From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: changing MTU on b44 breaks eth0
Date: Mon, 3 Nov 2003 22:53:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031103205335.GA7668@ee.oulu.fi>
References: <1067888106.3366.20.camel@bluez.bueche.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Charles Bueche <charles@bueche.ch>
Content-Disposition: inline
In-Reply-To: <1067888106.3366.20.camel@bluez.bueche.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 03, 2003 at 08:35:38PM +0100, Charles Bueche wrote:
> Hi,
> 
> I tried to reduce the MTU to 1464 because I'm behind an ADSL router.
> Rigth when I do the "ifconfig eth0 192.168.0.4 mtu 1464", it hangs the
> port.
> The problem can be reproduced. I have attached a few log extracts. I
> would be ready to test patches or new versions if needed.
Heh

Thanks for the report. Looking at the code and previous bugs in it, I can
safely say I found the problem and a few similar ones that could be
triggered when using ethtool :-)

Anyway, here's a (untested) patch that should fix the problem. As a bonus I
even snuck in a new feature, power management support! 

--- /usr/src/linux-2.6.0-0.test9.1.67/drivers/net/b44.c	2003-10-25 21:43:30.000000000 +0300
+++ linux-2.6.0-test9/drivers/net/b44.c	2003-11-03 22:25:15.943854312 +0200
@@ -25,8 +25,8 @@
 
 #define DRV_MODULE_NAME		"b44"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"0.91"
-#define DRV_MODULE_RELDATE	"Oct 3, 2003"
+#define DRV_MODULE_VERSION	"0.92"
+#define DRV_MODULE_RELDATE	"Nov 3, 2003"
 
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
@@ -1852,11 +1858,57 @@
 	}
 }
 
+#ifdef CONFIG_PM
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
+	b44_enable_ints(bp);
+	return 0;
+}
+#endif /* CONFIG_PM */
+
 static struct pci_driver b44_driver = {
 	.name		= DRV_MODULE_NAME,
 	.id_table	= b44_pci_tbl,
 	.probe		= b44_init_one,
 	.remove		= __devexit_p(b44_remove_one),
+#ifdef CONFIG_PM
+        .suspend        = b44_suspend,
+        .resume         = b44_resume,
+#endif /* CONFIG_PM */
 };
 
 static int __init b44_init(void)
