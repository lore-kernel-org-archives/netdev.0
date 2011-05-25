From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] xen: netfront: hold RTNL when updating features.
Date: Wed, 25 May 2011 08:56:02 +0100
Message-ID: <1306310162-5627-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Konrad reports:
[    0.930811] RTNL: assertion failed at /home/konrad/ssd/linux/net/core/dev.c (5258)
[    0.930821] Pid: 22, comm: xenwatch Not tainted 2.6.39-05193-gd762f43 #1
[    0.930825] Call Trace:
[    0.930834]  [<ffffffff8143bd0e>] __netdev_update_features+0xae/0xe0
[    0.930840]  [<ffffffff8143dd41>] netdev_update_features+0x11/0x30
[    0.930847]  [<ffffffffa0037105>] netback_changed+0x4e5/0x800 [xen_netfront]
[    0.930854]  [<ffffffff8132a838>] xenbus_otherend_changed+0xa8/0xb0
[    0.930860]  [<ffffffff8157ca99>] ? _raw_spin_unlock_irqrestore+0x19/0x20
[    0.930866]  [<ffffffff8132adfe>] backend_changed+0xe/0x10
[    0.930871]  [<ffffffff8132875a>] xenwatch_thread+0xba/0x180
[    0.930876]  [<ffffffff810a8ba0>] ? wake_up_bit+0x40/0x40
[    0.930881]  [<ffffffff813286a0>] ? split+0xf0/0xf0
[    0.930886]  [<ffffffff810a8646>] kthread+0x96/0xa0
[    0.930891]  [<ffffffff815855a4>] kernel_thread_helper+0x4/0x10
[    0.930896]  [<ffffffff815846b3>] ? int_ret_from_sys_call+0x7/0x1b
[    0.930901]  [<ffffffff8157cf61>] ? retint_restore_args+0x5/0x6
[    0.930906]  [<ffffffff815855a0>] ? gs_change+0x13/0x13

This update happens in xenbus watch callback context and hence does not already
hold the rtnl. Take the lock as necessary.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/net/xen-netfront.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index db9a763..d29365a 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1581,7 +1581,9 @@ static int xennet_connect(struct net_device *dev)
 	if (err)
 		return err;
 
+	rtnl_lock();
 	netdev_update_features(dev);
+	rtnl_unlock();
 
 	spin_lock_bh(&np->rx_lock);
 	spin_lock_irq(&np->tx_lock);
-- 
1.7.2.5
