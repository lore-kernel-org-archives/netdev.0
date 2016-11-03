From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 2/3] net/qdisc: IFF_NO_QUEUE drivers should use
 consistent TX queue len
Date: Thu, 03 Nov 2016 14:56:06 +0100
Message-ID: <20161103135606.28737.67383.stgit@firesoul>
References: <20161103135534.28737.37657.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, Robert Olsson <robert@herjulf.se>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38434 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755687AbcKCN4I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 09:56:08 -0400
In-Reply-To: <20161103135534.28737.37657.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The flag IFF_NO_QUEUE marks virtual device drivers that doesn't need a
default qdisc attached, given they will be backed by physical device,
that already have a qdisc attached for pushback.

It is still supported to attach a qdisc to a IFF_NO_QUEUE device, as
this can be useful for difference policy reasons (e.g. bandwidth
limiting containers).  For this to work, the tx_queue_len need to have
a sane value, because some qdiscs inherit/copy the tx_queue_len
(namely, pfifo, bfifo, gred, htb, plug and sfb).

Commit a813104d9233 ("IFF_NO_QUEUE: Fix for drivers not calling
ether_setup()") caught situations where some drivers didn't initialize
tx_queue_len.  The problem with the commit was choosing 1 as the
fallback value.

A qdisc queue length of 1 causes more harm than good, because it
creates hard to debug situations for userspace. It gives userspace a
false sense of a working config after attaching a qdisc.  As low
volume traffic (that doesn't activate the qdisc policy) works,
like ping, while traffic that e.g. needs shaping cannot reach the
configured policy levels, given the queue length is too small.

This patch change the value to DEFAULT_TX_QUEUE_LEN, given other
IFF_NO_QUEUE devices (that call ether_setup()) also use this value.

Fixes: a813104d9233 ("IFF_NO_QUEUE: Fix for drivers not calling ether_setup()")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f23e28668f32..0260ad314506 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7651,7 +7651,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 
 	if (!dev->tx_queue_len) {
 		dev->priv_flags |= IFF_NO_QUEUE;
-		dev->tx_queue_len = 1;
+		dev->tx_queue_len = DEFAULT_TX_QUEUE_LEN;
 	}
 
 	dev->num_tx_queues = txqs;
