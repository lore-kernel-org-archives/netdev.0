From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 11/14] netlink: add RX/TX-ring support to netlink diag
Date: Wed, 17 Apr 2013 18:47:06 +0200
Message-ID: <1366217229-22705-12-git-send-email-kaber@trash.net>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60964 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936249Ab3DQQrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:47:33 -0400
In-Reply-To: <1366217229-22705-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on AF_PACKET.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/uapi/linux/netlink_diag.h | 10 ++++++++++
 net/netlink/diag.c                | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 42 insertions(+)

diff --git a/include/uapi/linux/netlink_diag.h b/include/uapi/linux/netlink_diag.h
index 88009a3..4e31db4 100644
--- a/include/uapi/linux/netlink_diag.h
+++ b/include/uapi/linux/netlink_diag.h
@@ -25,9 +25,18 @@ struct netlink_diag_msg {
 	__u32	ndiag_cookie[2];
 };
 
+struct netlink_diag_ring {
+	__u32	ndr_block_size;
+	__u32	ndr_block_nr;
+	__u32	ndr_frame_size;
+	__u32	ndr_frame_nr;
+};
+
 enum {
 	NETLINK_DIAG_MEMINFO,
 	NETLINK_DIAG_GROUPS,
+	NETLINK_DIAG_RX_RING,
+	NETLINK_DIAG_TX_RING,
 
 	__NETLINK_DIAG_MAX,
 };
@@ -38,5 +47,6 @@ enum {
 
 #define NDIAG_SHOW_MEMINFO	0x00000001 /* show memory info of a socket */
 #define NDIAG_SHOW_GROUPS	0x00000002 /* show groups of a netlink socket */
+#define NDIAG_SHOW_RING_CFG	0x00000004 /* show ring configuration */
 
 #endif
diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index 5ffb1d1..4e4aa47 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -7,6 +7,34 @@
 
 #include "af_netlink.h"
 
+static int sk_diag_put_ring(struct netlink_ring *ring, int nl_type,
+			    struct sk_buff *nlskb)
+{
+	struct netlink_diag_ring ndr;
+
+	ndr.ndr_block_size = ring->pg_vec_pages << PAGE_SHIFT;
+	ndr.ndr_block_nr   = ring->pg_vec_len;
+	ndr.ndr_frame_size = ring->frame_size;
+	ndr.ndr_frame_nr   = ring->frame_max + 1;
+
+	return nla_put(nlskb, nl_type, sizeof(ndr), &ndr);
+}
+
+static int sk_diag_put_rings_cfg(struct sock *sk, struct sk_buff *nlskb)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+	int ret;
+
+	mutex_lock(&nlk->pg_vec_lock);
+	ret = sk_diag_put_ring(&nlk->rx_ring, NETLINK_DIAG_RX_RING, nlskb);
+	if (!ret)
+		ret = sk_diag_put_ring(&nlk->tx_ring, NETLINK_DIAG_TX_RING,
+				       nlskb);
+	mutex_unlock(&nlk->pg_vec_lock);
+
+	return ret;
+}
+
 static int sk_diag_dump_groups(struct sock *sk, struct sk_buff *nlskb)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -51,6 +79,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 	    sock_diag_put_meminfo(sk, skb, NETLINK_DIAG_MEMINFO))
 		goto out_nlmsg_trim;
 
+	if ((req->ndiag_show & NDIAG_SHOW_RING_CFG) &&
+	    sk_diag_put_rings_cfg(sk, skb))
+		goto out_nlmsg_trim;
+
 	return nlmsg_end(skb, nlh);
 
 out_nlmsg_trim:
-- 
1.8.1.4
