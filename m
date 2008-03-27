From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: [PATCH / RFC 2/2] fec: fixup spinlocks.
Date: Thu, 27 Mar 2008 15:00:43 +0100
Message-ID: <20080327140120.068976876@linutronix.de>
References: <20080327140041.072611004@linutronix.de>
Reply-To: uClinux development list <uclinux-dev@uclinux.org>
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	Greg Ungerer <gerg@uclinux.org>
To: uclinux-dev@uclinux.org
Return-path: <uclinux-dev-bounces@uclinux.org>
Content-Disposition: inline; filename=m68knommu-fix_spinlocks_in_fec.patch
List-Unsubscribe: <http://mailman.uclinux.org/mailman/listinfo/uclinux-dev>,
	<mailto:uclinux-dev-request@uclinux.org?subject=unsubscribe>
List-Archive: <http://mailman.uclinux.org/pipermail/uclinux-dev>
List-Post: <mailto:uclinux-dev@uclinux.org>
List-Help: <mailto:uclinux-dev-request@uclinux.org?subject=help>
List-Subscribe: <http://mailman.uclinux.org/mailman/listinfo/uclinux-dev>,
	<mailto:uclinux-dev-request@uclinux.org?subject=subscribe>
Sender: uclinux-dev-bounces@uclinux.org
Errors-To: uclinux-dev-bounces@uclinux.org
List-Id: netdev.vger.kernel.org

1. Initialize the spinlock
2. Fix the following spinlock recursion:

|BUG: spinlock recursion on CPU#0, swapper/1
| lock: 00253484, .magic: dead4ead, .owner: swapper/1, .owner_cpu: 0
|Stack from 00219d04:
|        0002951e 00144b04 000afaca 00253484 001753a2 00002704 000c5ef6 00253484
|        00800000 0025302d 002533e0 0002951e 00253000 0004857a 00144baa 00253484
|        00000000 000c5550 00253484 00172acd 000c5ef6 0017689c 0014aca3 00253484
|        00020013 00252000 002533e0 40001000 000c602e 00253000 600e0000 000c5ef6
|        001a6d68 40001000 000c57c0 00020013 00253000 00172acd 000c5faa 00176a11
|        0014ac96 000c5faa 00000000 00000000 0000005d 00000033 00219eaa 00000001
|Possible Call Trace:
| printk+0x0/0x20
| _spin_unlock+0x0/0x6
| _raw_spin_lock+0xfc/0x160
| mii_discover_phy3+0x0/0xb4
| printk+0x0/0x20
| note_interrupt+0x0/0x28a
| _spin_lock_irqsave+0x16/0x1e
| mii_queue+0x4c/0x124
| mii_discover_phy3+0x0/0xb4
| _start+0x13/0x7c
| mii_discover_phy+0x84/0x90
| mii_discover_phy3+0x0/0xb4
| fec_enet_interrupt+0x158/0x472

We call from inet context (fec_enet_interrupt, holding the spinlock) the
first callback (which is mii_discover_phy(), initialized in fec_enet_init()).
mii_discover_phy() calls mii_queue() which takes the spinlock again, boom.
The fix is to drop the spinlock in interrupt context after the list
modification.

3. Use spin_unlock_irq / spin_lock_irq in the IRQ functions (IRQ is not
registered with the IRQ off flag) and  dev->hard_start_xmit callback.
4. Use the .*_irqsave variant in that part which may be called from IRQ or
user mode.

Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -117,9 +117,11 @@ static unsigned char	fec_mac_default[] =
 /* Forward declarations of some structures to support different PHYs
 */
 
+typedef void (mii_func)(uint val, struct net_device *dev);
+
 typedef struct {
 	uint mii_data;
-	void (*funct)(uint mii_reg, struct net_device *dev);
+	mii_func *funct;
 } phy_cmd_t;
 
 typedef struct {
@@ -261,7 +263,7 @@ static mii_list_t	*mii_head;
 static mii_list_t	*mii_tail;
 
 static int	mii_queue(struct net_device *dev, int request,
-				void (*func)(uint, struct net_device *));
+				mii_func *func);
 
 /* Make MII read/write commands for the FEC.
 */
@@ -503,7 +505,7 @@ fec_enet_tx(struct net_device *dev)
 	struct	sk_buff	*skb;
 
 	fep = netdev_priv(dev);
-	spin_lock(&fep->lock);
+	spin_lock_irq(&fep->lock);
 	bdp = fep->dirty_tx;
 
 	while (((status = bdp->cbd_sc) & BD_ENET_TX_READY) == 0) {
@@ -562,7 +564,7 @@ fec_enet_tx(struct net_device *dev)
 		}
 	}
 	fep->dirty_tx = (cbd_t *)bdp;
-	spin_unlock(&fep->lock);
+	spin_unlock_irq(&fep->lock);
 }
 
 
@@ -705,12 +707,13 @@ fec_enet_mii(struct net_device *dev)
 	volatile fec_t	*ep;
 	mii_list_t	*mip;
 	uint		mii_reg;
+	mii_func *mii_func = NULL;
 
 	fep = netdev_priv(dev);
 	ep = fep->hwp;
 	mii_reg = ep->fec_mii_data;
 
-	spin_lock(&fep->lock);
+	spin_lock_irq(&fep->lock);
 
 	if ((mip = mii_head) == NULL) {
 		printk("MII and no head!\n");
@@ -718,7 +721,7 @@ fec_enet_mii(struct net_device *dev)
 	}
 
 	if (mip->mii_func != NULL)
-		(*(mip->mii_func))(mii_reg, dev);
+		mii_func = *(mip->mii_func);
 
 	mii_head = mip->mii_next;
 	mip->mii_next = mii_free;
@@ -728,11 +731,13 @@ fec_enet_mii(struct net_device *dev)
 		ep->fec_mii_data = mip->mii_regval;
 
 unlock:
-	spin_unlock(&fep->lock);
+	spin_unlock_irq(&fep->lock);
+	if (mii_func)
+		mii_func(mii_reg, dev);
 }
 
 static int
-mii_queue(struct net_device *dev, int regval, void (*func)(uint, struct net_device *))
+mii_queue(struct net_device *dev, int regval, mii_func *func)
 {
 	struct fec_enet_private *fep;
 	unsigned long	flags;
@@ -2343,6 +2348,7 @@ int __init fec_enet_init(struct net_devi
 	*/
 	fecp = (volatile fec_t *) fec_hw[index];
 
+	spin_lock_init(&fep->lock);
 	fep->index = index;
 	fep->hwp = fecp;
 	fep->netdev = dev;

-- 

_______________________________________________
uClinux-dev mailing list
uClinux-dev@uclinux.org
http://mailman.uclinux.org/mailman/listinfo/uclinux-dev
This message was resent by uclinux-dev@uclinux.org
To unsubscribe see:
http://mailman.uclinux.org/mailman/options/uclinux-dev
