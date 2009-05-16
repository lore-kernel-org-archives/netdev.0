From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] NET: Meth: Fix unsafe mix of irq and non-irq spinlocks.
Date: Sat, 16 May 2009 12:21:58 +0100
Message-ID: <20090516112158.GA13140@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org,
	Andrew Randrianasulu <randrik_a@yahoo.com>
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Mixing of normal and irq spinlocks results in the following lockdep messages
on bootup on IP32:

[...]
Sending DHCP requests .
======================================================
[ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
2.6.30-rc5-00164-g41baeef #30
------------------------------------------------------
swapper/1 [HC0[0]:SC0[1]:HE0:SE0] is trying to acquire:
 (&priv->meth_lock){+.+...}, at: [<ffffffff8026388c>] meth_tx+0x48/0x43c

and this task is already holding:
 (_xmit_ETHER#2){+.-...}, at: [<ffffffff802d3a00>] __qdisc_run+0x118/0x30c
which would create a new lock dependency:
 (_xmit_ETHER#2){+.-...} -> (&priv->meth_lock){+.+...}

but this new dependency connects a SOFTIRQ-irq-safe lock:
 (_xmit_ETHER#2){+.-...}
... which became SOFTIRQ-irq-safe at:
  [<ffffffff80061458>] __lock_acquire+0x784/0x1a14
  [<ffffffff800627e0>] lock_acquire+0xf8/0x150
  [<ffffffff800128d0>] _spin_lock+0x30/0x44
  [<ffffffff802d2b88>] dev_watchdog+0x70/0x398
  [<ffffffff800433b8>] run_timer_softirq+0x1a8/0x248
  [<ffffffff8003da5c>] __do_softirq+0xec/0x208
  [<ffffffff8003dbd8>] do_softirq+0x60/0xe4
  [<ffffffff8003dda0>] irq_exit+0x54/0x9c
  [<ffffffff80004420>] ret_from_irq+0x0/0x4
  [<ffffffff80004720>] r4k_wait+0x20/0x40
  [<ffffffff80015418>] cpu_idle+0x30/0x60
  [<ffffffff804cd934>] start_kernel+0x3ec/0x404

to a SOFTIRQ-irq-unsafe lock:
 (&priv->meth_lock){+.+...}
... which became SOFTIRQ-irq-unsafe at:
...  [<ffffffff800614f8>] __lock_acquire+0x824/0x1a14
  [<ffffffff800627e0>] lock_acquire+0xf8/0x150
  [<ffffffff800128d0>] _spin_lock+0x30/0x44
  [<ffffffff80263f20>] meth_reset+0x118/0x2d8
  [<ffffffff8026424c>] meth_open+0x28/0x140
  [<ffffffff802c1ae8>] dev_open+0xe0/0x18c
  [<ffffffff802c1268>] dev_change_flags+0xd8/0x1d4
  [<ffffffff804e7770>] ip_auto_config+0x1d4/0xf28
  [<ffffffff80012e68>] do_one_initcall+0x58/0x170
  [<ffffffff804cd190>] kernel_init+0x98/0x104
  [<ffffffff8001520c>] kernel_thread_helper+0x10/0x18

other info that might help us debug this:

2 locks held by swapper/1:
 #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff802c0954>] dev_queue_xmit+0x1e0/0x4b0
 #1:  (_xmit_ETHER#2){+.-...}, at: [<ffffffff802d3a00>] __qdisc_run+0x118/0x30c

the SOFTIRQ-irq-safe lock's dependencies:
-> (_xmit_ETHER#2){+.-...} ops: 0 {
   HARDIRQ-ON-W at:
                        [<ffffffff800614d0>] __lock_acquire+0x7fc/0x1a14
                        [<ffffffff800627e0>] lock_acquire+0xf8/0x150
                        [<ffffffff800128d0>] _spin_lock+0x30/0x44
                        [<ffffffff802d2b88>] dev_watchdog+0x70/0x398
                        [<ffffffff800433b8>] run_timer_softirq+0x1a8/0x248
                        [<ffffffff8003da5c>] __do_softirq+0xec/0x208
                        [<ffffffff8003dbd8>] do_softirq+0x60/0xe4
                        [<ffffffff8003dda0>] irq_exit+0x54/0x9c
                        [<ffffffff80004420>] ret_from_irq+0x0/0x4
                        [<ffffffff80004720>] r4k_wait+0x20/0x40
                        [<ffffffff80015418>] cpu_idle+0x30/0x60
                        [<ffffffff804cd934>] start_kernel+0x3ec/0x404
   IN-SOFTIRQ-W at:
                        [<ffffffff80061458>] __lock_acquire+0x784/0x1a14
                        [<ffffffff800627e0>] lock_acquire+0xf8/0x150
                        [<ffffffff800128d0>] _spin_lock+0x30/0x44
                        [<ffffffff802d2b88>] dev_watchdog+0x70/0x398
                        [<ffffffff800433b8>] run_timer_softirq+0x1a8/0x248
                        [<ffffffff8003da5c>] __do_softirq+0xec/0x208
                        [<ffffffff8003dbd8>] do_softirq+0x60/0xe4
                        [<ffffffff8003dda0>] irq_exit+0x54/0x9c
                        [<ffffffff80004420>] ret_from_irq+0x0/0x4
                        [<ffffffff80004720>] r4k_wait+0x20/0x40
                        [<ffffffff80015418>] cpu_idle+0x30/0x60
                        [<ffffffff804cd934>] start_kernel+0x3ec/0x404
   INITIAL USE at:
                       [<ffffffff80061570>] __lock_acquire+0x89c/0x1a14
                       [<ffffffff800627e0>] lock_acquire+0xf8/0x150
                       [<ffffffff800128d0>] _spin_lock+0x30/0x44
                       [<ffffffff802d2b88>] dev_watchdog+0x70/0x398
                       [<ffffffff800433b8>] run_timer_softirq+0x1a8/0x248
                       [<ffffffff8003da5c>] __do_softirq+0xec/0x208
                       [<ffffffff8003dbd8>] do_softirq+0x60/0xe4
                       [<ffffffff8003dda0>] irq_exit+0x54/0x9c
                       [<ffffffff80004420>] ret_from_irq+0x0/0x4
                       [<ffffffff80004720>] r4k_wait+0x20/0x40
                       [<ffffffff80015418>] cpu_idle+0x30/0x60
                       [<ffffffff804cd934>] start_kernel+0x3ec/0x404
 }
 ... key      at: [<ffffffff80cf93f0>] netdev_xmit_lock_key+0x8/0x1c8

the SOFTIRQ-irq-unsafe lock's dependencies:
-> (&priv->meth_lock){+.+...} ops: 0 {
   HARDIRQ-ON-W at:
                        [<ffffffff800614d0>] __lock_acquire+0x7fc/0x1a14
                        [<ffffffff800627e0>] lock_acquire+0xf8/0x150
                        [<ffffffff800128d0>] _spin_lock+0x30/0x44
                        [<ffffffff80263f20>] meth_reset+0x118/0x2d8
                        [<ffffffff8026424c>] meth_open+0x28/0x140
                        [<ffffffff802c1ae8>] dev_open+0xe0/0x18c
                        [<ffffffff802c1268>] dev_change_flags+0xd8/0x1d4
                        [<ffffffff804e7770>] ip_auto_config+0x1d4/0xf28
                        [<ffffffff80012e68>] do_one_initcall+0x58/0x170
                        [<ffffffff804cd190>] kernel_init+0x98/0x104
                        [<ffffffff8001520c>] kernel_thread_helper+0x10/0x18
   SOFTIRQ-ON-W at:
                        [<ffffffff800614f8>] __lock_acquire+0x824/0x1a14
                        [<ffffffff800627e0>] lock_acquire+0xf8/0x150
                        [<ffffffff800128d0>] _spin_lock+0x30/0x44
                        [<ffffffff80263f20>] meth_reset+0x118/0x2d8
                        [<ffffffff8026424c>] meth_open+0x28/0x140
                        [<ffffffff802c1ae8>] dev_open+0xe0/0x18c
                        [<ffffffff802c1268>] dev_change_flags+0xd8/0x1d4
                        [<ffffffff804e7770>] ip_auto_config+0x1d4/0xf28
                        [<ffffffff80012e68>] do_one_initcall+0x58/0x170
                        [<ffffffff804cd190>] kernel_init+0x98/0x104
                        [<ffffffff8001520c>] kernel_thread_helper+0x10/0x18
   INITIAL USE at:
                       [<ffffffff80061570>] __lock_acquire+0x89c/0x1a14
                       [<ffffffff800627e0>] lock_acquire+0xf8/0x150
                       [<ffffffff800128d0>] _spin_lock+0x30/0x44
                       [<ffffffff80263f20>] meth_reset+0x118/0x2d8
                       [<ffffffff8026424c>] meth_open+0x28/0x140
                       [<ffffffff802c1ae8>] dev_open+0xe0/0x18c
                       [<ffffffff802c1268>] dev_change_flags+0xd8/0x1d4
                       [<ffffffff804e7770>] ip_auto_config+0x1d4/0xf28
                       [<ffffffff80012e68>] do_one_initcall+0x58/0x170
                       [<ffffffff804cd190>] kernel_init+0x98/0x104
                       [<ffffffff8001520c>] kernel_thread_helper+0x10/0x18
 }
 ... key      at: [<ffffffff80cf6ce8>] __key.32424+0x0/0x8

stack backtrace:
Call Trace:
[<ffffffff8000ed0c>] dump_stack+0x8/0x34
[<ffffffff80060b74>] check_usage+0x470/0x4a0
[<ffffffff80060c34>] check_irq_usage+0x90/0x130
[<ffffffff80061f78>] __lock_acquire+0x12a4/0x1a14
[<ffffffff800627e0>] lock_acquire+0xf8/0x150
[<ffffffff80012a0c>] _spin_lock_irqsave+0x60/0x84
[<ffffffff8026388c>] meth_tx+0x48/0x43c
[<ffffffff802d3a38>] __qdisc_run+0x150/0x30c
[<ffffffff802c0aa8>] dev_queue_xmit+0x334/0x4b0
[<ffffffff804e7e6c>] ip_auto_config+0x8d0/0xf28
[<ffffffff80012e68>] do_one_initcall+0x58/0x170
[<ffffffff804cd190>] kernel_init+0x98/0x104
[<ffffffff8001520c>] kernel_thread_helper+0x10/0x18

..... timed out!
IP-Config: Retrying forever (NFS root)...
Sending DHCP requests ., OK
[...]

Fixed by converting all locks to irq locks.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
Tested-by: Andrew Randrianasulu <randrik_a@yahoo.com>

---

 drivers/net/meth.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index aa08987..dbd3436 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -127,11 +127,11 @@ static unsigned long mdio_read(struct meth_private *priv, unsigned long phyreg)
 static int mdio_probe(struct meth_private *priv)
 {
 	int i;
-	unsigned long p2, p3;
+	unsigned long p2, p3, flags;
 	/* check if phy is detected already */
 	if(priv->phy_addr>=0&&priv->phy_addr<32)
 		return 0;
-	spin_lock(&priv->meth_lock);
+	spin_lock_irqsave(&priv->meth_lock, flags);
 	for (i=0;i<32;++i){
 		priv->phy_addr=i;
 		p2=mdio_read(priv,2);
@@ -157,7 +157,7 @@ static int mdio_probe(struct meth_private *priv)
 			break;
 		}
 	}
-	spin_unlock(&priv->meth_lock);
+	spin_unlock_irqrestore(&priv->meth_lock, flags);
 	if(priv->phy_addr<32) {
 		return 0;
 	}
@@ -373,14 +373,14 @@ static int meth_release(struct net_device *dev)
 static void meth_rx(struct net_device* dev, unsigned long int_status)
 {
 	struct sk_buff *skb;
-	unsigned long status;
+	unsigned long status, flags;
 	struct meth_private *priv = netdev_priv(dev);
 	unsigned long fifo_rptr = (int_status & METH_INT_RX_RPTR_MASK) >> 8;
 
-	spin_lock(&priv->meth_lock);
+	spin_lock_irqsave(&priv->meth_lock, flags);
 	priv->dma_ctrl &= ~METH_DMA_RX_INT_EN;
 	mace->eth.dma_ctrl = priv->dma_ctrl;
-	spin_unlock(&priv->meth_lock);
+	spin_unlock_irqrestore(&priv->meth_lock, flags);
 
 	if (int_status & METH_INT_RX_UNDERFLOW) {
 		fifo_rptr = (fifo_rptr - 1) & 0x0f;
@@ -452,12 +452,12 @@ static void meth_rx(struct net_device* dev, unsigned long int_status)
 		mace->eth.rx_fifo = priv->rx_ring_dmas[priv->rx_write];
 		ADVANCE_RX_PTR(priv->rx_write);
 	}
-	spin_lock(&priv->meth_lock);
+	spin_lock_irqsave(&priv->meth_lock, flags);
 	/* In case there was underflow, and Rx DMA was disabled */
 	priv->dma_ctrl |= METH_DMA_RX_INT_EN | METH_DMA_RX_EN;
 	mace->eth.dma_ctrl = priv->dma_ctrl;
 	mace->eth.int_stat = METH_INT_RX_THRESHOLD;
-	spin_unlock(&priv->meth_lock);
+	spin_unlock_irqrestore(&priv->meth_lock, flags);
 }
 
 static int meth_tx_full(struct net_device *dev)
@@ -470,11 +470,11 @@ static int meth_tx_full(struct net_device *dev)
 static void meth_tx_cleanup(struct net_device* dev, unsigned long int_status)
 {
 	struct meth_private *priv = netdev_priv(dev);
-	unsigned long status;
+	unsigned long status, flags;
 	struct sk_buff *skb;
 	unsigned long rptr = (int_status&TX_INFO_RPTR) >> 16;
 
-	spin_lock(&priv->meth_lock);
+	spin_lock_irqsave(&priv->meth_lock, flags);
 
 	/* Stop DMA notification */
 	priv->dma_ctrl &= ~(METH_DMA_TX_INT_EN);
@@ -527,12 +527,13 @@ static void meth_tx_cleanup(struct net_device* dev, unsigned long int_status)
 	}
 
 	mace->eth.int_stat = METH_INT_TX_EMPTY | METH_INT_TX_PKT;
-	spin_unlock(&priv->meth_lock);
+	spin_unlock_irqrestore(&priv->meth_lock, flags);
 }
 
 static void meth_error(struct net_device* dev, unsigned status)
 {
 	struct meth_private *priv = netdev_priv(dev);
+	unsigned long flags;
 
 	printk(KERN_WARNING "meth: error status: 0x%08x\n",status);
 	/* check for errors too... */
@@ -547,7 +548,7 @@ static void meth_error(struct net_device* dev, unsigned status)
 		printk(KERN_WARNING "meth: Rx overflow\n");
 	if (status & (METH_INT_RX_UNDERFLOW)) {
 		printk(KERN_WARNING "meth: Rx underflow\n");
-		spin_lock(&priv->meth_lock);
+		spin_lock_irqsave(&priv->meth_lock, flags);
 		mace->eth.int_stat = METH_INT_RX_UNDERFLOW;
 		/* more underflow interrupts will be delivered,
 		 * effectively throwing us into an infinite loop.
@@ -555,7 +556,7 @@ static void meth_error(struct net_device* dev, unsigned status)
 		priv->dma_ctrl &= ~METH_DMA_RX_EN;
 		mace->eth.dma_ctrl = priv->dma_ctrl;
 		DPRINTK("Disabled meth Rx DMA temporarily\n");
-		spin_unlock(&priv->meth_lock);
+		spin_unlock_irqrestore(&priv->meth_lock, flags);
 	}
 	mace->eth.int_stat = METH_INT_ERROR;
 }

----- End forwarded message -----

  Ralf
