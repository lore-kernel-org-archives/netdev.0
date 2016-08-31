From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC 1/9] ipv6: implement dataplane support for rthdr type 4
 (Segment Routing Header)
Date: Wed, 31 Aug 2016 16:51:34 +0200
Message-ID: <9a7b8a77-5832-1038-00f8-b24f8e7b8d4c@6wind.com>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
 <1472226767-9904-2-git-send-email-david.lebrun@uclouvain.be>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: David Lebrun <david.lebrun@uclouvain.be>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34821 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935178AbcHaOvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 10:51:39 -0400
Received: by mail-wm0-f50.google.com with SMTP id w2so34804434wmd.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 07:51:38 -0700 (PDT)
In-Reply-To: <1472226767-9904-2-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/08/2016 à 17:52, David Lebrun a écrit :
> Implement minimal support for processing of SR-enabled packets
> as described in
> https://tools.ietf.org/html/draft-ietf-6man-segment-routing-header-01.
> 
> This patch implements the following operations:
> - Intermediate segment endpoint: incrementation of active segment and rerouting.
> - Egress for SR-encapsulated packets: decapsulation of outer IPv6 header + SRH
>   and routing of inner packet.
> - Cleanup flag support for SR-inlined packets: removal of SRH if we are the
>   penultimate segment endpoint.
> 
> A per-interface sysctl seg6_enabled is provided, to accept/deny SR-enabled
> packets. Default is deny.
> 
> This patch does not provide support for HMAC-signed packets.
> 
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
> ---
Thanks for proposing this feature. It would be great to have it upstream.

[snip]
> +config IPV6_SEG6
> +	bool "IPv6: Segment Routing support"
> +	depends on IPV6
> +	---help---
> +	  Experimental support for IPv6 Segment Routing dataplane as defined
> +	  in IETF draft-ietf-6man-segment-routing-header-01. This option
> +	  enables the processing of SR-enabled packets allowing the kernel
> +	  to act as a segment endpoint (intermediate or egress).
> +
> +	  If unsure, say N.
> +
I don't think that the option is needed. At the end, every distributions will
turn it on.

[snip]
> +#ifdef CONFIG_IPV6_SEG6
> +	{
> +		.procname	= "seg6_enabled",
> +		.data		= &ipv6_devconf.seg6_enabled,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +#endif
Don't forget to document this option in Documentation/networking/ip-sysctl.txt.
Don't forget to explain how 'all' works ;-)
It would be nice to also add it in netconf subsystem (see 'git grep netconf
net/ipv6').

[snip]
> +#ifdef CONFIG_IPV6_SEG6
> +static int ipv6_srh_rcv(struct sk_buff *skb)
> +{
> +	struct inet6_skb_parm *opt = IP6CB(skb);
> +	struct in6_addr *addr = NULL, *last_addr = NULL, *active_addr = NULL;
> +	struct ipv6_sr_hdr *hdr;
> +	struct net *net = dev_net(skb->dev);
> +	int cleanup = 0;
> +	struct inet6_dev *idev;
> +	int accept_seg6;
nit: better to follow the 'reverse christmas tree' scheme when declaring variables.

> +
> +	hdr = (struct ipv6_sr_hdr *)skb_transport_header(skb);
> +
> +	idev = __in6_dev_get(skb->dev);
> +
> +	accept_seg6 = net->ipv6.devconf_all->seg6_enabled;
> +	if (accept_seg6 > idev->cnf.seg6_enabled)
> +		accept_seg6 = idev->cnf.seg6_enabled;
> +
> +	if (!accept_seg6) {
> +		kfree_skb(skb);
> +		return -1;
> +	}
> +
> +looped_back:
> +	last_addr = hdr->segments;
> +
> +	if (hdr->segments_left > 0) {
> +		if (hdr->nexthdr != NEXTHDR_IPV6 && hdr->segments_left == 1 &&
> +		    sr_get_flags(hdr) & SR6_FLAG_CLEANUP)
> +			cleanup = 1;
> +	} else {
> +		if (hdr->nexthdr == NEXTHDR_IPV6) {
> +			int offset = (hdr->hdrlen + 1) << 3;
> +
> +			if (!pskb_pull(skb, offset)) {
> +				kfree_skb(skb);
> +				return -1;
> +			}
> +			skb_postpull_rcsum(skb, skb_transport_header(skb),
> +					   offset);
> +
> +			skb_reset_network_header(skb);
> +			skb_reset_transport_header(skb);
> +			skb->encapsulation = 0;
> +
> +			__skb_tunnel_rx(skb, skb->dev, net);
> +
> +			netif_rx(skb);
> +			return -1;
> +		}
> +
> +		opt->srcrt = skb_network_header_len(skb);
> +		opt->lastopt = opt->srcrt;
> +		skb->transport_header += (hdr->hdrlen + 1) << 3;
> +		opt->nhoff = (&hdr->nexthdr) - skb_network_header(skb);
> +
> +		return 1;
> +	}
> +
> +	if (skb_cloned(skb)) {
> +		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
> +			__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
> +					IPSTATS_MIB_OUTDISCARDS);
> +			kfree_skb(skb);
> +			return -1;
> +		}
> +	}
> +
> +	if (skb->ip_summed == CHECKSUM_COMPLETE)
> +		skb->ip_summed = CHECKSUM_NONE;
> +
> +	hdr = (struct ipv6_sr_hdr *)skb_transport_header(skb);
> +
> +	active_addr = hdr->segments + hdr->segments_left;
> +	hdr->segments_left--;
> +	addr = hdr->segments + hdr->segments_left;
> +
> +	ipv6_hdr(skb)->daddr = *addr;
> +
> +	skb_push(skb, sizeof(struct ipv6hdr));
> +
> +	/* cleanup */
> +
> +	if (cleanup) {
> +		int srhlen = (hdr->hdrlen + 1) << 3;
> +		int nh = hdr->nexthdr;
> +
> +		memmove(skb_network_header(skb) + srhlen,
> +			skb_network_header(skb),
> +			(unsigned char *)hdr - skb_network_header(skb));
> +		skb_pull(skb, srhlen);
> +		skb->network_header += srhlen;
> +		ipv6_hdr(skb)->nexthdr = nh;
> +		ipv6_hdr(skb)->payload_len = htons(skb->len -
> +						   sizeof(struct ipv6hdr));
> +	}
> +
> +	skb_dst_drop(skb);
> +
> +	ip6_route_input(skb);
The destination address has now changed and the packet is routed again.
skb->nfct is not updated, it is intentional? I'm asking me if it's conceptually
right.
