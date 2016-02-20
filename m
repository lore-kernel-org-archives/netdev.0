From: Gonglei <arei.gonglei@huawei.com>
Subject: [PATCH] xen-netfront: set real_num_tx_queues to zreo avoid to trigger BUG_ON
Date: Sat, 20 Feb 2016 09:27:26 +0800
Message-ID: <1455931646-5672-1-git-send-email-arei.gonglei@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peter.huangpeng@huawei.com>, Gonglei <arei.gonglei@huawei.com>,
	"David S . Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's possible for a race condition to exist between xennet_open() and
talk_to_netback(). After invoking netfront_probe() then other
threads or processes invoke xennet_open (such as NetworkManager)
immediately may trigger BUG_ON(). Besides, we also should reset
real_num_tx_queues in xennet_destroy_queues().

    [ 3324.658057] kernel BUG at include/linux/netdevice.h:508!
    [ 3324.658057] invalid opcode: 0000 [#1] SMP
    [ 3324.658057] CPU: 0 PID: 662 Comm: NetworkManager Tainted: G
    [<ffffffff810bc646>] ? raw_notifier_call_chain+0x16/0x20
    [<ffffffff8166e1be>] __dev_open+0xce/0x150
    [<ffffffff8166e501>] __dev_change_flags+0xa1/0x170
    [<ffffffff8166e5f9>] dev_change_flags+0x29/0x70
    [<ffffffff8167c49f>] do_setlink+0x39f/0xb40
    [<ffffffff813c9ce2>] ? nla_parse+0x32/0x120
    [<ffffffff8167d544>] rtnl_newlink+0x604/0x900
    [<ffffffff8169f453>] ? netlink_unicast+0x193/0x1c0
    [<ffffffff81324808>] ? security_capable+0x18/0x20
    [<ffffffff810a4e9d>] ? ns_capable+0x2d/0x60
    [<ffffffff8167b955>] rtnetlink_rcv_msg+0xf5/0x270
    [<ffffffff813b32bd>] ? rhashtable_lookup_compare+0x5d/0xa0
    [<ffffffff8167b860>] ? rtnetlink_rcv+0x40/0x40
    [<ffffffff8169fc89>] netlink_rcv_skb+0xb9/0xe0
    [<ffffffff8167b84c>] rtnetlink_rcv+0x2c/0x40
    [<ffffffff8169f3ed>] netlink_unicast+0x12d/0x1c0
    [<ffffffff8169f953>] netlink_sendmsg+0x4d3/0x630
    [<ffffffff813280a2>] ? sock_has_perm+0x72/0x90
    [<ffffffff8164d34f>] do_sock_sendmsg+0x9f/0xc0
    [ 3324.703482] RIP  [<ffffffffa0065a50>] xennet_open+0x180/0x182 [xen_netfront]

CC: David S. Miller <davem@davemloft.net>
Signed-off-by: Gonglei <arei.gonglei@huawei.com>
---
 drivers/net/xen-netfront.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d6abf19..da25555 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -340,7 +340,7 @@ static int xennet_open(struct net_device *dev)
 	unsigned int i = 0;
 	struct netfront_queue *queue = NULL;
 
-	for (i = 0; i < num_queues; ++i) {
+	for (i = 0; i < num_queues && np->queues; ++i) {
 		queue = &np->queues[i];
 		napi_enable(&queue->napi);
 
@@ -1296,6 +1296,10 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	np                   = netdev_priv(netdev);
 	np->xbdev            = dev;
 
+	/* No need to use rtnl_lock() before the call below as it
+	 * happens before register_netdev().
+	 */
+	netdev->real_num_tx_queues = 0;
 	np->queues = NULL;
 
 	err = -ENOMEM;
@@ -1748,7 +1752,7 @@ static void xennet_destroy_queues(struct netfront_info *info)
 		del_timer_sync(&queue->rx_refill_timer);
 		netif_napi_del(&queue->napi);
 	}
-
+	info->netdev->real_num_tx_queues = 0;
 	rtnl_unlock();
 
 	kfree(info->queues);
@@ -1951,6 +1955,9 @@ abort_transaction_no_dev_fatal:
 	xennet_disconnect_backend(info);
 	kfree(info->queues);
 	info->queues = NULL;
+	rtnl_lock();
+	info->netdev->real_num_tx_queues = 0;
+	rtnl_unlock();
  out:
 	return err;
 }
-- 
1.8.5.2
