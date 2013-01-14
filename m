From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 09/10] bnx2x: Added FW GRO bridging support
Date: Mon, 14 Jan 2013 17:11:49 +0200
Message-ID: <1358176310-31504-10-git-send-email-yuvalmin@broadcom.com>
References: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4309 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757268Ab3ANQKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 11:10:20 -0500
In-Reply-To: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since submit 621b4d6 the bnx2x driver support FW GRO.
However, when using the device with GRO enabled in bridging
scenarios throughput is very low, as the bridge expects all
incoming packets to be passed with CHECKSUM_PARTIAL -
a demand which is satisfied by the SW GRO implementation,
but was missed in the bnx2x driver implementation (which returned
CHECKSUM_UNNECESSARY).

Now, given that the traffic is supported by FW GRO (TCP/IP),
the bnx2x driver calculates the pseudo checksum by itself,
passing skbs with CHECKSUM_PARTIAL and giving a much better
throughput when receiving GRO traffic.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 54 ++++++++++++++++++++++++-
 1 file changed, 52 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index a6f4140..963eb2d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -21,6 +21,7 @@
 #include <linux/if_vlan.h>
 #include <linux/interrupt.h>
 #include <linux/ip.h>
+#include <net/tcp.h>
 #include <net/ipv6.h>
 #include <net/ip6_checksum.h>
 #include <linux/prefetch.h>
@@ -506,7 +507,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 					tpa_info->parsing_flags, len_on_bd);
 
 		/* set for GRO */
-		if (fp->mode == TPA_MODE_GRO)
+		if (fp->mode == TPA_MODE_GRO && skb_shinfo(skb)->gso_size)
 			skb_shinfo(skb)->gso_type =
 			    (GET_FLAG(tpa_info->parsing_flags,
 				      PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) ==
@@ -595,6 +596,55 @@ static void *bnx2x_frag_alloc(const struct bnx2x_fastpath *fp)
 }
 
 
+#ifdef CONFIG_INET
+static void bnx2x_gro_ip_csum(struct bnx2x *bp, struct sk_buff *skb)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct tcphdr *th;
+
+	skb_set_transport_header(skb, sizeof(struct iphdr));
+	th = tcp_hdr(skb);
+
+	th->check = ~tcp_v4_check(skb->len - skb_transport_offset(skb),
+				  iph->saddr, iph->daddr, 0);
+}
+
+static void bnx2x_gro_ipv6_csum(struct bnx2x *bp, struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct tcphdr *th;
+
+	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
+	th = tcp_hdr(skb);
+
+	th->check = ~tcp_v6_check(skb->len - skb_transport_offset(skb),
+				  &iph->saddr, &iph->daddr, 0);
+}
+#endif
+
+static void bnx2x_gro_receive(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+			       struct sk_buff *skb)
+{
+#ifdef CONFIG_INET
+	if (fp->mode == TPA_MODE_GRO && skb_shinfo(skb)->gso_size) {
+		skb_set_network_header(skb, 0);
+		switch (be16_to_cpu(skb->protocol)) {
+		case ETH_P_IP:
+			bnx2x_gro_ip_csum(bp, skb);
+			break;
+		case ETH_P_IPV6:
+			bnx2x_gro_ipv6_csum(bp, skb);
+			break;
+		default:
+			BNX2X_ERR("FW GRO supports only IPv4/IPv6, not 0x%04x\n",
+				  be16_to_cpu(skb->protocol));
+		}
+		tcp_gro_complete(skb);
+	}
+#endif
+	napi_gro_receive(&fp->napi, skb);
+}
+
 static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			   struct bnx2x_agg_info *tpa_info,
 			   u16 pages,
@@ -648,7 +698,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 					 skb, cqe, cqe_idx)) {
 			if (tpa_info->parsing_flags & PARSING_FLAGS_VLAN)
 				__vlan_hwaccel_put_tag(skb, tpa_info->vlan_tag);
-			napi_gro_receive(&fp->napi, skb);
+			bnx2x_gro_receive(bp, fp, skb);
 		} else {
 			DP(NETIF_MSG_RX_STATUS,
 			   "Failed to allocate new pages - dropping packet!\n");
-- 
1.8.1.227.g44fe835
