From: Patrick Loschmidt <Patrick.Loschmidt@OEAW.ac.at>
Subject: [PATCH] corrected documentation for hardware time stamping
Date: Wed, 07 Apr 2010 13:15:16 +0200
Message-ID: <4BBC6944.2090102@OEAW.ac.at>
Reply-To: loschmidt@fiss-oeaw.at
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick Ohly <patrick.ohly@gmx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from post.fiss-oeaw.at ([83.64.124.243]:37381 "EHLO
	hermes.fiss-oeaw.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752191Ab0DGLtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 07:49:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Loschmidt <Patrick.Loschmidt@oeaw.ac.at>

The current documentation for hardware time stamping does not correctly specify the available kernel
functions since the implementation was changed later on.

Signed-off-by: Patrick Loschmidt <Patrick.Loschmidt@oeaw.ac.at>
---
--- Documentation/networking/timestamping.txt.orig	2010-04-07 12:52:47.000000000 +0200
+++ Documentation/networking/timestamping.txt	2010-04-07 11:43:57.000000000 +0200
@@ -41,11 +41,12 @@ SOF_TIMESTAMPING_SOFTWARE:     return sy
 SOF_TIMESTAMPING_TX/RX determine how time stamps are generated.
 SOF_TIMESTAMPING_RAW/SYS determine how they are reported in the
 following control message:
-    struct scm_timestamping {
-           struct timespec systime;
-           struct timespec hwtimetrans;
-           struct timespec hwtimeraw;
-    };
+
+struct scm_timestamping {
+	struct timespec systime;
+	struct timespec hwtimetrans;
+	struct timespec hwtimeraw;
+};

 recvmsg() can be used to get this control message for regular incoming
 packets. For send time stamps the outgoing packet is looped back to
@@ -87,12 +88,13 @@ by the network device and will be empty
 SIOCSHWTSTAMP:

 Hardware time stamping must also be initialized for each device driver
-that is expected to do hardware time stamping. The parameter is:
+that is expected to do hardware time stamping. The parameter is defined in
+/include/linux/net_tstamp.h as:

 struct hwtstamp_config {
-    int flags;           /* no flags defined right now, must be zero */
-    int tx_type;         /* HWTSTAMP_TX_* */
-    int rx_filter;       /* HWTSTAMP_FILTER_* */
+	int flags;	/* no flags defined right now, must be zero */
+	int tx_type;	/* HWTSTAMP_TX_* */
+	int rx_filter;	/* HWTSTAMP_FILTER_* */
 };

 Desired behavior is passed into the kernel and to a specific device by
@@ -139,42 +141,56 @@ enum {
 	/* time stamp any incoming packet */
 	HWTSTAMP_FILTER_ALL,

-        /* return value: time stamp all packets requested plus some others */
-        HWTSTAMP_FILTER_SOME,
+	/* return value: time stamp all packets requested plus some others */
+	HWTSTAMP_FILTER_SOME,

 	/* PTP v1, UDP, any kind of event packet */
 	HWTSTAMP_FILTER_PTP_V1_L4_EVENT,
-
-        ...
+	
+	/* for the complete list of values, please check
+	 * the include file /include/linux/net_tstamp.h
+	 */
 };


 DEVICE IMPLEMENTATION

 A driver which supports hardware time stamping must support the
-SIOCSHWTSTAMP ioctl. Time stamps for received packets must be stored
-in the skb with skb_hwtstamp_set().
+SIOCSHWTSTAMP ioctl and update the supplied struct hwtstamp_config with
+the actual values as described in the section on SIOCSHWTSTAMP.
+
+Time stamps for received packets must be stored in the skb. To get a pointer
+to the shared time stamp structure of the skb call skb_hwtstamps(). Then
+set the time stamps in the structure:
+
+struct skb_shared_hwtstamps {
+	/* hardware time stamp transformed into duration
+	 * since arbitrary point in time
+	 */
+	ktime_t	hwtstamp;
+	ktime_t	syststamp; /* hwtstamp transformed to system time base */
+};

 Time stamps for outgoing packets are to be generated as follows:
-- In hard_start_xmit(), check if skb_hwtstamp_check_tx_hardware()
-  returns non-zero. If yes, then the driver is expected
-  to do hardware time stamping.
+- In hard_start_xmit(), check if skb_tx(skb)->hardware is set no-zero.
+  If yes, then the driver is expected to do hardware time stamping.
 - If this is possible for the skb and requested, then declare
-  that the driver is doing the time stamping by calling
-  skb_hwtstamp_tx_in_progress(). A driver not supporting
-  hardware time stamping doesn't do that. A driver must never
-  touch sk_buff::tstamp! It is used to store how time stamping
-  for an outgoing packets is to be done.
+  that the driver is doing the time stamping by setting the field
+  skb_tx(skb)->in_progress non-zero. You might want to keep a pointer
+  to the associated skb for the next step and not free the skb. A driver
+  not supporting hardware time stamping doesn't do that. A driver must
+  never touch sk_buff::tstamp! It is used to store software generated
+  time stamps by the network subsystem.
 - As soon as the driver has sent the packet and/or obtained a
   hardware time stamp for it, it passes the time stamp back by
   calling skb_hwtstamp_tx() with the original skb, the raw
-  hardware time stamp and a handle to the device (necessary
-  to convert the hardware time stamp to system time). If obtaining
-  the hardware time stamp somehow fails, then the driver should
-  not fall back to software time stamping. The rationale is that
-  this would occur at a later time in the processing pipeline
-  than other software time stamping and therefore could lead
-  to unexpected deltas between time stamps.
-- If the driver did not call skb_hwtstamp_tx_in_progress(), then
+  hardware time stamp. skb_hwtstamp_tx() clones the original skb and
+  adds the timestamps, therefore the original skb has to be freed now.
+  If obtaining the hardware time stamp somehow fails, then the driver
+  should not fall back to software time stamping. The rationale is that
+  this would occur at a later time in the processing pipeline than other
+  software time stamping and therefore could lead to unexpected deltas
+  between time stamps.
+- If the driver did not call set skb_tx(skb)->in_progress, then
   dev_hard_start_xmit() checks whether software time stamping
   is wanted as fallback and potentially generates the time stamp.
