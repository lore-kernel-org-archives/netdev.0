From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH next-next 1/7] ipv6: Cleanup IPv6 tunnel receive path
Date: Fri, 29 Apr 2016 17:12:15 -0700
Message-ID: <1461975141-954269-2-git-send-email-tom@herbertland.com>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55805 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750973AbcD3AOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 20:14:40 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3U0C2uu024689
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22mggpg9eg-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:39 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 86dcbc9a0e6811e6b5d224be0595f910-d43f7c50 for <netdev@vger.kernel.org>;	Fri,
 29 Apr 2016 17:14:38 -0700
In-Reply-To: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some basic changes to make IPv6 tunnel receive path look more like
IPv4 path:
  - Make ip6_tnl_rcv non-static so that GREv6 and others can call it
  - Make ip6_tnl_rcv look like ip_tunnel_rcv
  - Switch to gro_cells_receive
  - Make ip6_tnl_rcv non-static and export it

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/ip6_tunnel.h |   4 +
 net/ipv6/ip6_tunnel.c    | 212 +++++++++++++++++++++++++++++++----------------
 2 files changed, 146 insertions(+), 70 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 499a707..eab3a9b 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -42,6 +42,7 @@ struct ip6_tnl {
 	struct __ip6_tnl_parm parms;	/* tunnel configuration parameters */
 	struct flowi fl;	/* flowi template for xmit */
 	struct dst_cache dst_cache;	/* cached dst */
+	struct gro_cells gro_cells;
 
 	int err_count;
 	unsigned long err_time;
@@ -63,6 +64,9 @@ struct ipv6_tlv_tnl_enc_lim {
 
 int ip6_tnl_rcv_ctl(struct ip6_tnl *t, const struct in6_addr *laddr,
 		const struct in6_addr *raddr);
+int ip6_tnl_rcv(struct ip6_tnl *tunnel, struct sk_buff *skb,
+		const struct tnl_ptk_info *tpi, struct metadata_dst *tun_dst,
+		bool log_ecn_error);
 int ip6_tnl_xmit_ctl(struct ip6_tnl *t, const struct in6_addr *laddr,
 		     const struct in6_addr *raddr);
 __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 1f20345..94ed065 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -238,6 +238,7 @@ static void ip6_dev_free(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 
+	gro_cells_destroy(&t->gro_cells);
 	dst_cache_destroy(&t->dst_cache);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
@@ -753,97 +754,157 @@ int ip6_tnl_rcv_ctl(struct ip6_tnl *t,
 }
 EXPORT_SYMBOL_GPL(ip6_tnl_rcv_ctl);
 
-/**
- * ip6_tnl_rcv - decapsulate IPv6 packet and retransmit it locally
- *   @skb: received socket buffer
- *   @protocol: ethernet protocol ID
- *   @dscp_ecn_decapsulate: the function to decapsulate DSCP code and ECN
- *
- * Return: 0
- **/
-
-static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
-		       __u8 ipproto,
-		       int (*dscp_ecn_decapsulate)(const struct ip6_tnl *t,
-						   const struct ipv6hdr *ipv6h,
-						   struct sk_buff *skb))
+static int __ip6_tnl_rcv(struct ip6_tnl *tunnel, struct sk_buff *skb,
+			 const struct tnl_ptk_info *tpi,
+			 struct metadata_dst *tun_dst,
+			 int (*dscp_ecn_decapsulate)(const struct ip6_tnl *t,
+						const struct ipv6hdr *ipv6h,
+						struct sk_buff *skb),
+			 bool log_ecn_err)
 {
-	struct ip6_tnl *t;
+	struct pcpu_sw_netstats *tstats;
 	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
-	u8 tproto;
 	int err;
 
-	rcu_read_lock();
-	t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr, &ipv6h->daddr);
-	if (t) {
-		struct pcpu_sw_netstats *tstats;
+	if ((!(tpi->flags & TUNNEL_CSUM) &&
+	     (tunnel->parms.i_flags & TUNNEL_CSUM)) ||
+	    ((tpi->flags & TUNNEL_CSUM) &&
+	     !(tunnel->parms.i_flags & TUNNEL_CSUM))) {
+		tunnel->dev->stats.rx_crc_errors++;
+		tunnel->dev->stats.rx_errors++;
+		goto drop;
+	}
 
-		tproto = ACCESS_ONCE(t->parms.proto);
-		if (tproto != ipproto && tproto != 0) {
-			rcu_read_unlock();
-			goto discard;
+	if (tunnel->parms.i_flags & TUNNEL_SEQ) {
+		if (!(tpi->flags & TUNNEL_SEQ) ||
+		    (tunnel->i_seqno &&
+		     (s32)(ntohl(tpi->seq) - tunnel->i_seqno) < 0)) {
+			tunnel->dev->stats.rx_fifo_errors++;
+			tunnel->dev->stats.rx_errors++;
+			goto drop;
 		}
+		tunnel->i_seqno = ntohl(tpi->seq) + 1;
+	}
 
-		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-			rcu_read_unlock();
-			goto discard;
-		}
+	skb->protocol = tpi->proto;
 
-		if (!ip6_tnl_rcv_ctl(t, &ipv6h->daddr, &ipv6h->saddr)) {
-			t->dev->stats.rx_dropped++;
-			rcu_read_unlock();
-			goto discard;
+	/* Warning: All skb pointers will be invalidated! */
+	if (tunnel->dev->type == ARPHRD_ETHER) {
+		if (!pskb_may_pull(skb, ETH_HLEN)) {
+			tunnel->dev->stats.rx_length_errors++;
+			tunnel->dev->stats.rx_errors++;
+			goto drop;
 		}
-		skb->mac_header = skb->network_header;
-		skb_reset_network_header(skb);
-		skb->protocol = htons(protocol);
-		memset(skb->cb, 0, sizeof(struct inet6_skb_parm));
-
-		__skb_tunnel_rx(skb, t->dev, t->net);
-
-		err = dscp_ecn_decapsulate(t, ipv6h, skb);
-		if (unlikely(err)) {
-			if (log_ecn_error)
-				net_info_ratelimited("non-ECT from %pI6 with dsfield=%#x\n",
-						     &ipv6h->saddr,
-						     ipv6_get_dsfield(ipv6h));
-			if (err > 1) {
-				++t->dev->stats.rx_frame_errors;
-				++t->dev->stats.rx_errors;
-				rcu_read_unlock();
-				goto discard;
-			}
+
+		ipv6h = ipv6_hdr(skb);
+		skb->protocol = eth_type_trans(skb, tunnel->dev);
+		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
+	} else {
+		skb->dev = tunnel->dev;
+	}
+
+	skb_reset_network_header(skb);
+	memset(skb->cb, 0, sizeof(struct inet6_skb_parm));
+
+	__skb_tunnel_rx(skb, tunnel->dev, tunnel->net);
+
+	err = dscp_ecn_decapsulate(tunnel, ipv6h, skb);
+	if (unlikely(err)) {
+		if (log_ecn_err)
+			net_info_ratelimited("non-ECT from %pI6 with DS=%#x\n",
+					     &ipv6h->saddr,
+					     ipv6_get_dsfield(ipv6h));
+		if (err > 1) {
+			++tunnel->dev->stats.rx_frame_errors;
+			++tunnel->dev->stats.rx_errors;
+			goto drop;
 		}
+	}
 
-		tstats = this_cpu_ptr(t->dev->tstats);
-		u64_stats_update_begin(&tstats->syncp);
-		tstats->rx_packets++;
-		tstats->rx_bytes += skb->len;
-		u64_stats_update_end(&tstats->syncp);
+	tstats = this_cpu_ptr(tunnel->dev->tstats);
+	u64_stats_update_begin(&tstats->syncp);
+	tstats->rx_packets++;
+	tstats->rx_bytes += skb->len;
+	u64_stats_update_end(&tstats->syncp);
 
-		netif_rx(skb);
+	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(tunnel->dev)));
 
-		rcu_read_unlock();
-		return 0;
+	gro_cells_receive(&tunnel->gro_cells, skb);
+	return 0;
+
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+
+int ip6_tnl_rcv(struct ip6_tnl *t, struct sk_buff *skb,
+		const struct tnl_ptk_info *tpi,
+		struct metadata_dst *tun_dst,
+		bool log_ecn_err)
+{
+	return __ip6_tnl_rcv(t, skb, tpi, NULL, ip6ip6_dscp_ecn_decapsulate,
+			     log_ecn_err);
+}
+EXPORT_SYMBOL(ip6_tnl_rcv);
+
+static const struct tnl_ptk_info tpi_v6 = {
+	/* no tunnel info required for ipxip6. */
+	.proto = htons(ETH_P_IPV6),
+};
+
+static const struct tnl_ptk_info tpi_v4 = {
+	/* no tunnel info required for ipxip6. */
+	.proto = htons(ETH_P_IP),
+};
+
+static int ipxip6_rcv(struct sk_buff *skb, u8 ipproto,
+		      const struct tnl_ptk_info *tpi,
+		      int (*dscp_ecn_decapsulate)(const struct ip6_tnl *t,
+						  const struct ipv6hdr *ipv6h,
+						  struct sk_buff *skb))
+{
+	struct ip6_tnl *t;
+	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+	int ret = -1;
+
+	rcu_read_lock();
+	t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr, &ipv6h->daddr);
+
+	if (t) {
+		u8 tproto = ACCESS_ONCE(t->parms.proto);
+
+		if (tproto != ipproto && tproto != 0)
+			goto drop;
+		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
+			goto drop;
+		if (!ip6_tnl_rcv_ctl(t, &ipv6h->daddr, &ipv6h->saddr))
+			goto drop;
+		if (iptunnel_pull_header(skb, 0, tpi->proto, false))
+			goto drop;
+		ret = __ip6_tnl_rcv(t, skb, tpi, NULL, dscp_ecn_decapsulate,
+				    log_ecn_error);
 	}
+
 	rcu_read_unlock();
-	return 1;
 
-discard:
+	return ret;
+
+drop:
+	rcu_read_unlock();
 	kfree_skb(skb);
 	return 0;
 }
 
 static int ip4ip6_rcv(struct sk_buff *skb)
 {
-	return ip6_tnl_rcv(skb, ETH_P_IP, IPPROTO_IPIP,
-			   ip4ip6_dscp_ecn_decapsulate);
+	return ipxip6_rcv(skb, IPPROTO_IP, &tpi_v4,
+			  ip4ip6_dscp_ecn_decapsulate);
 }
 
 static int ip6ip6_rcv(struct sk_buff *skb)
 {
-	return ip6_tnl_rcv(skb, ETH_P_IPV6, IPPROTO_IPV6,
-			   ip6ip6_dscp_ecn_decapsulate);
+	return ipxip6_rcv(skb, IPPROTO_IPV6, &tpi_v6,
+			  ip6ip6_dscp_ecn_decapsulate);
 }
 
 struct ipv6_tel_txoption {
@@ -1370,6 +1431,8 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct net *net = t->net;
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
+	memset(&p1, 0, sizeof(p1));
+
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		if (dev == ip6n->fb_tnl_dev) {
@@ -1549,13 +1612,22 @@ ip6_tnl_dev_init_gen(struct net_device *dev)
 		return -ENOMEM;
 
 	ret = dst_cache_init(&t->dst_cache, GFP_KERNEL);
-	if (ret) {
-		free_percpu(dev->tstats);
-		dev->tstats = NULL;
-		return ret;
-	}
+	if (ret)
+		goto free_stats;
+
+	ret = gro_cells_init(&t->gro_cells, dev);
+	if (ret)
+		goto destroy_dst;
 
 	return 0;
+
+destroy_dst:
+	dst_cache_destroy(&t->dst_cache);
+free_stats:
+	free_percpu(dev->tstats);
+	dev->tstats = NULL;
+
+	return ret;
 }
 
 /**
-- 
2.8.0.rc2
