From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH v4 net-next] ppp: Fix one deadlock issue of PPP when
 reentrant
Date: Mon, 22 Aug 2016 14:35:25 +0200
Message-ID: <20160822123525.ycymv43cdaoykuqt@alphalink.fr>
References: <1471828814-19187-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulus@samba.org, philipp@redfish-solutions.com,
        linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1471828814-19187-1-git-send-email-fgao@ikuai8.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 22, 2016 at 09:20:14AM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> PPP channel holds one spinlock before send frame. But the skb may
> select the same PPP channel with wrong route policy. As a result,
> the skb reaches the same channel path. It tries to get the same
> spinlock which is held before. Bang, the deadlock comes out.
>
Thanks for following up on this case.
On my side, I've thought a bit more about it in the weekend and cooked
this patch.
It's experimental and requires cleanup and further testing, but it
should fix all issues I could think of (at least for PPP over L2TP).

The main idea is to use a per-cpu variable to detect recursion in
selected points of PPP and L2TP xmit path.

---
 drivers/net/ppp/ppp_generic.c | 49 ++++++++++++++++++++++++++++++++-----------
 net/l2tp/l2tp_core.c          | 28 +++++++++++++++++++++----
 2 files changed, 61 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index f226db4..c33036bf 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1354,6 +1354,8 @@ static void ppp_setup(struct net_device *dev)
 	dev->netdev_ops = &ppp_netdev_ops;
 	SET_NETDEV_DEVTYPE(dev, &ppp_type);
 
+	dev->features |= NETIF_F_LLTX;
+
 	dev->hard_header_len = PPP_HDRLEN;
 	dev->mtu = PPP_MRU;
 	dev->addr_len = 0;
@@ -1367,12 +1369,7 @@ static void ppp_setup(struct net_device *dev)
  * Transmit-side routines.
  */
 
-/*
- * Called to do any work queued up on the transmit side
- * that can now be done.
- */
-static void
-ppp_xmit_process(struct ppp *ppp)
+static void __ppp_xmit_process(struct ppp *ppp)
 {
 	struct sk_buff *skb;
 
@@ -1392,6 +1389,23 @@ ppp_xmit_process(struct ppp *ppp)
 	ppp_xmit_unlock(ppp);
 }
 
+static DEFINE_PER_CPU(int, ppp_xmit_recursion);
+
+/* Called to do any work queued up on the transmit side that can now be done */
+static void ppp_xmit_process(struct ppp *ppp)
+{
+	if (unlikely(__this_cpu_read(ppp_xmit_recursion))) {
+		WARN(1, "recursion detected\n");
+		return;
+	}
+
+	__this_cpu_inc(ppp_xmit_recursion);
+	local_bh_disable();
+	__ppp_xmit_process(ppp);
+	local_bh_enable();
+	__this_cpu_dec(ppp_xmit_recursion);
+}
+
 static inline struct sk_buff *
 pad_compress_skb(struct ppp *ppp, struct sk_buff *skb)
 {
@@ -1847,11 +1861,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 }
 #endif /* CONFIG_PPP_MULTILINK */
 
-/*
- * Try to send data out on a channel.
- */
-static void
-ppp_channel_push(struct channel *pch)
+static void __ppp_channel_push(struct channel *pch)
 {
 	struct sk_buff *skb;
 	struct ppp *ppp;
@@ -1876,11 +1886,26 @@ ppp_channel_push(struct channel *pch)
 		read_lock_bh(&pch->upl);
 		ppp = pch->ppp;
 		if (ppp)
-			ppp_xmit_process(ppp);
+			__ppp_xmit_process(ppp);
 		read_unlock_bh(&pch->upl);
 	}
 }
 
+/* Try to send data out on a channel */
+static void ppp_channel_push(struct channel *pch)
+{
+	if (unlikely(__this_cpu_read(ppp_xmit_recursion))) {
+		WARN(1, "recursion detected\n");
+		return;
+	}
+
+	__this_cpu_inc(ppp_xmit_recursion);
+	local_bh_disable();
+	__ppp_channel_push(pch);
+	local_bh_enable();
+	__this_cpu_dec(ppp_xmit_recursion);
+}
+
 /*
  * Receive-side routines.
  */
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 1e40dac..bdfb1be 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1096,10 +1096,8 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 	return 0;
 }
 
-/* If caller requires the skb to have a ppp header, the header must be
- * inserted in the skb data before calling this function.
- */
-int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len)
+static int __l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb,
+			   int hdr_len)
 {
 	int data_len = skb->len;
 	struct l2tp_tunnel *tunnel = session->tunnel;
@@ -1178,6 +1176,28 @@ out_unlock:
 
 	return ret;
 }
+
+static DEFINE_PER_CPU(int, l2tp_xmit_recursion);
+
+/* If caller requires the skb to have a ppp header, the header must be
+ * inserted in the skb data before calling this function.
+ */
+int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb,
+		  int hdr_len)
+{
+	int ret;
+
+	if (unlikely(__this_cpu_read(l2tp_xmit_recursion))) {
+		WARN(1, "recursion detected\n");
+		return NET_XMIT_DROP;
+	}
+
+	__this_cpu_inc(l2tp_xmit_recursion);
+	ret = __l2tp_xmit_skb(session, skb, hdr_len);
+	__this_cpu_dec(l2tp_xmit_recursion);
+
+	return ret;
+}
 EXPORT_SYMBOL_GPL(l2tp_xmit_skb);
 
 /*****************************************************************************
-- 
2.9.3
