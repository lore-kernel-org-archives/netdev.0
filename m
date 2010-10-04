From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may cap
	num_rx_queues at init time
Date: Mon, 04 Oct 2010 15:00:42 -0700
Message-ID: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, therbert@google.com
To: bhutchings@solarflare.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20578 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751975Ab0JDWBq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 18:01:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The logic for netif_set_real_num_rx_queues is the following,

netif_set_real_num_rx_queues(dev, rxq)
{
	...
	if (dev->reg_state == NETREG_REGISTERED) {
		...
	} else {
		dev->num_rx_queues = rxq;
	}

	dev->real_num_rx_queues = rxq;
	return 0;
}

Some drivers init path looks like the following,

alloc_etherdev_mq(priv_sz, max_num_queues_ever);
...
netif_set_real_num_rx_queues(dev, queues_to_use_now);
...
register_netdev(dev);
...

Because netif_set_real_num_rx_queues sets num_rx_queues if the
reg state is not NETREG_REGISTERED we end up with the incorrect
max number of rx queues. This patch proposes to remove the else
clause above so this does not occur.  Also just reading the
function set_real_num it seems a bit unexpected that num_rx_queues
gets set.

CC: Ben Hutchings <bhutchings@solarflare.com>

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/dev.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a313bab..f78d996 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1592,8 +1592,6 @@ int netif_set_real_num_rx_queues(struct net_device *dev, unsigned int rxq)
 						  rxq);
 		if (rc)
 			return rc;
-	} else {
-		dev->num_rx_queues = rxq;
 	}
 
 	dev->real_num_rx_queues = rxq;

