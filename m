From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 1/9 Rev3] [Doc] HOWTO Documentation for batching
Date: Wed, 08 Aug 2007 15:01:24 +0530
Message-ID: <20070808093124.15396.69224.sendpatchset@localhost.localdomain>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	rick.jones2@hp.com, mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	hadi@cyberus.ca, netdev@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>, xma@us.ibm.com
To: johnpol@2ka.mipt.ru, kaber@trash.net,
	shemminger@linux-foundation.org, davem@davemloft.net,
	sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:54827 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755175AbXHHJab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 05:30:31 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l789WPb0581754
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 19:32:26 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l789XowH134318
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 19:33:51 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l789UE1a001894
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 19:30:17 +1000
In-Reply-To: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add Documentation describing batching API.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 Batching_skb_API.txt |   82 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 82 insertions(+)

diff -ruNp ORG/Documentation/networking/Batching_skb_API.txt NEW/Documentation/networking/Batching_skb_API.txt
--- ORG/Documentation/networking/Batching_skb_API.txt	1970-01-01 05:30:00.000000000 +0530
+++ NEW/Documentation/networking/Batching_skb_API.txt	2007-08-07 22:41:55.000000000 +0530
@@ -0,0 +1,82 @@
+		 HOWTO for batching skb API support
+		 -----------------------------------
+
+Section 1: What is batching skb API ?
+Section 2: How batching API works vs the original API ?
+Section 3: How drivers can support this API ?
+Section 4: How users can work with this API ?
+
+
+Introduction: Kernel support for batching skb
+----------------------------------------------
+
+A new xmit API - hard_start_xmit_batch() is provided in the netdevice layer
+similar to the existing hard_start_xmit() API. Drivers which export this
+API can implement it similar to the hard_start_xmit handler. The new API
+should process multiple skbs (or even one) in a single call while the
+existing hard_start_xmit processes one skb. It is possible for the driver
+writer to re-use most of the code from the existing API in the new API
+without having code duplication.
+
+
+Section 1: What is batching skb API ?
+-------------------------------------
+
+	This API is optionally exported by a driver. The pre-requisite for a
+	driver to use this API is that it should have a reasonably sized
+	hardware queue that can process multiple skbs.
+
+
+Section 2: How batching API works vs the original API ?
+-------------------------------------------------------
+
+	The networking stack gets called from upper layer protocols with a
+	single skb to transmit. This skb is first enqueue'd and an attempt is
+	made to transmit it immediately (via qdisc_run). However, events like
+	tx lock contention, tx queue stopped, etc, can result in the skb not
+	getting sent out and it remains in the queue. When the next xmit is
+	called or when the queue is re-enabled, qdisc_run could potentially
+	find multiple packets in the queue, and iteratively send them all out
+	one-by-one.
+
+	The batching skb API was added to exploit this situation where all
+	skbs can be passed in one shot to the device. This reduces driver
+	processing, locking at the driver (or in stack for ~LLTX drivers)
+	gets amortized over multiple skbs, and in case of specific drivers
+	where every xmit results in a completion processing (like IPoIB),
+	optimizations can be made in the driver to request a completion for
+	only the last skb that was sent which results in saving interrupts
+	for every (but the last) skb that was sent in the same batch.
+
+	Batching can result in significant performance gains for systems that
+	have multiple data stream paths over the same network interface card.
+
+
+Section 3: How drivers can support this API ?
+---------------------------------------------
+
+	The new API - dev->hard_start_xmit_batch(struct net_device *dev),
+	simplistically, can be written almost identically to the regular
+	xmit API except that multiple skbs should be processed by the driver
+	instead of one skb. The new API doesn't get a skb as an argument,
+	instead it picks up all the skbs from dev->skb_blist, where it was
+	added by the core stack, and tries to send them out.
+
+	Batching requires the driver to set dev->hard_start_xmit_batch to the
+	new API implemented for that driver.
+
+
+Section 4: How users can work with this API ?
+---------------------------------------------
+
+	Batching could be disabled for a particular device, e.g. on desktop
+	systems if only one stream of network activity for that device is
+	taking place, since performance could be slightly affected due to
+	extra processing that batching adds (unless packets are getting
+	sent fast resulting in stopped queue's). Batching can be enabled if
+	more than one stream of network activity per device is being done,
+	e.g. on servers; or even desktop usage with multiple browser, chat,
+	file transfer sessions, etc.
+
+	Per device batching can be enabled/disabled using ethtool, where
+	passing 1 enables batching and passing 0 disables batching.
