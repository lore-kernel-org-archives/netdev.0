From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: changing MTU on b44 breaks eth0
Date: Tue, 4 Nov 2003 23:19:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031104211937.GA3888@ee.oulu.fi>
References: <1067888106.3366.20.camel@bluez.bueche.ch> <20031103205335.GA7668@ee.oulu.fi> <20031103151618.79704b30.davem@redhat.com> <20031104111555.GA26860@ee.oulu.fi> <20031104091355.70d6a3d1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031104091355.70d6a3d1.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 04, 2003 at 09:13:55AM -0800, David S. Miller wrote:
> free_netdev() is being invoked before the device registration
> state advanced to NETREG_UNREGISTERED, likely unregister_netdev()
> has not been called first or a bogus pointer was passed into
> the routine.
Ah, like a missing SET_NETDEV_DEV? :-) I still got reliable
rtnetlink_fill_ifinfo oopses (quick debugging showed
strlen(dev->qdisc_sleeping->ops->id); to be the location of the oops), which
went away after adding debug printk's to the module remove stuff, and didn't
come back after removing them and instead removing the device from
modprobe.conf (since I suspected it might have to do with the device getting
rmmoded and getting immediately insmod'd since something tried to use the
device). Then I put it back there and it's behaved since. Weird, or maybe
I forgot a make modules_install before the initial fix. Whatever.

Also added a add_timer() to resume, which it obviously needs...

--- /usr/src/linux-2.6.0-0.test9.1.67/drivers/net/b44.c	2003-10-25 21:43:30.000000000 +0300
+++ linux-2.6.0-test9/drivers/net/b44.c	2003-11-04 22:12:25.776969400 +0200
@@ -25,8 +25,8 @@
 
 #define DRV_MODULE_NAME		"b44"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"0.91"
-#define DRV_MODULE_RELDATE	"Oct 3, 2003"
+#define DRV_MODULE_VERSION	"0.92"
+#define DRV_MODULE_RELDATE	"Nov 4, 2003"
 
 #define B44_DEF_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \
@@ -942,6 +942,8 @@
 	b44_init_hw(bp);
 	spin_unlock_irq(&bp->lock);
 
+	b44_enable_ints(bp);
+	
 	return 0;
 }
 
@@ -1558,6 +1560,8 @@
 		netif_wake_queue(bp->dev);
 		spin_unlock_irq(&bp->lock);
 
+		b44_enable_ints(bp);
+		
 		return 0;
 	}
 	case ETHTOOL_GPAUSEPARAM: {
@@ -1601,6 +1605,8 @@
 		}
 		spin_unlock_irq(&bp->lock);
 
+		b44_enable_ints(bp);
+		
 		return 0;
 	}
 	};
@@ -1752,6 +1758,7 @@
 	}
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev,&pdev->dev);
 
 	/* No interesting netdevice features in this card... */
 	dev->features |= 0;
@@ -1852,11 +1859,56 @@
 	}
 }
 
+static int b44_suspend(struct pci_dev *pdev, u32 state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct b44 *bp = dev->priv;
+
+        if (!netif_running(dev))
+                 return 0;
+
+	del_timer_sync(&bp->timer);
+
+	spin_lock_irq(&bp->lock); 
+
+	b44_halt(bp);
+	netif_carrier_off(bp->dev); 
+	netif_device_detach(bp->dev);
+	b44_free_rings(bp);
+
+	spin_unlock_irq(&bp->lock);
+	return 0;
+}
+
+static int b44_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct b44 *bp = dev->priv;
+
+	if (!netif_running(dev))
+		return 0;
+
+	spin_lock_irq(&bp->lock);
+
+	b44_init_rings(bp);
+	b44_init_hw(bp);
+	netif_device_attach(bp->dev);
+	spin_unlock_irq(&bp->lock);
+
+	bp->timer.expires = jiffies + HZ;
+	add_timer(&bp->timer);
+
+	b44_enable_ints(bp);
+	return 0;
+}
+
 static struct pci_driver b44_driver = {
 	.name		= DRV_MODULE_NAME,
 	.id_table	= b44_pci_tbl,
 	.probe		= b44_init_one,
 	.remove		= __devexit_p(b44_remove_one),
+        .suspend        = b44_suspend,
+        .resume         = b44_resume,
 };
 
 static int __init b44_init(void)
-- 
Pekka Pietikainen
