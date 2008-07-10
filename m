From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-next] net: fix lockdep warning in qdisc_lock_tree()
Date: Thu, 10 Jul 2008 20:14:16 +0200
Message-ID: <20080710181416.GA8265@ami.dom.local>
References: <a4423d670807100204kf269814ncd649bf02312311b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-next@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a4423d670807100204kf269814ncd649bf02312311b@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexander Beregalov wrote, On 07/10/2008 11:04 AM:
...
> [    0.426638] =============================================
> [    0.426638] [ INFO: possible recursive locking detected ]
> [    0.426638] 2.6.26-rc9-next-20080710 #5
> [    0.426638] ---------------------------------------------
> [    0.426638] swapper/1 is trying to acquire lock:
> [    0.426638]  (&queue->lock){-...}, at: [<ffffffff8041c3d0>]
> qdisc_lock_tree+0x27/0x2c
> [    0.426638]
> [    0.426638] but task is already holding lock:
> [    0.426638]  (&queue->lock){-...}, at: [<ffffffff8041c3c8>]
> qdisc_lock_tree+0x1f/0x2c
> [    0.426638]
> [    0.426638] other info that might help us debug this:
> [    0.426638] 3 locks held by swapper/1:
> [    0.426638]  #0:  (net_mutex){--..}, at: [<ffffffff8040b827>]
> register_pernet_device+0x1a/0x5a
> [    0.426638]  #1:  (rtnl_mutex){--..}, at: [<ffffffff80417179>]
> rtnl_lock+0x12/0x14
> [    0.426638]  #2:  (&queue->lock){-...}, at: [<ffffffff8041c3c8>]
> qdisc_lock_tree+0x1f/0x2c
> [    0.426638]
> [    0.426638] stack backtrace:
> [    0.426638] Pid: 1, comm: swapper Not tainted 2.6.26-rc9-next-20080710 #5
> [    0.426638]
> [    0.426638] Call Trace:
> [    0.426638]  [<ffffffff8024f95a>] __lock_acquire+0xba9/0xf12
> [    0.426638]  [<ffffffff8041c3d0>] ? qdisc_lock_tree+0x27/0x2c
> [    0.426638]  [<ffffffff8024fd48>] lock_acquire+0x85/0xa9
> [    0.426638]  [<ffffffff8041c3d0>] ? qdisc_lock_tree+0x27/0x2c
> [    0.426638]  [<ffffffff80476794>] _spin_lock+0x25/0x31
> [    0.426638]  [<ffffffff8041c3d0>] qdisc_lock_tree+0x27/0x2c
> [    0.426638]  [<ffffffff8041c412>] dev_init_scheduler+0x11/0x94
> [    0.426638]  [<ffffffff8040f3be>] register_netdevice+0x296/0x3f0
> [    0.426638]  [<ffffffff8040f552>] register_netdev+0x3a/0x48
> [    0.426638]  [<ffffffff805fc274>] loopback_net_init+0x40/0x7a
> [    0.426638]  [<ffffffff805fc222>] ? loopback_init+0x0/0x12
...

lockdep needs separate lock init to distinguish rx and tx queue locks.
(There is no real lockup danger.)

Reported-by: Alexander Beregalov <a.beregalov@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/core/dev.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a29a359..157b683 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4090,17 +4090,25 @@ static struct net_device_stats *internal_stats(struct net_device *dev)
 	return &dev->stats;
 }
 
-static void netdev_init_one_queue(struct net_device *dev,
-				  struct netdev_queue *queue)
+static void netdev_init_rx_queue(struct net_device *dev,
+				  struct netdev_queue *rx_queue)
 {
-	spin_lock_init(&queue->lock);
-	queue->dev = dev;
+	spin_lock_init(&rx_queue->lock);
+	rx_queue->dev = dev;
+}
+
+/* lockdep needs separate init to distinguish these locks */
+static void netdev_init_tx_queue(struct net_device *dev,
+				  struct netdev_queue *tx_queue)
+{
+	spin_lock_init(&tx_queue->lock);
+	tx_queue->dev = dev;
 }
 
 static void netdev_init_queues(struct net_device *dev)
 {
-	netdev_init_one_queue(dev, &dev->rx_queue);
-	netdev_init_one_queue(dev, &dev->tx_queue);
+	netdev_init_rx_queue(dev, &dev->rx_queue);
+	netdev_init_tx_queue(dev, &dev->tx_queue);
 }
 
 /**
