From: timg@tpi.com (Tim Gardner)
Subject: 2.6.25-rc2 pull request, stop log noise from CONFIG_RPS
Date: Wed,  9 Jun 2010 13:51:09 -0600 (MDT)
Message-ID: <20100609195110.02FEAF89E9@sepang.rtg.net>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:2938 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758218Ab0FITvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 15:51:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please consider applying this patch in order to stop
log noise under certain configurations.

rtg
---------------
The following changes since commit 327723edebbbd621ed35b0d63073685eb225563e:
  David S. Miller (1):
        Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

are available in the git repository at:

  git://kernel.ubuntu.com/rtg/net-2.6 num_rx_queues

Tim Gardner (1):
      net: Print num_rx_queues imbalance warning only when there are allocated queues

 net/core/dev.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)
>From 08c801f8d45387a1b46066aad1789a9bb9c4b645 Mon Sep 17 00:00:00 2001
From: Tim Gardner <tim.gardner@canonical.com>
Date: Tue, 8 Jun 2010 17:51:27 -0600
Subject: [PATCH] net: Print num_rx_queues imbalance warning only when there are allocated queues

BugLink: http://bugs.launchpad.net/bugs/591416

There are a number of network drivers (bridge, bonding, etc) that are not yet
receive multi-queue enabled and use alloc_netdev(), so don't print a
num_rx_queues imbalance warning in that case.

Also, only print the warning once for those drivers that _are_ multi-queue
enabled.

Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d03470f..14a8568 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2253,11 +2253,9 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index = skb_get_rx_queue(skb);
 		if (unlikely(index >= dev->num_rx_queues)) {
-			if (net_ratelimit()) {
-				pr_warning("%s received packet on queue "
-					"%u, but number of RX queues is %u\n",
-					dev->name, index, dev->num_rx_queues);
-			}
+			WARN_ONCE(dev->num_rx_queues > 1, "%s received packet "
+				"on queue %u, but number of RX queues is %u\n",
+				dev->name, index, dev->num_rx_queues);
 			goto done;
 		}
 		rxqueue = dev->_rx + index;
-- 
1.7.0.4

