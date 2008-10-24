From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 04/13] net: implement generic SOF_TIMESTAMPING_TX_*
	support
Date: Fri, 24 Oct 2008 15:41:34 +0200
Message-ID: <1226415417.31699.3.camel@ecld0pohly>
References: <1226414697.17450.852.camel@ecld0pohly>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30737 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756043AbYKKO47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 09:56:59 -0500
In-Reply-To: <1226414697.17450.852.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We make use of the upper bits in the skb->tstamp to transport the
senders time stamping settings into the lower levels. Currently these
are per-socket settings, but a per-packet control message could also
be added.

When a TX timestamp operation is requested, the TX skb will be cloned
and the clone will be time stamped (in hardware or software) and added
to the socket error queue of the skb, if the skb has a socket
associated.

The actual timestamp will reach userspace as a RX timestamp on the
cloned packet. If timestamping is requested and no timestamping is
done in the device driver (potentially this may use hardware
timestamping), it will be done in software after the device's
start_hard_xmit routine.

The new semantic for hardware/software time stamping around
net_device->hard_start_xmit() is based on two assumptions about
existing network device drivers which don't support hardware
time stamping and know nothing about it:
- they leave the skb->tstamp field unmodified
- the keep the connection to the originating socket in skb->sk
  alive, i.e., don't call skb_orphan()

The first assumption seems to hold for in-tree drivers. The second
is only true for some drivers. As a result, software TX time stamping
currently works with the bnx2 driver, but not with the unmodified
igb driver (the two drivers this patch was tested with).

Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>
---
 Documentation/networking/timestamping.txt |   31 +++++++++++++++++
 include/linux/netdevice.h                 |   10 ++++++
 include/linux/skbuff.h                    |   51 +++++++++++++++++++++++++++++
 include/net/sock.h                        |   14 ++++++++
 net/core/dev.c                            |   34 +++++++++++++++++--
 net/core/skbuff.c                         |   36 ++++++++++++++++++++
 net/socket.c                              |   15 ++++++++
 7 files changed, 188 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index 10ecb1d..6a87a96 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -145,3 +145,34 @@ The original hardware time stamp can only be returned after
 transforming it back, which might not be supported by the driver which
 generated the packet. In that case hwtimetrans is set, but hwtimeraw
 is not.
+
+
+DEVICE IMPLEMENTATION
+
+A driver which supports hardware time stamping must support the
+SIOCSHWTSTAMP ioctl. Time stamps for received packets must be stored
+in the skb with skb_hwtstamp_set().
+
+Time stamps for outgoing packets are to be generated as follows:
+- In hard_start_xmit(), check if skb_hwtstamp_check_tx_hardware()
+  returns non-zero. If yes, then the driver is expected
+  to do hardware time stamping.
+- If this is possible for the skb and requested, then declare
+  that the driver is doing the time stamping by calling
+  skb_hwtstamp_tx_in_progress(). A driver not supporting
+  hardware time stamping doesn't do that. A driver must never
+  touch sk_buff::tstamp! It is used to store how time stamping
+  for an outgoing packets is to be done.
+- As soon as the driver has sent the packet and/or obtained a
+  hardware time stamp for it, it passes the time stamp back by
+  calling skb_hwtstamp_tx() with the original skb, the raw
+  hardware time stamp and a handle to the device (necessary
+  to convert the hardware time stamp to system time). If obtaining
+  the hardware time stamp somehow fails, then the driver should
+  not fall back to software time stamping. The rationale is that
+  this would occur at a later time in the processing pipeline
+  than other software time stamping and therefore could lead
+  to unexpected deltas between time stamps.
+- If the driver did not call skb_hwtstamp_tx_in_progress(), then
+  dev_hard_start_xmit() checks whether software time stamping
+  is wanted as fallback and potentially generates the time stamp.
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 79221a1..89f4025 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -752,6 +752,16 @@ struct net_device
 
 	/* hardware time stamping support */
 #define HAVE_HW_TIME_STAMP
+	/* Transforms original raw hardware time stamp to
+	 * system time base. Always required when supporting
+	 * hardware time stamping.
+	 *
+	 * Returns empty stamp (= all zero) if conversion wasn't
+	 * possible.
+	 */
+	union ktime             (*hwtstamp_raw2sys)(struct net_device *dev,
+						union ktime stamp);
+
 	/* Transforms time stamp back from system time base
 	 * to the original, raw hardware time stamp. This call
 	 * is necessary only when scm_timestamping::hwtimeraw
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b8818dc..bcca8fc 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1625,6 +1625,57 @@ int skb_hwtstamp_raw(const struct sk_buff *skb, struct timespec *stamp);
  */
 int skb_hwtstamp_transformed(const struct sk_buff *skb, struct timespec *stamp);
 
+/*
+ * Timestamps for outgoing skbs have special meaning:
+ * - request TX timestamping in hardware
+ * - request for TX hardware time stamp is processed by hardware
+ * - request TX timestamping in software as fallback
+ */
+#define SKB_TSTAMP_TX_HARDWARE                    (1LL << 62)
+#define SKB_TSTAMP_TX_HARDWARE_IN_PROGRESS        (1LL << 61)
+#define SKB_TSTAMP_TX_SOFTWARE                    (1LL << 60)
+
+static inline int skb_hwtstamp_check_tx_hardware(struct sk_buff *skb)
+{
+	return (skb->tstamp.tv64 & SKB_TSTAMP_TX_HARDWARE) ? 1 : 0;
+}
+
+static inline void skb_hwtstamp_tx_in_progress(struct sk_buff *skb)
+{
+	skb->tstamp.tv64 |= SKB_TSTAMP_TX_HARDWARE_IN_PROGRESS;
+}
+static inline int skb_hwtstamp_check_tx_software(struct sk_buff *skb)
+{
+	return (skb->tstamp.tv64 & SKB_TSTAMP_TX_SOFTWARE) ? 1 : 0;
+}
+
+/**
+ * skb_hwtstamp_tx - queue clone of skb with send time stamp
+ * @orig_skb: the original outgoing packet
+ * @stamp: either raw hardware time stamp or result of ktime_get_real()
+ * @dev: NULL if time stamp from ktime_get_real(), otherwise device
+ *       which generated the hardware time stamp; the device may or
+ *        may not implement
+ *
+ * This function will not actually timestamp the skb, but, if the skb has a
+ * socket associated, clone the skb, timestamp it, and queue it to the error
+ * queue of the socket. Errors are silently ignored.
+ */
+void skb_hwtstamp_tx(struct sk_buff *orig_skb,
+		union ktime stamp,
+		struct net_device *dev);
+
+/**
+ * skb_tx_software_timestamp - software fallback for send time stamping
+ */
+static inline void skb_tx_software_timestamp(struct sk_buff *skb)
+{
+	if ((skb->tstamp.tv64 & SKB_TSTAMP_TX_SOFTWARE) &&
+		!(skb->tstamp.tv64 & SKB_TSTAMP_TX_HARDWARE_IN_PROGRESS)) {
+		skb_hwtstamp_tx(skb, ktime_get_real(), NULL);
+	}
+}
+
 extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 739a8e8..98af0a4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1283,6 +1283,20 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 }
 
 /**
+ * sock_tx_timestamp - checks whether the outgoing packet is to be time stamped
+ * @msg: outgoing packet
+ * @sk: socket sending this packet
+ * @tstamp: set to combination of SKB_TSTAMP_TX_* flags by this function
+ *
+ * Currently only depends on SOCK_TIMESTAMPING* flags. Returns error code if
+ * parameters are invalid.
+ */
+extern int sock_tx_timestamp(struct msghdr *msg,
+			struct sock *sk,
+			union ktime *tstamp);
+
+
+/**
  * sk_eat_skb - Release a skb if it is no longer needed
  * @sk: socket to eat this skb from
  * @skb: socket buffer to eat
diff --git a/net/core/dev.c b/net/core/dev.c
index 0ae08d3..7cf31fb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1623,9 +1623,20 @@ static int dev_gso_segment(struct sk_buff *skb)
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
+	int rc;
+	union ktime tstamp = skb->tstamp;
+
 	if (likely(!skb->next)) {
-		if (!list_empty(&ptype_all))
+		if (!list_empty(&ptype_all)) {
+			/*
+			 * dev_queue_xmit_nit() sets skb->tstamp if
+			 * net time stamping is on: when calling
+			 * dev->hard_start_xmit() we need the original
+			 * SKB_TSTAMP_* flags there, so restore it
+			 */
 			dev_queue_xmit_nit(skb, dev);
+			skb->tstamp = tstamp;
+		}
 
 		if (netif_needs_gso(dev, skb)) {
 			if (unlikely(dev_gso_segment(skb)))
@@ -1634,13 +1645,29 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				goto gso;
 		}
 
-		return dev->hard_start_xmit(skb, dev);
+		rc = dev->hard_start_xmit(skb, dev);
+		/*
+		 * TODO: if skb_orphan() was called by
+		 * dev->hard_start_xmit() (for example, the unmodified
+		 * igb driver does that; bnx2 doesn't), then
+		 * skb_tx_software_timestamp() will be unable to send
+		 * back the time stamp.
+		 *
+		 * How can this be prevented? Always create another
+		 * reference to the socket before calling
+		 * dev->hard_start_xmit()? Prevent that skb_orphan()
+		 * does anything in dev->hard_start_xmit() by clearing
+		 * the skb destructor before the call and restoring it
+		 * afterwards, then doing the skb_orphan() ourselves?
+		 */
+		if (likely(!rc))
+			skb_tx_software_timestamp(skb);
+		return rc;
 	}
 
 gso:
 	do {
 		struct sk_buff *nskb = skb->next;
-		int rc;
 
 		skb->next = nskb->next;
 		nskb->next = NULL;
@@ -1650,6 +1677,7 @@ gso:
 			skb->next = nskb;
 			return rc;
 		}
+		skb_tx_software_timestamp(skb);
 		if (unlikely(netif_tx_queue_stopped(txq) && skb->next))
 			return NETDEV_TX_BUSY;
 	} while (skb->next);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3663b62..7d714b8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2566,6 +2566,42 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 	return elt;
 }
 
+void skb_hwtstamp_tx(struct sk_buff *orig_skb,
+		union ktime stamp,
+		struct net_device *dev)
+{
+	struct sock *sk = orig_skb->sk;
+	struct sk_buff *skb;
+	int err = -ENOMEM;
+
+	if (!sk)
+		return;
+
+	skb = skb_clone(orig_skb, GFP_ATOMIC);
+	if (!skb)
+		return;
+
+	if (dev) {
+		skb_hwtstamp_set(skb,
+				dev->hwtstamp_raw2sys ?
+				dev->hwtstamp_raw2sys(dev, stamp) :
+				stamp);
+	} else {
+		skb->tstamp = stamp;
+#if BITS_PER_LONG != 64 && !defined(CONFIG_KTIME_SCALAR)
+		skb->tstamp.tv.sec = skb->tstamp.tv.sec / 2 * 2;
+#else
+		skb->tstamp.tv64 = skb->tstamp.tv64 / 2 * 2;
+#endif
+	}
+
+	err = sock_queue_err_skb(sk, skb);
+	if (err)
+		kfree_skb(skb);
+}
+EXPORT_SYMBOL_GPL(skb_hwtstamp_tx);
+
+
 /**
  * skb_partial_csum_set - set up and verify partial csum values for packet
  * @skb: the skb to set
diff --git a/net/socket.c b/net/socket.c
index 6fb6b40..ea4b128 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -546,6 +546,21 @@ void sock_release(struct socket *sock)
 	sock->file = NULL;
 }
 
+int sock_tx_timestamp(struct msghdr *msg, struct sock *sk, ktime_t *tstamp)
+{
+	if (!sk) {
+		tstamp->tv64 = 0;
+	} else {
+		tstamp->tv64 =
+			(sock_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE) ?
+				SKB_TSTAMP_TX_HARDWARE : 0) |
+			(sock_flag(sk, SOCK_TIMESTAMPING_TX_SOFTWARE) ?
+				SKB_TSTAMP_TX_SOFTWARE : 0);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(sock_tx_timestamp);
+
 static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 				 struct msghdr *msg, size_t size)
 {
-- 
1.6.0.4


