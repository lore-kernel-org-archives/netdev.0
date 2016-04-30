From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH next-next 3/7] gre6: Cleanup GREv6 receive path, call common GRE functions
Date: Fri, 29 Apr 2016 17:12:17 -0700
Message-ID: <1461975141-954269-4-git-send-email-tom@herbertland.com>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:10948 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752650AbcD3AOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 20:14:45 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3U0DmIm023015
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22ktt2rp4a-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:44 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 8909875a0e6811e6b5d224be0595f910-d43f7c50 for <netdev@vger.kernel.org>;	Fri,
 29 Apr 2016 17:14:42 -0700
In-Reply-To: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  - Create gre_rcv function. This calls gre_parse_header and ip6gre_rcv.
  - Call ip6_tnl_rcv. Doing this and using gre_parse_header eliminates
    most of the code in ip6gre_rcv.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_gre.c | 140 +++++++++--------------------------------------------
 1 file changed, 23 insertions(+), 117 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index ca5a2c5..9b33745 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -54,6 +54,7 @@
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>
 #include <net/ip6_tunnel.h>
+#include <net/gre.h>
 
 
 static bool log_ecn_error = true;
@@ -443,137 +444,40 @@ static void ip6gre_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	t->err_time = jiffies;
 }
 
-static int ip6gre_rcv(struct sk_buff *skb)
+static int ip6gre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 {
 	const struct ipv6hdr *ipv6h;
-	u8     *h;
-	__be16    flags;
-	__sum16   csum = 0;
-	__be32 key = 0;
-	u32    seqno = 0;
 	struct ip6_tnl *tunnel;
-	int    offset = 4;
-	__be16 gre_proto;
-	int err;
-
-	if (!pskb_may_pull(skb, sizeof(struct in6_addr)))
-		goto drop;
 
 	ipv6h = ipv6_hdr(skb);
-	h = skb->data;
-	flags = *(__be16 *)h;
-
-	if (flags&(GRE_CSUM|GRE_KEY|GRE_ROUTING|GRE_SEQ|GRE_VERSION)) {
-		/* - Version must be 0.
-		   - We do not support routing headers.
-		 */
-		if (flags&(GRE_VERSION|GRE_ROUTING))
-			goto drop;
-
-		if (flags&GRE_CSUM) {
-			csum = skb_checksum_simple_validate(skb);
-			offset += 4;
-		}
-		if (flags&GRE_KEY) {
-			key = *(__be32 *)(h + offset);
-			offset += 4;
-		}
-		if (flags&GRE_SEQ) {
-			seqno = ntohl(*(__be32 *)(h + offset));
-			offset += 4;
-		}
-	}
-
-	gre_proto = *(__be16 *)(h + 2);
-
 	tunnel = ip6gre_tunnel_lookup(skb->dev,
-					  &ipv6h->saddr, &ipv6h->daddr, key,
-					  gre_proto);
+				      &ipv6h->saddr, &ipv6h->daddr, tpi->key,
+				      tpi->proto);
 	if (tunnel) {
-		struct pcpu_sw_netstats *tstats;
-
-		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
-			goto drop;
-
-		if (!ip6_tnl_rcv_ctl(tunnel, &ipv6h->daddr, &ipv6h->saddr)) {
-			tunnel->dev->stats.rx_dropped++;
-			goto drop;
-		}
-
-		skb->protocol = gre_proto;
-		/* WCCP version 1 and 2 protocol decoding.
-		 * - Change protocol to IPv6
-		 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
-		 */
-		if (flags == 0 && gre_proto == htons(ETH_P_WCCP)) {
-			skb->protocol = htons(ETH_P_IPV6);
-			if ((*(h + offset) & 0xF0) != 0x40)
-				offset += 4;
-		}
+		ip6_tnl_rcv(tunnel, skb, tpi, NULL, false);
 
-		skb->mac_header = skb->network_header;
-		__pskb_pull(skb, offset);
-		skb_postpull_rcsum(skb, skb_transport_header(skb), offset);
-
-		if (((flags&GRE_CSUM) && csum) ||
-		    (!(flags&GRE_CSUM) && tunnel->parms.i_flags&GRE_CSUM)) {
-			tunnel->dev->stats.rx_crc_errors++;
-			tunnel->dev->stats.rx_errors++;
-			goto drop;
-		}
-		if (tunnel->parms.i_flags&GRE_SEQ) {
-			if (!(flags&GRE_SEQ) ||
-			    (tunnel->i_seqno &&
-					(s32)(seqno - tunnel->i_seqno) < 0)) {
-				tunnel->dev->stats.rx_fifo_errors++;
-				tunnel->dev->stats.rx_errors++;
-				goto drop;
-			}
-			tunnel->i_seqno = seqno + 1;
-		}
-
-		/* Warning: All skb pointers will be invalidated! */
-		if (tunnel->dev->type == ARPHRD_ETHER) {
-			if (!pskb_may_pull(skb, ETH_HLEN)) {
-				tunnel->dev->stats.rx_length_errors++;
-				tunnel->dev->stats.rx_errors++;
-				goto drop;
-			}
-
-			ipv6h = ipv6_hdr(skb);
-			skb->protocol = eth_type_trans(skb, tunnel->dev);
-			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
-		}
-
-		__skb_tunnel_rx(skb, tunnel->dev, tunnel->net);
+		return PACKET_RCVD;
+	}
 
-		skb_reset_network_header(skb);
+	return PACKET_REJECT;
+}
 
-		err = IP6_ECN_decapsulate(ipv6h, skb);
-		if (unlikely(err)) {
-			if (log_ecn_error)
-				net_info_ratelimited("non-ECT from %pI6 with dsfield=%#x\n",
-						     &ipv6h->saddr,
-						     ipv6_get_dsfield(ipv6h));
-			if (err > 1) {
-				++tunnel->dev->stats.rx_frame_errors;
-				++tunnel->dev->stats.rx_errors;
-				goto drop;
-			}
-		}
+static int gre_rcv(struct sk_buff *skb)
+{
+	struct tnl_ptk_info tpi;
+	bool csum_err = false;
+	int hdr_len;
 
-		tstats = this_cpu_ptr(tunnel->dev->tstats);
-		u64_stats_update_begin(&tstats->syncp);
-		tstats->rx_packets++;
-		tstats->rx_bytes += skb->len;
-		u64_stats_update_end(&tstats->syncp);
+	if (gre_parse_header(skb, &tpi, &csum_err, &hdr_len) < 0)
+		goto drop;
 
-		netif_rx(skb);
+	if (iptunnel_pull_header(skb, hdr_len, tpi.proto, false))
+		goto drop;
 
+	if (ip6gre_rcv(skb, &tpi) == PACKET_RCVD)
 		return 0;
-	}
-	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 drop:
 	kfree_skb(skb);
 	return 0;
@@ -1075,6 +979,8 @@ static int ip6gre_tunnel_ioctl(struct net_device *dev,
 	struct net *net = t->net;
 	struct ip6gre_net *ign = net_generic(net, ip6gre_net_id);
 
+	memset(&p1, 0, sizeof(p1));
+
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		if (dev == ign->fb_tunnel_dev) {
@@ -1318,7 +1224,7 @@ static void ip6gre_fb_tunnel_init(struct net_device *dev)
 
 
 static struct inet6_protocol ip6gre_protocol __read_mostly = {
-	.handler     = ip6gre_rcv,
+	.handler     = gre_rcv,
 	.err_handler = ip6gre_err,
 	.flags       = INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
-- 
2.8.0.rc2
