From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next v1 1/3] gtp: refactor to support flow-based gtp
 encap and decap
Date: Thu, 13 Jul 2017 09:26:24 +0200
Message-ID: <20170713072624.iinvf7sqiwn6abff@nataraja>
References: <20170713004455.3946570-1-ouyangj@fb.com>
 <20170713004455.3946570-2-ouyangj@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: osmocom-net-gprs@lists.osmocom.org, netdev@vger.kernel.org,
        dev@openvswitch.org, pablo@netfilter.org, pshelar@nicira.com,
        wieger.ijntema.tno@gmail.com, yi.y.yang@intel.com, joe@ovn.org,
        amarpadmanabhan@fb.com
To: Jiannan Ouyang <ouyangj@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:38855 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751200AbdGMHh4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 03:37:56 -0400
Content-Disposition: inline
In-Reply-To: <20170713004455.3946570-2-ouyangj@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiannan,

On Wed, Jul 12, 2017 at 05:44:53PM -0700, Jiannan Ouyang wrote:

> +#define GTP_PDP_HASHSIZE 1024

please don't mix cosmetic cleanups with actual functional code changes.

> -	struct net_device       *dev;
> +	struct net_device	*dev;

please don't mix cosmetic cleanups with actual functional code changes.

> -static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
> -			unsigned int hdrlen, unsigned int role)
> +static int gtp_rx(struct gtp_dev *gtp, struct sk_buff *skb,
> +		  unsigned int hdrlen, struct sock *sk,
> +		  struct metadata_dst *tun_dst)
>  {
>  	struct pcpu_sw_netstats *stats;
>  
> -	if (!gtp_check_ms(skb, pctx, hdrlen, role)) {
> -		netdev_dbg(pctx->dev, "No PDP ctx for this MS\n");
> -		return 1;
> -	}
> -
>  	/* Get rid of the GTP + UDP headers. */
>  	if (iptunnel_pull_header(skb, hdrlen, skb->protocol,
> -				 !net_eq(sock_net(pctx->sk), dev_net(pctx->dev))))
> +				 !net_eq(sock_net(sk), dev_net(gtp->dev))))
>  		return -1;
>  
> -	netdev_dbg(pctx->dev, "forwarding packet from GGSN to uplink\n");
> +	netdev_dbg(gtp->dev, "forwarding packet from GGSN to uplink\n");
> +
> +	if (tun_dst) {
> +		skb_dst_set(skb, (struct dst_entry *)tun_dst);
> +		netdev_dbg(gtp->dev, "attaching metadata_dst to skb\n");
> +	}
>  
>  	/* Now that the UDP and the GTP header have been removed, set up the
>  	 * new network header. This is required by the upper layer to
> @@ -207,15 +215,16 @@ static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
>  	 */
>  	skb_reset_network_header(skb);
>  
> -	skb->dev = pctx->dev;
> +	skb->dev = gtp->dev;
>  
> -	stats = this_cpu_ptr(pctx->dev->tstats);
> +	stats = this_cpu_ptr(gtp->dev->tstats);
>  	u64_stats_update_begin(&stats->syncp);
>  	stats->rx_packets++;
>  	stats->rx_bytes += skb->len;
>  	u64_stats_update_end(&stats->syncp);
>  
>  	netif_rx(skb);
> +
>  	return 0;
>  }
>  
> @@ -244,7 +253,12 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
>  		return 1;
>  	}
>  
> -	return gtp_rx(pctx, skb, hdrlen, gtp->role);
> +	if (!gtp_check_ms(skb, pctx, hdrlen, gtp->role)) {
> +		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
> +		return 1;
> +	}
> +
> +	return gtp_rx(gtp, skb, hdrlen, pctx->sk, NULL);
>  }
>  
>  static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
> @@ -253,6 +267,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
>  			      sizeof(struct gtp1_header);
>  	struct gtp1_header *gtp1;
>  	struct pdp_ctx *pctx;
> +	struct metadata_dst *tun_dst = NULL;
>  
>  	if (!pskb_may_pull(skb, hdrlen))
>  		return -1;
> @@ -280,13 +295,24 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
>  
>  	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
>  
> -	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
> -	if (!pctx) {
> -		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
> -		return 1;
> +	if (ip_tunnel_collect_metadata() || gtp->collect_md) {
> +		tun_dst = udp_tun_rx_dst(skb, gtp->sk1u->sk_family, TUNNEL_KEY,
> +					 key32_to_tunnel_id(gtp1->tid), 0);
> +	} else {
> +		pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
> +		if (!pctx) {
> +			netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n",
> +				   skb);
> +			return 1;
> +		}
> +
> +		if (!gtp_check_ms(skb, pctx, hdrlen, gtp->role)) {
> +			netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
> +			return 1;
> +		}
>  	}
>  
> -	return gtp_rx(pctx, skb, hdrlen, gtp->role);
> +	return gtp_rx(gtp, skb, hdrlen, gtp->sk1u, tun_dst);
>  }
>  
>  static void gtp_encap_destroy(struct sock *sk)
> @@ -410,7 +436,7 @@ static inline void gtp0_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
>  	gtp0->tid	= cpu_to_be64(pctx->u.v0.tid);
>  }
>  
> -static inline void gtp1_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
> +static inline void gtp1_push_header(struct sk_buff *skb, __be32 tid)
>  {
>  	int payload_len = skb->len;
>  	struct gtp1_header *gtp1;
> @@ -426,7 +452,7 @@ static inline void gtp1_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
>  	gtp1->flags	= 0x30; /* v1, GTP-non-prime. */
>  	gtp1->type	= GTP_TPDU;
>  	gtp1->length	= htons(payload_len);
> -	gtp1->tid	= htonl(pctx->u.v1.o_tei);
> +	gtp1->tid	= tid;
>  
>  	/* TODO: Suppport for extension header, sequence number and N-PDU.
>  	 *	 Update the length field if any of them is available.
> @@ -438,34 +464,17 @@ struct gtp_pktinfo {
>  	struct iphdr		*iph;
>  	struct flowi4		fl4;
>  	struct rtable		*rt;
> -	struct pdp_ctx		*pctx;
>  	struct net_device	*dev;
>  	__be16			gtph_port;
>  };
>  
> -static void gtp_push_header(struct sk_buff *skb, struct gtp_pktinfo *pktinfo)
> -{
> -	switch (pktinfo->pctx->gtp_version) {
> -	case GTP_V0:
> -		pktinfo->gtph_port = htons(GTP0_PORT);
> -		gtp0_push_header(skb, pktinfo->pctx);
> -		break;
> -	case GTP_V1:
> -		pktinfo->gtph_port = htons(GTP1U_PORT);
> -		gtp1_push_header(skb, pktinfo->pctx);
> -		break;
> -	}
> -}
> -
>  static inline void gtp_set_pktinfo_ipv4(struct gtp_pktinfo *pktinfo,
>  					struct sock *sk, struct iphdr *iph,
> -					struct pdp_ctx *pctx, struct rtable *rt,
> -					struct flowi4 *fl4,
> +					struct rtable *rt, struct flowi4 *fl4,
>  					struct net_device *dev)
>  {
>  [...]
> +	__be32 tun_id;

you are breaking GTPv0 functionality here.  GTPv0 has 64 bit tunnel
identifiers, and this function is called both from GTPv1 and GTPv0
context.

This makes me wonder how you did verify that your changes do not break
the existing operation with both GTPv0 and GTPv1?

> +	// flow-based GTP1U encap
> +	info = skb_tunnel_info(skb);
> +	if (gtp->collect_md && info && ntohs(info->key.tp_dst) == GTP1U_PORT) {

I think it's typically safe to assume that GTP is only operated on
standard ports, but it is something you chould/should think about, i.e.
whether you want that kind of restriction.  In the existing use case, we
have the v0/v1 information stored in the per-pdp context structure.

> +		tun_id	= htonl(pctx->u.v1.o_tei);

here is where you're assuming GTPv1 in two ways from code that is called
from both v0 and v1.
* you're dereferencing a v1 specific element in the pctx union
* you're storing the result in a 32bit variable

>  	gtp = netdev_priv(dev);
> +	gtp->net = src_net;

Isn't this a generic change that's independent of your work on OVS GTP?

Regards,
	Harald

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
