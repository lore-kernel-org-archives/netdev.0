From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 14 Feb 2012 21:13:13 +0000
Message-ID: <1329253993.2443.30.camel@bwh-desktop>
References: <20120212191342.1458.70498.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:35326 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757293Ab2BNVNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 16:13:16 -0500
In-Reply-To: <20120212191342.1458.70498.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for persisting, Greg.

On Sun, 2012-02-12 at 11:13 -0800, Greg Rose wrote:
> Implement a new nlattr type IFLA_EXT_MASK.  The mask is a 32 bit
> value that can be used to indicate to the kernel that certain
> extended ifinfo values are requested by the user application.
> At this time the only mask value created is RTEXT_FILTER_VF to
> indicate that the user wants the ifinfo dump to send information
> about the VFs belonging to the interface.
> 
> I have kept the NLM_F_EXT nlmsg_flags bit to indicate to the kernel
> that the extended ifinfo dump filter mask is present.  It does not
> act as the filter itself which has changed since the first submission
> of this RFC.  Older versions of user applications won't set this
> flag which should fix the problem of some applications not allocating
> a large enough buffer for all the extended interface information.
[...]
> --- a/include/linux/netlink.h
> +++ b/include/linux/netlink.h
> @@ -59,6 +59,7 @@ struct nlmsghdr {
>  #define NLM_F_MATCH	0x200	/* return all matching	*/
>  #define NLM_F_ATOMIC	0x400	/* atomic GET		*/
>  #define NLM_F_DUMP	(NLM_F_ROOT|NLM_F_MATCH)
> +#define NLM_F_EXT	0x800	/* Get extended interface info such as VFs */
>  
>  /* Modifiers to NEW request */
>  #define NLM_F_REPLACE	0x100	/* Override existing		*/
> @@ -215,6 +216,7 @@ int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
>  #else
>  #define NLMSG_GOODSIZE	SKB_WITH_OVERHEAD(8192UL)
>  #endif
> +#define NLMSG_EXT_GOODSIZE SKB_WITH_OVERHEAD(32768UL)

This will probably do for now, but it would be preferable to really
calculate the maximum size.

I fear this is going to be too small in some cases while resulting in
allocation failures in others (that's an order-4 page allocation!).
Maybe reduce the message size slightly so that the skb data allocation
is within 32K?

[...]
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
[...]
> @@ -1055,6 +1059,17 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
>  	rcu_read_lock();
>  	cb->seq = net->dev_base_seq;
>  
> +	if (cb->nlh->nlmsg_flags && NLM_F_EXT) {

& not &&

> +		struct rtattr *ext_req;
> +		u32 *ext_req_data;
> +		req = (struct rtnl_req_extended *)cb->nlh;
> +		ext_req = (struct rtattr *)&req->ext;
> +		if (ext_req->rta_type == IFLA_EXT_MASK) {
> +			ext_req_data = RTA_DATA(ext_req);
> +			ext_filter_mask = *ext_req_data;
> +		}
> +	}

We cannot trust a flag to tell us what the length of the message is.  We
have to check the value of nlmsg_len (which netlink has already
validated as being within the skb length and >= our declared request
header length).  I think that makes the flag redundant.

In fact, I think we should really use nlmsg_parse() here.  That might be
overkill when there's only a single valid attribute; I don't know.

[...]
> @@ -1861,12 +1876,12 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
>  	if (dev == NULL)
>  		return -ENODEV;
>  
> -	nskb = nlmsg_new(if_nlmsg_size(dev), GFP_KERNEL);
> +	nskb = nlmsg_new(if_nlmsg_size(dev, 0), GFP_KERNEL);
>  	if (nskb == NULL)
>  		return -ENOBUFS;
>  
>  	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).pid,
> -			       nlh->nlmsg_seq, 0, 0);
> +			       nlh->nlmsg_seq, 0, 0, 0);
>  	if (err < 0) {
>  		/* -EMSGSIZE implies BUG in if_nlmsg_size */
>  		WARN_ON(err == -EMSGSIZE);

It seems like this ought to support IFLA_EXT_MASK as well, though it's
maybe less important ('ip link' doesn't need it).

> @@ -1877,9 +1892,26 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
>  	return err;
>  }
>  
> -static u16 rtnl_calcit(struct sk_buff *skb)
> +static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
>  {
> -	return min_ifinfo_dump_size;
> +	struct rtnl_req_extended *req;
> +	u32 ext_filter_mask = 0;
> +
> +	if (nlh->nlmsg_flags && NLM_F_EXT) {
> +		struct rtattr *ext_req;
> +		u32 *ext_req_data;
> +		req = (struct rtnl_req_extended *)&nlh;
> +		ext_req = (struct rtattr *)&req->ext;
> +		if (ext_req->rta_type == IFLA_EXT_MASK) {
> +			ext_req_data = RTA_DATA(ext_req);
> +			ext_filter_mask = *ext_req_data;
> +		}
> +	}
[...]

This has the same parsing problem as rtnl_dump_ifinfo().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
