From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v4 3/9] ipv6: sr: add support for SRH
 encapsulation and injection with lwtunnels
Date: Fri, 4 Nov 2016 15:21:54 +0100
Message-ID: <20161104142154.GA19947@pox.localdomain>
References: <1478255388-32213-1-git-send-email-david.lebrun@uclouvain.be>
 <1478255388-32213-4-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35797 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758408AbcKDOV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 10:21:58 -0400
Received: by mail-wm0-f49.google.com with SMTP id a197so54163796wmd.0
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 07:21:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1478255388-32213-4-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/16 at 11:29am, David Lebrun wrote:
> +/* insert an SRH within an IPv6 packet, just after the IPv6 header */
> +static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
> +{
> +	struct ipv6hdr *hdr, *oldhdr;
> +	struct ipv6_sr_hdr *isrh;
> +	int hdrlen, err;
> +
> +	hdrlen = (osrh->hdrlen + 1) << 3;
> +
> +	err = pskb_expand_head(skb, hdrlen, 0, GFP_ATOMIC);
> +	if (unlikely(err))
> +		return err;
> +
> +	oldhdr = ipv6_hdr(skb);
> +
> +	skb_pull(skb, sizeof(struct ipv6hdr));
> +	skb_postpull_rcsum(skb, skb_network_header(skb),
> +			   sizeof(struct ipv6hdr));
> +
> +	skb_push(skb, sizeof(struct ipv6hdr) + hdrlen);
> +	skb_reset_network_header(skb);
> +	skb_mac_header_rebuild(skb);
> +
> +	hdr = ipv6_hdr(skb);
> +
> +	memmove(hdr, oldhdr, sizeof(*hdr));
> +
> +	isrh = (void *)hdr + sizeof(*hdr);
> +	memcpy(isrh, osrh, hdrlen);
> +
> +	isrh->nexthdr = hdr->nexthdr;
> +	hdr->nexthdr = NEXTHDR_ROUTING;
> +
> +	isrh->segments[0] = hdr->daddr;
> +	hdr->daddr = isrh->segments[isrh->first_segment];

Where do you verify that isrh->first_segment is not out of bounds?

> +	skb_postpush_rcsum(skb, hdr, sizeof(struct ipv6hdr) + hdrlen);
> +
> +	return 0;
> +}
> +
> +
> +static int seg6_build_state(struct net_device *dev, struct nlattr *nla,
> +			    unsigned int family, const void *cfg,
> +			    struct lwtunnel_state **ts)
> +{
> +	struct nlattr *tb[SEG6_IPTUNNEL_MAX + 1];
> +	struct seg6_iptunnel_encap *tuninfo;
> +	struct lwtunnel_state *newts;
> +	struct seg6_lwt *slwt;
> +	int tuninfo_len;
> +	int err;
> +
> +	err = nla_parse_nested(tb, SEG6_IPTUNNEL_MAX, nla,
> +			       seg6_iptunnel_policy);
> +
> +	if (err < 0)
> +		return err;
> +
> +	if (!tb[SEG6_IPTUNNEL_SRH])
> +		return -EINVAL;
> +
> +	tuninfo = nla_data(tb[SEG6_IPTUNNEL_SRH]);
> +	tuninfo_len = SEG6_IPTUN_ENCAP_SIZE(tuninfo);

Nothing guarantees the size of the Netlink attribute right now. You
need to add a minimal size requirement to seg6_iptunnel_policy and
then check that the additional len provided in the struct itself does
not exceed the Netlink attribute length.
