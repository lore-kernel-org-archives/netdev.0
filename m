From: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/5] IrDA: nsc-ircc: PM update
Date: Tue, 14 Feb 2006 00:15:09 +0200
Message-ID: <20060213221509.GC31091@irie>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	IrDA users <irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "ext David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

This patch brings the nsc-ircc code to a more up to date power management
scheme, following the current device model.

Signed-off-by: Dmitry Torokhov <dtor-JGs/UdohzUI@public.gmane.org>
Signed-off-by: Rudolf Marek <r.marek-3zVPrsR01WjrBKCeMvbIDA@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

diff --git a/drivers/net/irda/nsc-ircc.h b/drivers/net/irda/nsc-ircc.h
index 6edf7e5..dacf671 100644
--- a/drivers/net/irda/nsc-ircc.h
+++ b/drivers/net/irda/nsc-ircc.h
@@ -269,7 +269,7 @@ struct nsc_ircc_cb {
 	__u32 new_speed;
 	int index;                 /* Instance index */
 
-        struct pm_dev *dev;
+	struct platform_device *pldev;
 };
 
 static inline void switch_bank(int iobase, int bank)
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 74cb38c..e8ff07f 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -55,14 +55,12 @@
 #include <linux/rtnetlink.h>
 #include <linux/dma-mapping.h>
 #include <linux/pnp.h>
+#include <linux/platform_device.h>
 
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/byteorder.h>
 
-#include <linux/pm.h>
-#include <linux/pm_legacy.h>
-
 #include <net/irda/wrapper.h>
 #include <net/irda/irda.h>
 #include <net/irda/irda_device.h>
@@ -74,6 +72,19 @@
 
 static char *driver_name = "nsc-ircc";
 
+/* Power Management */
+#define NSC_IRCC_DRIVER_NAME                  "nsc-ircc"
+static int nsc_ircc_suspend(struct platform_device *dev, pm_message_t state);
+static int nsc_ircc_resume(struct platform_device *dev);
+
+static struct platform_driver nsc_ircc_driver = {
+	.suspend	= nsc_ircc_suspend,
+	.resume		= nsc_ircc_resume,
+	.driver		= {
+		.name	= NSC_IRCC_DRIVER_NAME,
+	},
+};
+
 /* Module parameters */
 static int qos_mtt_bits = 0x07;  /* 1 ms or more */
 static int dongle_id;
@@ -164,7 +175,6 @@ static int  nsc_ircc_net_open(struct net
 static int  nsc_ircc_net_close(struct net_device *dev);
 static int  nsc_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static struct net_device_stats *nsc_ircc_net_get_stats(struct net_device *dev);
-static int nsc_ircc_pmproc(struct pm_dev *dev, pm_request_t rqst, void *data);
 
 /* Globals */
 static int pnp_registered;
@@ -186,6 +196,12 @@ static int __init nsc_ircc_init(void)
 	int reg;
 	int i = 0;
 
+	ret = platform_driver_register(&nsc_ircc_driver); 
+        if (ret) {
+                IRDA_ERROR("%s, Can't register driver!\n", driver_name);       
+                return ret;                                                                       
+        }	
+
  	/* Register with PnP subsystem to detect disable ports */
 	ret = pnp_register_driver(&nsc_ircc_pnp_driver);
 
@@ -274,6 +290,7 @@ static int __init nsc_ircc_init(void)
 	}
 
 	if (ret) {
+		platform_driver_unregister(&nsc_ircc_driver);
 		pnp_unregister_driver(&nsc_ircc_pnp_driver);
 		pnp_registered = 0;
 	}
@@ -291,13 +308,13 @@ static void __exit nsc_ircc_cleanup(void
 {
 	int i;
 
-	pm_unregister_all(nsc_ircc_pmproc);
-	
 	for (i = 0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
 			nsc_ircc_close(dev_self[i]);
 	}
 
+	platform_driver_unregister(&nsc_ircc_driver);
+
 	if (pnp_registered)
  		pnp_unregister_driver(&nsc_ircc_pnp_driver);
 	
@@ -314,7 +331,6 @@ static int __init nsc_ircc_open(chipio_t
 {
 	struct net_device *dev;
 	struct nsc_ircc_cb *self;
-	struct pm_dev *pmdev;
 	void *ret;
 	int err, chip_index;
 
@@ -444,11 +460,18 @@ static int __init nsc_ircc_open(chipio_t
 	self->io.dongle_id = dongle_id;
 	nsc_ircc_init_dongle_interface(self->io.fir_base, dongle_id);
 
-        pmdev = pm_register(PM_SYS_DEV, PM_SYS_IRDA, nsc_ircc_pmproc);
-        if (pmdev)
-                pmdev->data = self;
+ 	self->pldev = platform_device_register_simple(NSC_IRCC_DRIVER_NAME,
+ 						      self->index, NULL, 0);
+ 	if (IS_ERR(self->pldev)) {
+ 		err = PTR_ERR(self->pldev);
+ 		goto out5;
+ 	}
+ 	platform_set_drvdata(self->pldev, self);
 
 	return chip_index;
+
+ out5: 
+ 	unregister_netdev(dev);
  out4:
 	dma_free_coherent(NULL, self->tx_buff.truesize,
 			  self->tx_buff.head, self->tx_buff_dma);
@@ -479,6 +502,8 @@ static int __exit nsc_ircc_close(struct 
 
         iobase = self->io.fir_base;
 
+	platform_device_unregister(self->pldev);
+
 	/* Remove netdevice */
 	unregister_netdev(self->netdev);
 
@@ -2278,45 +2303,83 @@ static struct net_device_stats *nsc_ircc
 	return &self->stats;
 }
 
-static void nsc_ircc_suspend(struct nsc_ircc_cb *self)
+static int nsc_ircc_suspend(struct platform_device *dev, pm_message_t state)
 {
-	IRDA_MESSAGE("%s, Suspending\n", driver_name);
-
+     	struct nsc_ircc_cb *self = platform_get_drvdata(dev);
+ 	int bank;
+	unsigned long flags;
+ 	int iobase = self->io.fir_base;
+	
 	if (self->io.suspended)
-		return;
-
-	nsc_ircc_net_close(self->netdev);
+		return 0;
 
+	IRDA_DEBUG(1, "%s, Suspending\n", driver_name);
+		
+	rtnl_lock();
+	if (netif_running(self->netdev)) {
+		netif_device_detach(self->netdev);
+		spin_lock_irqsave(&self->lock, flags);
+		/* Save current bank */
+		bank = inb(iobase+BSR);
+		
+		/* Disable interrupts */
+		switch_bank(iobase, BANK0);
+		outb(0, iobase+IER);
+		
+		/* Restore bank register */
+		outb(bank, iobase+BSR);
+		
+		spin_unlock_irqrestore(&self->lock, flags);
+		free_irq(self->io.irq, self->netdev);
+		disable_dma(self->io.dma);
+	}
 	self->io.suspended = 1;
+	rtnl_unlock();
+ 	
+	return 0;
 }
-
-static void nsc_ircc_wakeup(struct nsc_ircc_cb *self)
+ 
+static int nsc_ircc_resume(struct platform_device *dev)
 {
+ 	struct nsc_ircc_cb *self = platform_get_drvdata(dev);
+ 	unsigned long flags;
+ 
 	if (!self->io.suspended)
-		return;
+		return 0;
+
+	IRDA_DEBUG(1, "%s, Waking up\n", driver_name);
 
+	rtnl_lock();
 	nsc_ircc_setup(&self->io);
-	nsc_ircc_net_open(self->netdev);
-	
-	IRDA_MESSAGE("%s, Waking up\n", driver_name);
+	nsc_ircc_init_dongle_interface(self->io.fir_base, self->io.dongle_id);
 
+	if (netif_running(self->netdev)) {
+		if (request_irq(self->io.irq, nsc_ircc_interrupt, 0,                     				
+				self->netdev->name, self->netdev)) {
+ 		    	IRDA_WARNING("%s, unable to allocate irq=%d\n",
+				     driver_name, self->io.irq);
+			
+			/*
+			 * Don't fail resume process, just kill this
+			 * network interface
+			 */
+			unregister_netdevice(self->netdev);
+		} else {
+			spin_lock_irqsave(&self->lock, flags);
+			nsc_ircc_change_speed(self, self->io.speed);
+			spin_unlock_irqrestore(&self->lock, flags);
+			netif_device_attach(self->netdev);
+		}
+		
+	} else {
+		spin_lock_irqsave(&self->lock, flags);
+		nsc_ircc_change_speed(self, 9600);
+		spin_unlock_irqrestore(&self->lock, flags);
+	}
 	self->io.suspended = 0;
-}
+	rtnl_unlock();
 
-static int nsc_ircc_pmproc(struct pm_dev *dev, pm_request_t rqst, void *data)
-{
-        struct nsc_ircc_cb *self = (struct nsc_ircc_cb*) dev->data;
-        if (self) {
-                switch (rqst) {
-                case PM_SUSPEND:
-                        nsc_ircc_suspend(self);
-                        break;
-                case PM_RESUME:
-                        nsc_ircc_wakeup(self);
-                        break;
-                }
-        }
-	return 0;
+ 	return 0;
 }
 
 MODULE_AUTHOR("Dag Brattli <dagb-WiQn+q4tdXRhl2p70BpVqQ@public.gmane.org>");


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
