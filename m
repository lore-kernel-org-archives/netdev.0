From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: graceful exit from netif_alloc_netdev_queues()
Date: Mon, 06 Jul 2015 17:13:26 +0200
Message-ID: <1436195606.4571.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:34880 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbbGFPNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:13:30 -0400
Received: by wgjx7 with SMTP id x7so143055249wgj.2
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 08:13:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

User space can crash kernel with

ip link add ifb10 numtxqueues 100000 type ifb

We must replace a BUG_ON() by proper test and return -EINVAL for
crazy values.

Fixes: 60877a32bce00 ("net: allow large number of tx queues")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6778a9999d52..0ad626214332 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6409,7 +6409,8 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 	struct netdev_queue *tx;
 	size_t sz = count * sizeof(*tx);
 
-	BUG_ON(count < 1 || count > 0xffff);
+	if (count < 1 || count > 0xffff)
+		return -EINVAL;
 
 	tx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
 	if (!tx) {
