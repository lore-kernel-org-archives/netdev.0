From: Christopher Zimmermann <madroach@zakweb.de>
Subject: Re: Possible bug: SO_TIMESTAMPING 2.6.30+
Date: Tue, 10 Nov 2009 09:12:52 +0100
Message-ID: <20091110091252.1667d27d@pundit>
References: <4AF8B67E.3030604@ripnet.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/E1KVNW40E31ptkQ=4vtartP"
Cc: netdev@vger.kernel.org
To: "Marcus D. Leech" <mleech@ripnet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:62087 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbZKJIM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 03:12:56 -0500
In-Reply-To: <4AF8B67E.3030604@ripnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/E1KVNW40E31ptkQ=4vtartP
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Mon, 09 Nov 2009 19:40:30 -0500
"Marcus D. Leech" <mleech@ripnet.com> wrote:


> I know that Patrick Ohly has essentially moved on from doing the 
> SO_TIMESTAMPING stuff, so
>    who's maintaining it now?

I worked on it a month ago or so and have a patchset from Patick Ohly
and some changes by me which fix software timestamping and make the
ioctl interface to the hardware more flexible (keeping backwards
compatibility). Patches are attached.
Still I never tried IPv6 and don't think the patches do anything about
it.
It would be nice to know weather software tx timestamps work
with/without the patches.


Christopher

--MP_/E1KVNW40E31ptkQ=4vtartP
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=0001-timecompare-use-ARRAY_SIZE-macro.patch

>From 5e408d962dbbafc581d4442d2e920dc667c0d078 Mon Sep 17 00:00:00 2001
From: Christopher Zimmermann <madroach@zakweb.de>
Date: Mon, 17 Aug 2009 21:26:17 +0200
Subject: [PATCH 1/3] timecompare: use ARRAY_SIZE() macro

---
 kernel/time/timecompare.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/time/timecompare.c b/kernel/time/timecompare.c
index 71e7f1a..fe24977 100644
--- a/kernel/time/timecompare.c
+++ b/kernel/time/timecompare.c
@@ -56,11 +56,11 @@ int timecompare_offset(struct timecompare *sync,
 	int index;
 	int num_samples = sync->num_samples;
 
-	if (num_samples > sizeof(buffer)/sizeof(buffer[0])) {
+	if (num_samples > ARRAY_SIZE(buffer)) {
 		samples = kmalloc(sizeof(*samples) * num_samples, GFP_ATOMIC);
 		if (!samples) {
 			samples = buffer;
-			num_samples = sizeof(buffer)/sizeof(buffer[0]);
+			num_samples = ARRAY_SIZE(buffer);
 		}
 	} else {
 		samples = buffer;
-- 
1.6.3.3


--MP_/E1KVNW40E31ptkQ=4vtartP
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=0002-net-software-TX-time-stamping.patch

>From 50d8dfcf781fd3e9ad1d6123ff204b9f77a185ea Mon Sep 17 00:00:00 2001
From: Christopher Zimmermann <madroach@zakweb.de>
Date: Mon, 17 Aug 2009 21:27:50 +0200
Subject: [PATCH 2/3] net: software TX time stamping

This patch implements the software fallback to TX time stamping. The
necessary access to the buffer and socket are secured by taking
references before calling ndo_start_xmit().

That avoids race conditions (buffer remains available even if
transmission completes before ndo_start_xmit() returns) and works
even if the driver calls skb_orphan().

The caller of skb_tstamp_tx() is now responsible for providing the
socket, which requires minor changes in users of the previous call:
add skb->sk as parameter to get the old behavior.
---
 drivers/net/igb/igb_main.c |    2 +-
 include/linux/skbuff.h     |   11 +++++---
 net/core/dev.c             |   65 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/skbuff.c          |    4 +-
 4 files changed, 75 insertions(+), 7 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index adb09d3..3ce4d78 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4370,7 +4370,7 @@ static void igb_tx_hwtstamp(struct igb_adapter *adapter, struct sk_buff *skb)
 			shhwtstamps.hwtstamp = ns_to_ktime(ns);
 			shhwtstamps.syststamp =
 				timecompare_transform(&adapter->compare, ns);
-			skb_tstamp_tx(skb, &shhwtstamps);
+			skb_tstamp_tx(skb, skb->sk, &shhwtstamps);
 		}
 	}
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f2c69a2..e29e43d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1873,17 +1873,20 @@ static inline ktime_t net_invalid_timestamp(void)
 
 /**
  * skb_tstamp_tx - queue clone of skb with send time stamps
- * @orig_skb:	the original outgoing packet
+ * @skb:	the original outgoing packet
+ * @sk:		sending socket (either from skb->sk or previous sock_get()),
+ *		may be NULL
  * @hwtstamps:	hardware time stamps, may be NULL if not available
  *
- * If the skb has a socket associated, then this function clones the
+ * If the socket is available, then this function clones the
  * skb (thus sharing the actual data and optional structures), stores
  * the optional hardware time stamping information (if non NULL) or
  * generates a software time stamp (otherwise), then queues the clone
  * to the error queue of the socket.  Errors are silently ignored.
  */
-extern void skb_tstamp_tx(struct sk_buff *orig_skb,
-			struct skb_shared_hwtstamps *hwtstamps);
+extern void skb_tstamp_tx(struct sk_buff *skb,
+			  struct sock *sk,
+			  struct skb_shared_hwtstamps *hwtstamps);
 
 extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 6a94475..e20e3ca 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1679,10 +1679,71 @@ static int dev_gso_segment(struct sk_buff *skb)
 	return 0;
 }
 
+/**
+ * struct tx_tstamp_context - context for software TX time stamping
+ * @sk: socket reference, NULL if nothing to do
+ * @skb: packet reference
+ */
+struct tx_tstamp_context {
+	struct sock *sk;
+	struct sk_buff *skb;
+};
+
+/**
+ * tx_tstamp_start - check for TX software time stamping and prepare for it
+ * @skb: buffer which is being sent
+ * @context: needs to be initialized for tx_tstamp_end()
+ */
+static void tx_tstamp_start(struct sk_buff *skb,
+			    struct tx_tstamp_context *context)
+{
+	union skb_shared_tx *shtx = skb_tx(skb);
+	/*
+	 * Prepare for TX time stamping in software if requested.
+	 * This could be optimized so that device drivers
+	 * do that themselves, which avoids the skb/sk ref/unref
+	 * overhead.
+	 */
+	if (unlikely(shtx->software &&
+		     skb->sk)) {
+		context->sk = skb->sk;
+		sock_hold(skb->sk);
+		context->skb = skb_get(skb);
+	} else {
+		/* TX software time stamping not requested/not possible. */
+		context->sk = NULL;
+	}
+}
+
+/**
+ * tx_tstamp_end - finish the work started by tx_tstamp_end()
+ * @context: may contain socket and buffer references
+ * @rc: result of ndo_start_xmit() - only do time stamping if packet was sent
+ */
+static void tx_tstamp_end(struct tx_tstamp_context *context, int rc)
+{
+	if (unlikely(context->sk)) {
+		union skb_shared_tx *shtx = skb_tx(context->skb);
+		/*
+		 * Checking shtx->software again is a bit redundant: it must
+		 * have been set in tx_tstamp_start(), but perhaps it
+		 * was cleared in the meantime to disable the TX software
+		 * fallback.
+		 */
+		if (likely(!rc) &&
+		    unlikely(shtx->software &&
+			     !shtx->in_progress))
+			skb_tstamp_tx(context->skb, context->sk, NULL);
+		sock_put(context->sk);
+		kfree_skb(context->skb);
+	}
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	struct tx_tstamp_context context;
 	int rc;
 
 	if (likely(!skb->next)) {
@@ -1703,6 +1764,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(skb);
 
+		tx_tstamp_start(skb, &context);
 		rc = ops->ndo_start_xmit(skb, dev);
 		if (rc == 0)
 			txq_trans_update(txq);
@@ -1720,6 +1782,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		 * the skb destructor before the call and restoring it
 		 * afterwards, then doing the skb_orphan() ourselves?
 		 */
+		tx_tstamp_end(&context, rc);
 		return rc;
 	}
 
@@ -1729,7 +1792,9 @@ gso:
 
 		skb->next = nskb->next;
 		nskb->next = NULL;
+		tx_tstamp_start(skb, &context);
 		rc = ops->ndo_start_xmit(nskb, dev);
+		tx_tstamp_end(&context, rc);
 		if (unlikely(rc)) {
 			nskb->next = skb->next;
 			skb->next = nskb;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9e0597d..78ae3e9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2971,9 +2971,9 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 EXPORT_SYMBOL_GPL(skb_cow_data);
 
 void skb_tstamp_tx(struct sk_buff *orig_skb,
-		struct skb_shared_hwtstamps *hwtstamps)
+		   struct sock *sk,
+		   struct skb_shared_hwtstamps *hwtstamps)
 {
-	struct sock *sk = orig_skb->sk;
 	struct sock_exterr_skb *serr;
 	struct sk_buff *skb;
 	int err;
-- 
1.6.3.3


--MP_/E1KVNW40E31ptkQ=4vtartP
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=0003-Change-kernel-timestamping-interface.patch

>From fc396501b8d0906253b1f85945b86da4130ee665 Mon Sep 17 00:00:00 2001
From: Christopher Zimmermann <madroach@sancho.(none)>
Date: Wed, 7 Oct 2009 17:28:26 +0200
Subject: [PATCH 3/3] Change kernel timestamping interface

Allow userspace to fine-tune hardware registers.
Stay backwards compatible to old userspace?
---
 .gitignore                   |    1 +
 drivers/net/igb/e1000_regs.h |   41 ++++++++++--------
 drivers/net/igb/igb_main.c   |   95 +++++++++++++++++++++++++----------------
 include/linux/net_tstamp.h   |   35 +++++++++++----
 4 files changed, 107 insertions(+), 65 deletions(-)

diff --git a/.gitignore b/.gitignore
index b93fb7e..6fac88c 100644
--- a/.gitignore
+++ b/.gitignore
@@ -32,6 +32,7 @@
 #
 # Top-level generic files
 #
+debian
 tags
 TAGS
 vmlinux
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 6e59245..1785b30 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -83,30 +83,33 @@
 #define E1000_TSYNCRXCTL_VALID (1<<0)
 #define E1000_TSYNCRXCTL_ENABLED (1<<4)
 enum {
+	/* bits 1 to 3 need leftshift <<1 for direct register access. */
 	E1000_TSYNCRXCTL_TYPE_L2_V2 = 0,
-	E1000_TSYNCRXCTL_TYPE_L4_V1 = (1<<1),
-	E1000_TSYNCRXCTL_TYPE_L2_L4_V2 = (1<<2),
-	E1000_TSYNCRXCTL_TYPE_ALL = (1<<3),
-	E1000_TSYNCRXCTL_TYPE_EVENT_V2 = (1<<3) | (1<<1),
+	E1000_TSYNCRXCTL_TYPE_L4_V1 = (1<<0),
+	E1000_TSYNCRXCTL_TYPE_L2_L4_V2 = (1<<1),
+	E1000_TSYNCRXCTL_TYPE_ALL = (1<<2),
+	E1000_TSYNCRXCTL_TYPE_EVENT_V2 = (1<<2) | (1<<0),
 };
 #define E1000_TSYNCRXCFG 0x05F50
 enum {
-	E1000_TSYNCRXCFG_PTP_V1_SYNC_MESSAGE = 0<<0,
-	E1000_TSYNCRXCFG_PTP_V1_DELAY_REQ_MESSAGE = 1<<0,
-	E1000_TSYNCRXCFG_PTP_V1_FOLLOWUP_MESSAGE = 2<<0,
-	E1000_TSYNCRXCFG_PTP_V1_DELAY_RESP_MESSAGE = 3<<0,
-	E1000_TSYNCRXCFG_PTP_V1_MANAGEMENT_MESSAGE = 4<<0,
+	/* bits 0 to 7 */
+	E1000_TSYNCRXCFG_PTP_V1_SYNC_MESSAGE = 0,
+	E1000_TSYNCRXCFG_PTP_V1_DELAY_REQ_MESSAGE = 1,
+	E1000_TSYNCRXCFG_PTP_V1_FOLLOWUP_MESSAGE = 2,
+	E1000_TSYNCRXCFG_PTP_V1_DELAY_RESP_MESSAGE = 3,
+	E1000_TSYNCRXCFG_PTP_V1_MANAGEMENT_MESSAGE = 4,
 
-	E1000_TSYNCRXCFG_PTP_V2_SYNC_MESSAGE = 0<<8,
-	E1000_TSYNCRXCFG_PTP_V2_DELAY_REQ_MESSAGE = 1<<8,
-	E1000_TSYNCRXCFG_PTP_V2_PATH_DELAY_REQ_MESSAGE = 2<<8,
-	E1000_TSYNCRXCFG_PTP_V2_PATH_DELAY_RESP_MESSAGE = 3<<8,
-	E1000_TSYNCRXCFG_PTP_V2_FOLLOWUP_MESSAGE = 8<<8,
-	E1000_TSYNCRXCFG_PTP_V2_DELAY_RESP_MESSAGE = 9<<8,
-	E1000_TSYNCRXCFG_PTP_V2_PATH_DELAY_FOLLOWUP_MESSAGE = 0xA<<8,
-	E1000_TSYNCRXCFG_PTP_V2_ANNOUNCE_MESSAGE = 0xB<<8,
-	E1000_TSYNCRXCFG_PTP_V2_SIGNALLING_MESSAGE = 0xC<<8,
-	E1000_TSYNCRXCFG_PTP_V2_MANAGEMENT_MESSAGE = 0xD<<8,
+	/* bits 8 to 11 need leftshift <<8 for direct register access */
+	E1000_TSYNCRXCFG_PTP_V2_SYNC_MESSAGE = 0,
+	E1000_TSYNCRXCFG_PTP_V2_DELAY_REQ_MESSAGE = 1,
+	E1000_TSYNCRXCFG_PTP_V2_PATH_DELAY_REQ_MESSAGE = 2,
+	E1000_TSYNCRXCFG_PTP_V2_PATH_DELAY_RESP_MESSAGE = 3,
+	E1000_TSYNCRXCFG_PTP_V2_FOLLOWUP_MESSAGE = 8,
+	E1000_TSYNCRXCFG_PTP_V2_DELAY_RESP_MESSAGE = 9,
+	E1000_TSYNCRXCFG_PTP_V2_PATH_DELAY_FOLLOWUP_MESSAGE = 0xA,
+	E1000_TSYNCRXCFG_PTP_V2_ANNOUNCE_MESSAGE = 0xB,
+	E1000_TSYNCRXCFG_PTP_V2_SIGNALLING_MESSAGE = 0xC,
+	E1000_TSYNCRXCFG_PTP_V2_MANAGEMENT_MESSAGE = 0xD,
 };
 #define E1000_SYSTIML 0x0B600
 #define E1000_SYSTIMH 0x0B604
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index adb09d3..17bfd5b 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1512,7 +1512,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	wr32(E1000_TIMINCA,
 	     (1<<24) |
 	     IGB_TSYNC_CYCLE_TIME_IN_NANOSECONDS * IGB_TSYNC_SCALE);
-#if 0
+#if 1
 	/*
 	 * Avoid rollover while we initialize by resetting the time counter.
 	 */
@@ -4881,28 +4881,33 @@ static int igb_hwtstamp_ioctl(struct net_device *netdev,
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	struct hwtstamp_config config;
+#if 0
 	u32 tsync_tx_ctl_bit = E1000_TSYNCTXCTL_ENABLED;
 	u32 tsync_rx_ctl_bit = E1000_TSYNCRXCTL_ENABLED;
 	u32 tsync_rx_ctl_type = 0;
 	u32 tsync_rx_cfg = 0;
 	int is_l4 = 0;
 	int is_l2 = 0;
-	short port = 319; /* PTP */
+#endif
 	u32 regval;
 
+	memset(&config, 0, sizeof(config));
+        /* TODO: first check, weather old or new interface is passed. */
 	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
 		return -EFAULT;
 
 	/* reserved for future extensions */
 	if (config.flags)
-		return -EINVAL;
+		goto manual;
 
 	switch (config.tx_type) {
 	case HWTSTAMP_TX_OFF:
-		tsync_tx_ctl_bit = 0;
+		//tsync_tx_ctl_bit = 0;
+		config.flags &= ~HWTSTAMP_TX;
 		break;
 	case HWTSTAMP_TX_ON:
-		tsync_tx_ctl_bit = E1000_TSYNCTXCTL_ENABLED;
+		//tsync_tx_ctl_bit = E1000_TSYNCTXCTL_ENABLED;
+		config.flags |= HWTSTAMP_TX;
 		break;
 	default:
 		return -ERANGE;
@@ -4910,7 +4915,7 @@ static int igb_hwtstamp_ioctl(struct net_device *netdev,
 
 	switch (config.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
-		tsync_rx_ctl_bit = 0;
+		config.flags &= ~HWTSTAMP_RX;
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
@@ -4921,57 +4926,68 @@ static int igb_hwtstamp_ioctl(struct net_device *netdev,
 		 * possible to time stamp both Sync and Delay_Req messages
 		 * => fall back to time stamping all packets
 		 */
-		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_ALL;
+		//tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_ALL;
+		config.igb.ptp_type = E1000_TSYNCRXCTL_TYPE_ALL;
 		config.rx_filter = HWTSTAMP_FILTER_ALL;
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
-		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_L4_V1;
-		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V1_SYNC_MESSAGE;
-		is_l4 = 1;
+		config.igb.ptp_type = E1000_TSYNCRXCTL_TYPE_L4_V1;
+		config.igb.ptp1_control = E1000_TSYNCRXCFG_PTP_V1_SYNC_MESSAGE;
+		config.igb.port = htons(319); /* PTP */
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
-		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_L4_V1;
-		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V1_DELAY_REQ_MESSAGE;
-		is_l4 = 1;
+		config.igb.ptp_type = E1000_TSYNCRXCTL_TYPE_L4_V1;
+		config.igb.ptp1_control = E1000_TSYNCRXCFG_PTP_V1_DELAY_REQ_MESSAGE;
+		config.igb.port = htons(319); /* PTP */
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
-		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_L2_L4_V2;
-		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V2_SYNC_MESSAGE;
-		is_l2 = 1;
-		is_l4 = 1;
+		config.igb.ptp_type = E1000_TSYNCRXCTL_TYPE_L2_L4_V2;
+		config.igb.ptp2_id = E1000_TSYNCRXCFG_PTP_V2_SYNC_MESSAGE;
+		config.igb.etype = 0x88F7;
+		config.igb.port = htons(319); /* PTP */
 		config.rx_filter = HWTSTAMP_FILTER_SOME;
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
 	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
-		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_L2_L4_V2;
-		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V2_DELAY_REQ_MESSAGE;
-		is_l2 = 1;
-		is_l4 = 1;
+		config.igb.ptp_type = E1000_TSYNCRXCTL_TYPE_L2_L4_V2;
+		config.igb.ptp2_id = E1000_TSYNCRXCFG_PTP_V2_DELAY_REQ_MESSAGE;
+		config.igb.etype = 0x88F7;
+		config.igb.port = htons(319); /* PTP */
 		config.rx_filter = HWTSTAMP_FILTER_SOME;
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
-		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_EVENT_V2;
+		config.igb.ptp_type = E1000_TSYNCRXCTL_TYPE_EVENT_V2;
 		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
-		is_l2 = 1;
+		config.igb.etype = 0x88F7;
 		break;
 	default:
 		return -ERANGE;
 	}
 
+manual:
 	/* enable/disable TX */
 	regval = rd32(E1000_TSYNCTXCTL);
-	regval = (regval & ~E1000_TSYNCTXCTL_ENABLED) | tsync_tx_ctl_bit;
+	if(config.flags & HWTSTAMP_TX)
+		regval = (regval | E1000_TSYNCTXCTL_ENABLED);
+	else	regval = (regval & ~E1000_TSYNCTXCTL_ENABLED);
 	wr32(E1000_TSYNCTXCTL, regval);
 
 	/* enable/disable RX, define which PTP packets are time stamped */
 	regval = rd32(E1000_TSYNCRXCTL);
-	regval = (regval & ~E1000_TSYNCRXCTL_ENABLED) | tsync_rx_ctl_bit;
-	regval = (regval & ~0xE) | tsync_rx_ctl_type;
+	if(config.flags & HWTSTAMP_RX)
+		regval = (regval | E1000_TSYNCRXCTL_ENABLED);
+	else	regval = (regval & ~E1000_TSYNCRXCTL_ENABLED);
+	regval = (regval & ~0xE) | config.igb.ptp_type << 1;
 	wr32(E1000_TSYNCRXCTL, regval);
-	wr32(E1000_TSYNCRXCFG, tsync_rx_cfg);
+
+	/* we don't need to read since we can reset the whole register. */
+	regval =  config.igb.ptp1_control
+		| config.igb.ptp2_id << 8
+		| config.igb.ptp2_val << 12;
+	wr32(E1000_TSYNCRXCFG, regval);
 
 	/*
 	 * Ethertype Filter Queue Filter[0][15:0] = 0x88F7
@@ -4979,27 +4995,32 @@ static int igb_hwtstamp_ioctl(struct net_device *netdev,
 	 * Ethertype Filter Queue Filter[0][26] = 0x1 (Enable filter)
 	 * Ethertype Filter Queue Filter[0][30] = 0x1 (Enable Timestamping)
 	 */
-	wr32(E1000_ETQF0, is_l2 ? 0x440088f7 : 0);
+	wr32(E1000_ETQF0, config.igb.etype ? 0x4400 << 16 | config.igb.etype : 0);
 
 	/* L4 Queue Filter[0]: only filter by source and destination port */
-	wr32(E1000_SPQF0, htons(port));
-	wr32(E1000_IMIREXT(0), is_l4 ?
+	/* wr32(E1000_SPQF0, port); XXX why source port? */
+	wr32(E1000_IMIREXT(0), config.igb.port ?
 	     ((1<<12) | (1<<19) /* bypass size and control flags */) : 0);
-	wr32(E1000_IMIR(0), is_l4 ?
-	     (htons(port)
+	wr32(E1000_IMIR(0), config.igb.port ?
+	     (config.igb.port
 	      | (0<<16) /* immediate interrupt disabled */
-	      | 0 /* (1<<17) bit cleared: do not bypass
+	      | (0<<17) /* (1<<17) bit cleared: do not bypass
 		     destination port check */)
 		: 0);
-	wr32(E1000_FTQF0, is_l4 ?
+	wr32(E1000_FTQF0, config.igb.port ?
 	     (0x11 /* UDP */
 	      | (1<<15) /* VF not compared */
 	      | (1<<27) /* Enable Timestamping */
+#if 0
 	      | (7<<28) /* only source port filter enabled,
 			   source/target address and protocol
-			   masked */)
-	     : ((1<<15) | (15<<28) /* all mask bits set = filter not
-				      enabled */));
+			   masked */
+#endif
+	      | (0xe<<28) /* only protocol filter enabled
+			   * everything else is masked. */
+	     )
+	     : (1<<15) | (15<<28) /* all mask bits set = filter not
+				      enabled */);
 
 	wrfl();
 
diff --git a/include/linux/net_tstamp.h b/include/linux/net_tstamp.h
index a3b8546..7b069dd 100644
--- a/include/linux/net_tstamp.h
+++ b/include/linux/net_tstamp.h
@@ -40,26 +40,43 @@ enum {
  */
 struct hwtstamp_config {
 	int flags;
-	int tx_type;
-	int rx_filter;
+	/* deprecated, only used for backwards compatibility when flags == 0 */
+	int tx_type;            /* put this into flags ? */
+	int rx_filter;          /* deprecated */
+	/* hardware dependend part starts here */
+	union {
+		struct {
+			unsigned short port;  /* for dst port filter, zero to disable */
+			unsigned short etype; /* for ethertype filter, zero to disable */
+			unsigned ptp1_control	:8; /* TSYNCRXCFG.CTRLT */
+			/* Careful! According to reference manual message ids
+			 * 2 and 3 always get timestamped. */
+			unsigned ptp2_id	:4; /* TSYNCRXCFG.MSGT */
+			unsigned ptp2_val	:4; /* TSYNCRXCFG.TRNSSPC */
+			unsigned ptp_type	:3; /* TSYNCRXCTL.Type */
+		} igb;
+	};
 };
 
-/* possible values for hwtstamp_config->tx_type */
+/* flags for hwtstamp_config */
 enum {
 	/*
-	 * No outgoing packet will need hardware time stamping;
-	 * should a packet arrive which asks for it, no hardware
-	 * time stamping will be done.
+	 * these first two values are the only allowed values in
+	 * deprecated hwtstamp_config->tx_type
 	 */
-	HWTSTAMP_TX_OFF,
-
 	/*
 	 * Enables hardware time stamping for outgoing packets;
 	 * the sender of the packet decides which are to be
 	 * time stamped by setting %SOF_TIMESTAMPING_TX_SOFTWARE
 	 * before sending the packet.
+	 * If disabled no packet will be timestamped; even if it
+	 * asks for it.
 	 */
-	HWTSTAMP_TX_ON,
+	HWTSTAMP_TX_OFF = 0, /* only used in hwtstamp_config->tx_type */
+	HWTSTAMP_TX_ON = 1,
+	HWTSTAMP_TX = 1,
+
+	HWTSTAMP_RX = 2
 };
 
 /* possible values for hwtstamp_config->rx_filter */
-- 
1.6.3.3


--MP_/E1KVNW40E31ptkQ=4vtartP--
