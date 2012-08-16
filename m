From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/2] packet: Report fanout status via diag engine
Date: Thu, 16 Aug 2012 19:36:48 +0400
Message-ID: <502D1390.2010600@parallels.com>
References: <502D125A.40701@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9313 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932788Ab2HPPgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 11:36:53 -0400
In-Reply-To: <502D125A.40701@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported value is the same reported by the FANOUT getsockoption, but
unlike it, the absent fanout setup results in absent nlattr, rather
than in nlattr with zero value. This is done so, since zero fanout
report may mean both -- no fanout, and fanou with both id and type zero.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/packet_diag.h |    2 ++
 net/packet/af_packet.c      |   23 +++--------------------
 net/packet/diag.c           |   20 ++++++++++++++++++++
 net/packet/internal.h       |   20 +++++++++++++++++++-
 4 files changed, 44 insertions(+), 21 deletions(-)

diff --git a/include/linux/packet_diag.h b/include/linux/packet_diag.h
index 34ade82..93f5fa9 100644
--- a/include/linux/packet_diag.h
+++ b/include/linux/packet_diag.h
@@ -15,6 +15,7 @@ struct packet_diag_req {
 #define PACKET_SHOW_INFO	0x00000001 /* Basic packet_sk information */
 #define PACKET_SHOW_MCLIST	0x00000002 /* A set of packet_diag_mclist-s */
 #define PACKET_SHOW_RING_CFG	0x00000004 /* Rings configuration parameters */
+#define PACKET_SHOW_FANOUT	0x00000008
 
 struct packet_diag_msg {
 	__u8	pdiag_family;
@@ -30,6 +31,7 @@ enum {
 	PACKET_DIAG_MCLIST,
 	PACKET_DIAG_RX_RING,
 	PACKET_DIAG_TX_RING,
+	PACKET_DIAG_FANOUT,
 
 	PACKET_DIAG_MAX,
 };
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8a1605a..226b2cd 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -207,24 +207,6 @@ static void prb_fill_vlan_info(struct tpacket_kbdq_core *,
 		struct tpacket3_hdr *);
 static void packet_flush_mclist(struct sock *sk);
 
-#define PACKET_FANOUT_MAX	256
-
-struct packet_fanout {
-#ifdef CONFIG_NET_NS
-	struct net		*net;
-#endif
-	unsigned int		num_members;
-	u16			id;
-	u8			type;
-	u8			defrag;
-	atomic_t		rr_cur;
-	struct list_head	list;
-	struct sock		*arr[PACKET_FANOUT_MAX];
-	spinlock_t		lock;
-	atomic_t		sk_ref;
-	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
-};
-
 struct packet_skb_cb {
 	unsigned int origlen;
 	union {
@@ -1148,7 +1130,8 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 	return po->prot_hook.func(skb, dev, &po->prot_hook, orig_dev);
 }
 
-static DEFINE_MUTEX(fanout_mutex);
+DEFINE_MUTEX(fanout_mutex);
+EXPORT_SYMBOL_GPL(fanout_mutex);
 static LIST_HEAD(fanout_list);
 
 static void __fanout_link(struct sock *sk, struct packet_sock *po)
@@ -1260,9 +1243,9 @@ static void fanout_release(struct sock *sk)
 	if (!f)
 		return;
 
+	mutex_lock(&fanout_mutex);
 	po->fanout = NULL;
 
-	mutex_lock(&fanout_mutex);
 	if (atomic_dec_and_test(&f->sk_ref)) {
 		list_del(&f->list);
 		dev_remove_pack(&f->prot_hook);
diff --git a/net/packet/diag.c b/net/packet/diag.c
index e3975e4..bc33fbe 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -109,6 +109,22 @@ static int pdiag_put_rings_cfg(struct packet_sock *po, struct sk_buff *skb)
 	return ret;
 }
 
+static int pdiag_put_fanout(struct packet_sock *po, struct sk_buff *nlskb)
+{
+	int ret = 0;
+
+	mutex_lock(&fanout_mutex);
+	if (po->fanout) {
+		u32 val;
+
+		val = (u32)po->fanout->id | ((u32)po->fanout->type << 16);
+		ret = nla_put_u32(nlskb, PACKET_DIAG_FANOUT, val);
+	}
+	mutex_unlock(&fanout_mutex);
+
+	return ret;
+}
+
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct packet_diag_req *req,
 		u32 pid, u32 seq, u32 flags, int sk_ino)
 {
@@ -139,6 +155,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct packet_diag
 			pdiag_put_rings_cfg(po, skb))
 		goto out_nlmsg_trim;
 
+	if ((req->pdiag_show & PACKET_SHOW_FANOUT) &&
+			pdiag_put_fanout(po, skb))
+		goto out_nlmsg_trim;
+
 	return nlmsg_end(skb, nlh);
 
 out_nlmsg_trim:
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 2c5fca2..44945f6 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -67,7 +67,25 @@ struct packet_ring_buffer {
 	atomic_t		pending;
 };
 
-struct packet_fanout;
+extern struct mutex fanout_mutex;
+#define PACKET_FANOUT_MAX	256
+
+struct packet_fanout {
+#ifdef CONFIG_NET_NS
+	struct net		*net;
+#endif
+	unsigned int		num_members;
+	u16			id;
+	u8			type;
+	u8			defrag;
+	atomic_t		rr_cur;
+	struct list_head	list;
+	struct sock		*arr[PACKET_FANOUT_MAX];
+	spinlock_t		lock;
+	atomic_t		sk_ref;
+	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
+};
+
 struct packet_sock {
 	/* struct sock has to be the first member of packet_sock */
 	struct sock		sk;
-- 
1.7.6.5
