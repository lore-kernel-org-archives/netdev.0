From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v1] net: gso: Add GSO support for NSH (Network
 Service Header)
Date: Fri, 25 Aug 2017 22:16:21 +0800
Message-ID: <20170825141620.GA23653@cran64.bj.intel.com>
References: <1503567376-64933-1-git-send-email-yi.y.yang@intel.com>
 <20170824161326.1f5f7c7f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "simon.horman@netronome.com" <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46004 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755767AbdHYObB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 10:31:01 -0400
Content-Disposition: inline
In-Reply-To: <20170824161326.1f5f7c7f@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 24, 2017 at 10:13:26PM +0800, Jiri Benc wrote:
> On Thu, 24 Aug 2017 17:36:16 +0800, Yi Yang wrote:
> >  include/net/nsh.h             | 307 ++++++++++++++++++++++++++++++++++++++++++
> >  include/uapi/linux/if_ether.h |   1 +
> >  net/Kconfig                   |   1 +
> >  net/Makefile                  |   1 +
> >  net/nsh/Kconfig               |  10 ++
> >  net/nsh/Makefile              |   4 +
> >  net/nsh/nsh_gso.c             | 116 ++++++++++++++++
> 
> Please consider making this a patchset, with a patch adding the NSH
> structures and helper functions, a patch adding GSO and a patch adding
> OVS support. That way, everything can be reviewed together, yet the
> patches are reasonably contained.

Sent out v6 as you said here.

> 
> > +config NET_NSH_GSO
> > +	bool "NSH GSO support"
> > +	depends on INET
> > +	default y
> > +	---help---
> > +	 This allows segmentation of GSO packet that have had NSH header pushed         onto them and thus become NSH GSO packets.
> 
> Seems you're missing a newline here.

Yes, fixed in v6.

> 
> > +static struct sk_buff *nsh_gso_segment(struct sk_buff *skb,
> > +				       netdev_features_t features)
> > +{
> > +	struct sk_buff *segs = ERR_PTR(-EINVAL);
> > +	__be16 protocol = skb->protocol;
> > +	__be16 inner_proto;
> > +	u16 mac_offset = skb->mac_header;
> > +	u16 mac_len = skb->mac_len;
> > +	struct nsh_hdr *nsh;
> > +	unsigned int nsh_hlen;
> > +	const struct net_offload *ops;
> > +	struct sk_buff *(*gso_inner_segment)(struct sk_buff *skb,
> > +					     netdev_features_t features);
> > +
> > +	skb_reset_network_header(skb);
> > +	nsh = (struct nsh_hdr *)skb_network_header(skb);
> > +	nsh_hlen = nsh_hdr_len(nsh);
> > +	if (unlikely(!pskb_may_pull(skb, nsh_hlen)))
> > +		goto out;
> 
> You have to reload nsh after this.

Yeah, reload it in v6.

> 
> > +
> > +	__skb_pull(skb, nsh_hlen);
> > +
> > +	skb_reset_mac_header(skb);
> > +	skb_reset_mac_len(skb);
> > +
> > +	rcu_read_lock();
> > +	switch (nsh->next_proto) {
> > +	case NSH_P_ETHERNET:
> > +		inner_proto = htons(ETH_P_TEB);
> > +		gso_inner_segment = skb_mac_gso_segment;
> > +		break;
> > +	case NSH_P_IPV4:
> > +		inner_proto = htons(ETH_P_IP);
> > +		ops = rcu_dereference(inet_offloads[inner_proto]);
> > +		if (!ops || !ops->callbacks.gso_segment)
> > +			goto out;
> > +		gso_inner_segment = ops->callbacks.gso_segment;
> > +		break;
> > +	case NSH_P_IPV6:
> > +		inner_proto = htons(ETH_P_IPV6);
> > +		ops = rcu_dereference(inet6_offloads[inner_proto]);
> > +		if (!ops || !ops->callbacks.gso_segment)
> > +			goto out;
> > +		gso_inner_segment = ops->callbacks.gso_segment;
> > +		break;
> > +	case NSH_P_NSH:
> > +		inner_proto = htons(ETH_P_NSH);
> > +		gso_inner_segment = nsh_gso_segment;
> 
> This doesn't look correct. Recursive call to nsh_gso_segment will reset
> mac header, causing skb_segment not to copy the previous NSH header(s)
> to the new segments.

There are some errors here, I carefully checked inet_gso_segment again,
it is very similiar to nsh_gso_segment. v6 should be ok.

> 
> > +		break;
> > +	default:
> > +		skb_gso_error_unwind(skb, protocol, nsh_hlen, mac_offset,
> > +				     mac_len);
> > +		goto out;
> > +	}
> > +
> > +	skb->protocol = inner_proto;
> > +	segs = gso_inner_segment(skb, features);
> > +	if (IS_ERR_OR_NULL(segs)) {
> > +		skb_gso_error_unwind(skb, protocol, nsh_hlen, mac_offset,
> > +				     mac_len);
> > +		goto out;
> > +	}
> > +
> > +	do {
> > +		skb->mac_len = mac_len;
> > +		skb->protocol = protocol;
> > +
> > +		skb_reset_inner_network_header(skb);
> 
> This looks superfluous.

v6 looks simple :-)

> 
> > +
> > +		__skb_push(skb, nsh_hlen);
> > +
> > +		skb_reset_mac_header(skb);
> > +		skb_set_network_header(skb, mac_len);
> > +	} while ((skb = skb->next));
> > +
> > +out:
> > +	rcu_read_unlock();
> > +	return segs;
> > +}
> > +
> > +static struct packet_offload nsh_offload __read_mostly = {
> > +	.type = cpu_to_be16(ETH_P_NSH),
> > +	.priority = 15,
> > +	.callbacks = {
> > +		.gso_segment    =	nsh_gso_segment,
> > +	},
> > +};
> > +
> > +static int __init nsh_gso_init(void)
> > +{
> > +	dev_add_offload(&nsh_offload);
> > +
> > +	return 0;
> > +}
> > +
> > +fs_initcall(nsh_gso_init);
> 
> device_initcall should be enough. I doubt we'll be doing NFS over
> NSH ;-)

I have used device_initcall in v6.

> 
>  Jiri
