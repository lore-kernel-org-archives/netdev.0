From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/5] net: Adjust TX queue kobjects if number
 of queues changes during unregister
Date: Tue, 15 Feb 2011 20:14:21 +0000
Message-ID: <1297800861.2584.17.camel@bwh-desktop>
References: <1297800733.2584.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Tom Herbert <therbert@google.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26486 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756008Ab1BOUO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 15:14:27 -0500
In-Reply-To: <1297800733.2584.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the root qdisc for a net device is mqprio, and the driver's
ndo_setup_tc() operation dynamically adds and remvoes TX queues,
netif_set_real_num_tx_queues() will be called during device
unregistration to remove the extra TX queues when the qdisc is
destroyed.  Currently this causes the corresponding kobjects
to be leaked, and the device's reference count never drops to 0.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6392ea0..30c71f9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1648,7 +1648,8 @@ int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
 	if (txq < 1 || txq > dev->num_tx_queues)
 		return -EINVAL;
 
-	if (dev->reg_state == NETREG_REGISTERED) {
+	if (dev->reg_state == NETREG_REGISTERED ||
+	    dev->reg_state == NETREG_UNREGISTERING) {
 		ASSERT_RTNL();
 
 		rc = netdev_queue_update_kobjects(dev, dev->real_num_tx_queues,
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

