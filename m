From: dingtianhong <dingtianhong@huawei.com>
Subject: [PATCH] bonding: add synchronize_net() after netdev_rx_handler_unregister
Date: Thu, 23 May 2013 09:57:55 +0800
Message-ID: <519D77A3.7040003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:1377 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757215Ab3EWB66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 21:58:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 00cfec3 (net: add a synchronize_net() in netdev_rx_handler_unregister())
add a synchronize_net() in netdev_rx_handler_unregister() to guarantee the
rx_handler is NULL when rx_handler_data is a non NULL in rcu_read_lock().

so the caller should not use netdev_rx_handler_unregister in atomic as it may
schedule and sleep, the bonding release met the problem.

the commit fcd99434f (bonding: get netdev_rx_handler_unregister out of locks)
fix the bug in bond release, but there is no action to guarantee the
rx_handler_data is NULL when bond release, so add synchronize_net() behind
netdev_rx_handler_unregister() to guarantee it.

This patch adds more comments to netdev_rx_handler_unregister(), as its more
reasonable.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 2 ++
 net/core/dev.c                  | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d0aade0..592a603 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2007,6 +2007,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 	 * for this slave anymore.
 	 */
 	netdev_rx_handler_unregister(slave_dev);
+	synchronize_net();
+
 	write_lock_bh(&bond->lock);
 
 	if (!all && !bond->params.fail_over_mac) {
diff --git a/net/core/dev.c b/net/core/dev.c
index fc1e289..9ffeda9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3344,6 +3344,9 @@ EXPORT_SYMBOL_GPL(netdev_rx_handler_register);
  *	Unregister a receive handler from a device.
  *
  *	The caller must hold the rtnl_mutex.
+ *
+ *	The function should only be called outside the atomic as it
+ *	might sleep and schedule.
  */
 void netdev_rx_handler_unregister(struct net_device *dev)
 {
-- 
1.8.0
