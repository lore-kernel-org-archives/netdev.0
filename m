From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 1/10 REV5] [Doc] HOWTO Documentation for batching
Date: Fri, 14 Sep 2007 14:31:18 +0530
Message-ID: <20070914090118.17589.43799.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	xma@us.ibm.com, gaagaan@gmail.com, netdev@vger.kernel.org,
	rdreier@cisco.com, rick.jones2@hp.com, mcarlson@broadcom.com,
	jeff@garzik.org, general@lists.openfabrics.org, mchan@broadcom.com,
	tgraf@suug.ch, randy.dunlap@oracle.com,
	Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:36175 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751385AbXINI7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 04:59:18 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8E8xIn7009673
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 04:59:18 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8E8xH3s546580
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 04:59:17 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8E8xE3b021600
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 04:59:17 -0400
In-Reply-To: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add Documentation describing batching skb xmit capability.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 batching_skb_xmit.txt |  107 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 107 insertions(+)

diff -ruNp org/Documentation/networking/batching_skb_xmit.txt new/Documentation/networking/batching_skb_xmit.txt
--- org/Documentation/networking/batching_skb_xmit.txt	1970-01-01 05:30:00.000000000 +0530
+++ new/Documentation/networking/batching_skb_xmit.txt	2007-09-14 10:25:36.000000000 +0530
@@ -0,0 +1,107 @@
+		 HOWTO for batching skb xmit support
+		 -----------------------------------
+
+Section 1: What is batching skb xmit
+Section 2: How batching xmit works vs the regular xmit
+Section 3: How drivers can support batching
+Section 4: Nitty gritty details for drivers
+Section 5: How users can work with batching
+
+
+Introduction: Kernel support for batching skb
+----------------------------------------------
+
+A new capability to support xmit of multiple skbs is provided in the netdevice
+layer. Drivers which enable this capability should be able to process multiple
+skbs in a single call to their xmit handler.
+
+
+Section 1: What is batching skb xmit
+-------------------------------------
+
+	This capability is optionally enabled by a driver by setting the
+	NETIF_F_BATCH_SKBS bit in dev->features. The prerequisite for a
+	driver to use this capability is that it should have a reasonably-
+	sized hardware queue that can process multiple skbs.
+
+
+Section 2: How batching xmit works vs the regular xmit
+-------------------------------------------------------
+
+	The network stack gets called from upper layer protocols with a single
+	skb to transmit. This skb is first enqueued and an attempt is made to
+	transmit it immediately (via qdisc_run). However, events like tx lock
+	contention, tx queue stopped, etc., can result in the skb not getting
+	sent out and it remains in the queue. When the next xmit is called or
+	when the queue is re-enabled, qdisc_run could potentially find
+	multiple packets in the queue, and iteratively send them all out
+	one-by-one.
+
+	Batching skb xmit is a mechanism to exploit this situation where all
+	skbs can be passed in one shot to the device. This reduces driver
+	processing, locking at the driver (or in stack for ~LLTX drivers)
+	gets amortized over multiple skbs, and in case of specific drivers
+	where every xmit results in a completion processing (like IPoIB) -
+	optimizations can be made in the driver to request a completion for
+	only the last skb that was sent which results in saving interrupts
+	for every (but the last) skb that was sent in the same batch.
+
+	Batching can result in significant performance gains for systems that
+	have multiple data stream paths over the same network interface card.
+
+
+Section 3: How drivers can support batching
+---------------------------------------------
+
+	Batching requires the driver to set the NETIF_F_BATCH_SKBS bit in
+	dev->features.
+
+	The driver's xmit handler should be modified to process multiple skbs
+	instead of one skb. The driver's xmit handler is called either with
+	an skb to transmit or NULL skb, where the latter case should be
+	handled as a call to xmit multiple skbs. This is done by sending out
+	all skbs in the dev->skb_blist list (where it was added by the core
+	stack).
+
+
+Section 4: Nitty gritty details for driver writers
+--------------------------------------------------
+
+	Batching is enabled from core networking stack only from softirq
+	context (NET_TX_SOFTIRQ), and dev_queue_xmit() doesn't use batching.
+
+	This leads to the following situation:
+		A skb was not sent out as either driver lock was contested or
+		the device was blocked. When the softirq handler runs, it
+		moves all skbs from the device queue to the batch list, but
+		then it too could fail to send due to lock contention. The
+		next xmit (of a single skb) called from dev_queue_xmit() will
+		not use batching and try to xmit skb, while previous skbs are
+		still present in the batch list. This results in the receiver
+		getting out-of-order packets, and in case of TCP the sender
+		would have unnecessary retransmissions.
+
+	To fix this problem, error cases where driver xmit gets called with a
+	skb must code as follows:
+		1. If driver xmit cannot get tx lock, return NETDEV_TX_LOCKED
+		   as usual. This allows qdisc to requeue the skb.
+		2. If driver xmit got the lock but failed to send the skb, it
+		   should return NETDEV_TX_BUSY but before that it should have
+		   queue'd the skb to the batch list. In this case, the qdisc
+		   does not requeue the skb.
+
+
+Section 5: How users can work with batching
+--------------------------------------------
+
+	Batching can be disabled for a particular device, e.g. on desktop
+	systems if only one stream of network activity for that device is
+	taking place, since performance could be slightly affected due to
+	extra processing that batching adds (unless packets are getting
+	sent fast resulting in queue getting stopped). Batching can be enabled
+	if more than one stream of network activity per device is being done,
+	e.g. on servers; or even desktop usage with multiple browser, chat,
+	file transfer sessions, etc.
+
+	Per device batching can be enabled/disabled by:
+		ethtool <dev> batching on/off
