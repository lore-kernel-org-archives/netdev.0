From: Phil Sutter <phil@nwl.cc>
Subject: [net PATCH] IFF_NO_QUEUE: Fix for drivers not calling ether_setup()
Date: Wed, 17 Feb 2016 15:37:43 +0100
Message-ID: <1455719863-25730-1-git-send-email-phil@nwl.cc>
References: <1027362736.325.1455717462229.JavaMail.zimbra@efficios.com>
Cc: mathieu.desnoyers@efficios.com, linux-kernel@vger.kernel.org,
	jhs@mojatatu.com, netdev@vger.kernel.org, stable@vger.kernel.org
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1027362736.325.1455717462229.JavaMail.zimbra@efficios.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My implementation around IFF_NO_QUEUE driver flag assumed that leaving
tx_queue_len untouched (specifically: not setting it to zero) by drivers
would make it possible to assign a regular qdisc to them without having
to worry about setting tx_queue_len to a useful value. This was only
partially true: I overlooked that some drivers don't call ether_setup()
and therefore not initialize tx_queue_len to the default value of 1000.
Consequently, removing the workarounds in place for that case in qdisc
implementations which cared about it (namely, pfifo, bfifo, gred, htb,
plug and sfb) leads to problems with these specific interface types and
qdiscs.

Luckily, there's already a sanitization point for drivers setting
tx_queue_len to zero, which can be reused to assign the fallback value
most qdisc implementations used, which is 1.

Fixes: 348e3435cbefa ("net: sched: drop all special handling of tx_queue_len == 0")
Tested-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/core/dev.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3f4071a84a03f..75383f40e7ced 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7440,8 +7440,10 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	dev->priv_flags = IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM;
 	setup(dev);
 
-	if (!dev->tx_queue_len)
+	if (!dev->tx_queue_len) {
 		dev->priv_flags |= IFF_NO_QUEUE;
+		dev->tx_queue_len = 1;
+	}
 
 	dev->num_tx_queues = txqs;
 	dev->real_num_tx_queues = txqs;
-- 
2.7.0
