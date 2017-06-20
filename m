From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 4/4] ip6mr: add netlink notifications on
 mrt6msg cache reports
Date: Tue, 20 Jun 2017 12:37:39 +0300
Message-ID: <200784c5-0e9f-9d92-776f-dd2072d1cefb@cumulusnetworks.com>
References: <20170619204417.13230-1-julien@arista.com>
 <20170619204417.13230-5-julien@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sharpd@cumulusnetworks.com, nicolas.dichtel@6wind.com
To: Julien Gomes <julien@arista.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36686 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752539AbdFTJhw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 05:37:52 -0400
Received: by mail-wm0-f51.google.com with SMTP id m125so16098848wmm.1
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 02:37:46 -0700 (PDT)
In-Reply-To: <20170619204417.13230-5-julien@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/06/17 23:44, Julien Gomes wrote:
> Add Netlink notifications on cache reports in ip6mr, in addition to the
> existing mrt6msg sent to mroute6_sk.
> Send RTM_NEWCACHEREPORT notifications to RTNLGRP_IPV6_MROUTE_R.
> 
> MSGTYPE, MIF_ID, SRC_ADDR and DST_ADDR Netlink attributes contain the
> same data as their equivalent fields in the mrt6msg header.
> PKT attribute is the packet sent to mroute6_sk, without the added
> mrt6msg header.
> 
> Suggested-by: Ryan Halbrook <halbrook@arista.com>
> Signed-off-by: Julien Gomes <julien@arista.com>
> ---
>  include/uapi/linux/mroute6.h | 12 ++++++++
>  net/ipv6/ip6mr.c             | 67 ++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 77 insertions(+), 2 deletions(-)
> 
> diff --git a/include/uapi/linux/mroute6.h b/include/uapi/linux/mroute6.h
> index ed5721148768..e4746816c855 100644
> --- a/include/uapi/linux/mroute6.h
> +++ b/include/uapi/linux/mroute6.h
> @@ -133,4 +133,16 @@ struct mrt6msg {
>  	struct in6_addr	im6_src, im6_dst;
>  };
>  
> +/* ip6mr netlink cache report attributes */
> +enum {
> +	IP6MRA_CREPORT_UNSPEC,
> +	IP6MRA_CREPORT_MSGTYPE,
> +	IP6MRA_CREPORT_MIF_ID,
> +	IP6MRA_CREPORT_SRC_ADDR,
> +	IP6MRA_CREPORT_DST_ADDR,
> +	IP6MRA_CREPORT_PKT,
> +	__IP6MRA_CREPORT_MAX
> +};
> +#define IP6MRA_CREPORT_MAX (__IP6MRA_CREPORT_MAX - 1)
> +
>  #endif /* _UAPI__LINUX_MROUTE6_H */
> diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
> index b0e2bf1f4212..28a1fb49f12e 100644
> --- a/net/ipv6/ip6mr.c
> +++ b/net/ipv6/ip6mr.c
> @@ -116,6 +116,7 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
>  			       struct mfc6_cache *c, struct rtmsg *rtm);
>  static void mr6_netlink_event(struct mr6_table *mrt, struct mfc6_cache *mfc,
>  			      int cmd);
> +static void mrt6msg_netlink_event(struct mr6_table *mrt, struct sk_buff *pkt);
>  static int ip6mr_rtm_dumproute(struct sk_buff *skb,
>  			       struct netlink_callback *cb);
>  static void mroute_clean_tables(struct mr6_table *mrt, bool all);
> @@ -1125,8 +1126,7 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
>  }
>  
>  /*
> - *	Bounce a cache query up to pim6sd. We could use netlink for this but pim6sd
> - *	expects the following bizarre scheme.
> + *	Bounce a cache query up to pim6sd and netlink.
>   *
>   *	Called under mrt_lock.
>   */
> @@ -1208,6 +1208,8 @@ static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff *pkt,
>  		return -EINVAL;
>  	}
>  
> +	mrt6msg_netlink_event(mrt, skb);
> +
>  	/*
>  	 *	Deliver to user space multicast routing algorithms
>  	 */
> @@ -2457,6 +2459,67 @@ static void mr6_netlink_event(struct mr6_table *mrt, struct mfc6_cache *mfc,
>  		rtnl_set_sk_err(net, RTNLGRP_IPV6_MROUTE, err);
>  }
>  
> +static void mrt6msg_netlink_event(struct mr6_table *mrt, struct sk_buff *pkt)
> +{
> +	struct net *net = read_pnet(&mrt->net);
> +	struct nlmsghdr *nlh;
> +	struct rtgenmsg *rtgenm;
> +	struct mrt6msg *msg;
> +	struct sk_buff *skb;
> +	struct nlattr *nla;
> +	int payloadlen;
> +	int msgsize;
> +
> +	payloadlen = pkt->len - sizeof(struct mrt6msg);
> +	msg = (struct mrt6msg *)skb_transport_header(pkt);
> +	msgsize = NLMSG_ALIGN(sizeof(struct rtgenmsg))
> +			+ nla_total_size(1)
> +					/* IP6MRA_CREPORT_MSGTYPE */
> +			+ nla_total_size(2)
> +					/* IP6MRA_CREPORT_MIF_ID */
> +			+ nla_total_size(sizeof(struct in6_addr))
> +					/* IP6MRA_CREPORT_SRC_ADDR */
> +			+ nla_total_size(sizeof(struct in6_addr))
> +					/* IP6MRA_CREPORT_DST_ADDR */
> +			+ nla_total_size(payloadlen)
> +					/* IP6MRA_CREPORT_PKT */
> +			;

Same as patch 03, this calculation could be in a separate function.

> +
> +	skb = nlmsg_new(msgsize, GFP_ATOMIC);
> +	if (!skb)
> +		goto errout;
> +
> +	nlh = nlmsg_put(skb, 0, 0, RTM_NEWCACHEREPORT,
> +			sizeof(struct rtgenmsg), 0);
> +	if (!nlh)
> +		goto errout;
> +	rtgenm = nlmsg_data(nlh);
> +	rtgenm->rtgen_family = RTNL_FAMILY_IP6MR;
> +	if (nla_put_u8(skb, IP6MRA_CREPORT_MSGTYPE, msg->im6_msgtype) ||
> +	    nla_put_u16(skb, IP6MRA_CREPORT_MIF_ID, msg->im6_mif) ||
> +	    nla_put_in6_addr(skb, IP6MRA_CREPORT_SRC_ADDR,
> +			     &msg->im6_src) ||
> +	    nla_put_in6_addr(skb, IP6MRA_CREPORT_DST_ADDR,
> +			     &msg->im6_dst))
> +		goto nla_put_failure;
> +
> +	nla = nla_reserve(skb, IP6MRA_CREPORT_PKT, payloadlen);
> +	if (!nla || skb_copy_bits(pkt, sizeof(struct mrt6msg),
> +				  nla_data(nla), payloadlen))
> +		goto nla_put_failure;
> +
> +	nlmsg_end(skb, nlh);
> +
> +	rtnl_notify(skb, net, 0, RTNLGRP_IPV6_MROUTE_R, NULL, GFP_ATOMIC);
> +	return;
> +
> +nla_put_failure:
> +	nlmsg_cancel(skb, nlh);
> +errout:
> +	kfree_skb(skb);
> +	rtnl_set_sk_err(net, RTNLGRP_IPV6_MROUTE_R, -ENOBUFS);
> +}
> +
>  static int ip6mr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
>  {
>  	struct net *net = sock_net(skb->sk);
> 
