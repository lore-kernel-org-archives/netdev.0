From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/2] packet: Report rings cfg via diag engine
Date: Thu, 16 Aug 2012 19:34:22 +0400
Message-ID: <502D12FE.1020405@parallels.com>
References: <502D125A.40701@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:18123 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757399Ab2HPPe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 11:34:26 -0400
In-Reply-To: <502D125A.40701@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One extension bit may result in two nlattrs -- one per ring type.
If some ring type is not configured, then the respective nlatts
will be empty.

The structure reported contains the data, that is given to the
corresponding ring setup socket option.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/packet_diag.h |   13 +++++++++++
 net/packet/diag.c           |   48 ++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 60 insertions(+), 1 deletions(-)

diff --git a/include/linux/packet_diag.h b/include/linux/packet_diag.h
index ea2e8923..34ade82 100644
--- a/include/linux/packet_diag.h
+++ b/include/linux/packet_diag.h
@@ -14,6 +14,7 @@ struct packet_diag_req {
 
 #define PACKET_SHOW_INFO	0x00000001 /* Basic packet_sk information */
 #define PACKET_SHOW_MCLIST	0x00000002 /* A set of packet_diag_mclist-s */
+#define PACKET_SHOW_RING_CFG	0x00000004 /* Rings configuration parameters */
 
 struct packet_diag_msg {
 	__u8	pdiag_family;
@@ -27,6 +28,8 @@ struct packet_diag_msg {
 enum {
 	PACKET_DIAG_INFO,
 	PACKET_DIAG_MCLIST,
+	PACKET_DIAG_RX_RING,
+	PACKET_DIAG_TX_RING,
 
 	PACKET_DIAG_MAX,
 };
@@ -54,4 +57,14 @@ struct packet_diag_mclist {
 	__u8	pdmc_addr[MAX_ADDR_LEN];
 };
 
+struct packet_diag_ring {
+	__u32	pdr_block_size;
+	__u32	pdr_block_nr;
+	__u32	pdr_frame_size;
+	__u32	pdr_frame_nr;
+	__u32	pdr_retire_tmo;
+	__u32	pdr_sizeof_priv;
+	__u32	pdr_features;
+};
+
 #endif
diff --git a/net/packet/diag.c b/net/packet/diag.c
index 3dda4ec..e3975e4 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -67,12 +67,54 @@ static int pdiag_put_mclist(const struct packet_sock *po, struct sk_buff *nlskb)
 	return 0;
 }
 
+static int pdiag_put_ring(struct packet_ring_buffer *ring, int ver, int nl_type,
+		struct sk_buff *nlskb)
+{
+	struct packet_diag_ring pdr;
+
+	if (!ring->pg_vec || ((ver > TPACKET_V2) &&
+				(nl_type == PACKET_DIAG_TX_RING)))
+		return 0;
+
+	pdr.pdr_block_size = ring->pg_vec_pages << PAGE_SHIFT;
+	pdr.pdr_block_nr = ring->pg_vec_len;
+	pdr.pdr_frame_size = ring->frame_size;
+	pdr.pdr_frame_nr = ring->frame_max + 1;
+
+	if (ver > TPACKET_V2) {
+		pdr.pdr_retire_tmo = ring->prb_bdqc.retire_blk_tov;
+		pdr.pdr_sizeof_priv = ring->prb_bdqc.blk_sizeof_priv;
+		pdr.pdr_features = ring->prb_bdqc.feature_req_word;
+	} else {
+		pdr.pdr_retire_tmo = 0;
+		pdr.pdr_sizeof_priv = 0;
+		pdr.pdr_features = 0;
+	}
+
+	return nla_put(nlskb, nl_type, sizeof(pdr), &pdr);
+}
+
+static int pdiag_put_rings_cfg(struct packet_sock *po, struct sk_buff *skb)
+{
+	int ret;
+
+	mutex_lock(&po->pg_vec_lock);
+	ret = pdiag_put_ring(&po->rx_ring, po->tp_version,
+			PACKET_DIAG_RX_RING, skb);
+	if (!ret)
+		ret = pdiag_put_ring(&po->tx_ring, po->tp_version,
+				PACKET_DIAG_TX_RING, skb);
+	mutex_unlock(&po->pg_vec_lock);
+
+	return ret;
+}
+
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct packet_diag_req *req,
 		u32 pid, u32 seq, u32 flags, int sk_ino)
 {
 	struct nlmsghdr *nlh;
 	struct packet_diag_msg *rp;
-	const struct packet_sock *po = pkt_sk(sk);
+	struct packet_sock *po = pkt_sk(sk);
 
 	nlh = nlmsg_put(skb, pid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rp), flags);
 	if (!nlh)
@@ -93,6 +135,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct packet_diag
 			pdiag_put_mclist(po, skb))
 		goto out_nlmsg_trim;
 
+	if ((req->pdiag_show & PACKET_SHOW_RING_CFG) &&
+			pdiag_put_rings_cfg(po, skb))
+		goto out_nlmsg_trim;
+
 	return nlmsg_end(skb, nlh);
 
 out_nlmsg_trim:
-- 
1.7.6.5
