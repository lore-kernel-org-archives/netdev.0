From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [PATCH net-next] virtio_net: do not rate limit counter increments
Date: Tue, 27 Mar 2012 10:28:09 -0700 (PDT)
Message-ID: <20120327172809.C52572900384@tardy>
Reply-To: Rick Jones <rick.jones2@hp.com>
Cc: <rusty@rustcorp.com.au>, <mst@redhat.com>,
	<virtualization@lists.linux-foundation.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:26285 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978Ab2C0R2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 13:28:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

While it is desirable to rate limit certain messages, it is not
desirable to rate limit the incrementing of counters associated
with those messages.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compiled, and run briefly in a 1 vCPU guest under a netperf workload.


diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 019da01..4de2760 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -625,12 +625,13 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* This can happen with OOM and indirect buffers. */
 	if (unlikely(capacity < 0)) {
-		if (net_ratelimit()) {
-			if (likely(capacity == -ENOMEM)) {
+		if (likely(capacity == -ENOMEM)) {
+			if (net_ratelimit()) {
 				dev_warn(&dev->dev,
 					 "TX queue failure: out of memory\n");
 			} else {
-				dev->stats.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
+			if (net_ratelimit())
 				dev_warn(&dev->dev,
 					 "Unexpected TX queue failure: %d\n",
 					 capacity);
