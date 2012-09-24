From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] vxlan: virtual extensible lan
Date: Mon, 24 Sep 2012 21:39:07 +0200
Message-ID: <1348515547.26828.1538.camel@edumazet-glaptop>
References: <20120924184304.727711327@vyatta.com>
	 <20120924185050.162920909@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43987 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932071Ab2IXTjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 15:39:12 -0400
Received: by bkcjk13 with SMTP id jk13so1145942bkc.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 12:39:11 -0700 (PDT)
In-Reply-To: <20120924185050.162920909@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 11:43 -0700, Stephen Hemminger wrote:

> +/* Callback from net/ipv4/udp.c to receive packets */
> +static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
> +{
> +	struct iphdr *oip = ip_hdr(skb);

oip is set to ip_hdr(skb)

> +	struct vxlanhdr *vxh;
> +	struct vxlan_dev *vxlan;
> +	struct vxlan_stats *stats;
> +	__u32 vni;
> +	__be32 saddr = oip->saddr;	/* source address for learning */
> +	__be32 daddr = oip->daddr;	/* destination for checking */
> +
> +	/* pop off outer UDP header */
> +	__skb_pull(skb, sizeof(struct udphdr));
> +
> +	/* Need Vxlan and inner Ethernet header to be present */
> +	if (!pskb_may_pull(skb,
> +			   sizeof(struct vxlanhdr) + sizeof(struct ethhdr)))
> +		goto error;
> +

here oip may points to a freed memory, if pskb_may_pull) has to
reallocate skb->head

> +	/* Drop packets with reserved bits set */
> +	vxh = (struct vxlanhdr *) skb->data;
> +	if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
> +	    (vxh->vx_vni & htonl(0xff)))
> +		goto error;
> +
> +	__skb_pull(skb, sizeof(struct vxlanhdr));
> +
> +	/* Is this VNI defined? */
> +	vni = ntohl(vxh->vx_vni) >> 8;
> +	vxlan = vxlan_find_vni(sock_net(sk), vni);
> +	if (!vxlan)
> +		goto drop;
> +
> +	/* Ignore packets if device is not up */
> +	if (!netif_running(vxlan->dev))
> +		goto drop;
> +
> +	/* Re-examine inner Ethernet packet */
> +	skb->protocol = eth_type_trans(skb, vxlan->dev);
> +	skb->ip_summed = CHECKSUM_NONE;
> +
> +	/* Ignore packet loops (and multicast echo) */
> +	if (compare_ether_addr(eth_hdr(skb)->h_source,
> +			       vxlan->dev->dev_addr) == 0)
> +		goto drop;
> +
> +	/* Check for multicast group configuration errors */
> +	if (IN_MULTICAST(ntohl(daddr)) &&
> +	    daddr != vxlan->gaddr) {
> +		if (net_ratelimit())
> +			netdev_notice(vxlan->dev,
> +				      "group address %pI4 does not match\n",
> +				      &daddr);
> +		goto drop;
> +	}
> +
> +	if (vxlan->learn)
> +		vxlan_snoop(skb->dev, saddr, eth_hdr(skb)->h_source);
> +
> +	stats = this_cpu_ptr(vxlan->stats);
> +	u64_stats_update_begin(&stats->syncp);
> +	stats->rx_packets++;
> +	stats->rx_bytes += skb->len;
> +	u64_stats_update_end(&stats->syncp);
> +
> +	__skb_tunnel_rx(skb, vxlan->dev);
> +	skb_reset_network_header(skb);


> +	vxlan_ecn_decap(oip, skb);

potential crash
