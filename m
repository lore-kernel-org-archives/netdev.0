From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/9] PCI: vpd handle longer delays in access (rev3)
Date: Thu, 25 Sep 2008 09:48:52 -0700
Message-ID: <20080925165223.168847327@vyatta.com>
References: <20080925164851.694359776@vyatta.com>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ivan Vecera <ivecera@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline; filename=vpd-delay.patch
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Accessing the VPD area can take a long time.  The existing 
VPD access code fails consistently on my hardware. There are comments
in the Marvell vendor driver that it can take up to 13ms per word. 

Change the access routines to:
  * use a mutex rather than spinning with IRQ's disabled and lock held
  * have a much longer timeout
  * call cond_resched while spinning

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/pci/access.c	2008-09-09 13:56:10.000000000 -0700
+++ b/drivers/pci/access.c	2008-09-09 13:56:56.000000000 -0700
@@ -133,39 +133,46 @@ PCI_USER_WRITE_CONFIG(dword, u32)
 
 struct pci_vpd_pci22 {
 	struct pci_vpd base;
-	spinlock_t lock; /* controls access to hardware and the flags */
-	u8	cap;
+	struct mutex lock;
+	u16	flag;
 	bool	busy;
-	bool	flag; /* value of F bit to wait for */
+	u8	cap;
 };
 
-/* Wait for last operation to complete */
+/*
+ * Wait for last operation to complete.
+ * This code has to spin since there is no other notification from the PCI
+ * hardware. Since the VPD is often implemented by serial attachment to an
+ * EEPROM, it may take many milliseconds to complete.
+ */
 static int pci_vpd_pci22_wait(struct pci_dev *dev)
 {
 	struct pci_vpd_pci22 *vpd =
 		container_of(dev->vpd, struct pci_vpd_pci22, base);
-	u16 flag, status;
-	int wait;
+	unsigned long timeout = jiffies + HZ/20 + 2;
+	u16 status;
 	int ret;
 
 	if (!vpd->busy)
 		return 0;
 
-	flag = vpd->flag ? PCI_VPD_ADDR_F : 0;
-	wait = vpd->flag ? 10 : 1000; /* read: 100 us; write: 10 ms */
 	for (;;) {
-		ret = pci_user_read_config_word(dev,
-						vpd->cap + PCI_VPD_ADDR,
+		ret = pci_user_read_config_word(dev, vpd->cap + PCI_VPD_ADDR,
 						&status);
-		if (ret < 0)
+		if (ret)
 			return ret;
-		if ((status & PCI_VPD_ADDR_F) == flag) {
+
+		if ((status & PCI_VPD_ADDR_F) == vpd->flag) {
 			vpd->busy = false;
 			return 0;
 		}
-		if (wait-- == 0)
+
+		if (time_after(jiffies, timeout))
 			return -ETIMEDOUT;
-		udelay(10);
+		if (fatal_signal_pending(current))
+			return -EINTR;
+		if(!cond_resched())
+			udelay(10);
 	}
 }
 
@@ -175,7 +182,7 @@ static int pci_vpd_pci22_read(struct pci
 	struct pci_vpd_pci22 *vpd =
 		container_of(dev->vpd, struct pci_vpd_pci22, base);
 	u32 val;
-	int ret;
+	int ret = 0;
 	int begin, end, i;
 
 	if (pos < 0 || pos > vpd->base.len || size > vpd->base.len  - pos)
@@ -183,7 +190,9 @@ static int pci_vpd_pci22_read(struct pci
 	if (size == 0)
 		return 0;
 
-	spin_lock_irq(&vpd->lock);
+	if (mutex_lock_killable(&vpd->lock))
+		return -EINTR;
+
 	ret = pci_vpd_pci22_wait(dev);
 	if (ret < 0)
 		goto out;
@@ -191,15 +200,16 @@ static int pci_vpd_pci22_read(struct pci
 					 pos & ~3);
 	if (ret < 0)
 		goto out;
+
 	vpd->busy = true;
-	vpd->flag = 1;
+	vpd->flag = PCI_VPD_ADDR_F;
 	ret = pci_vpd_pci22_wait(dev);
 	if (ret < 0)
 		goto out;
 	ret = pci_user_read_config_dword(dev, vpd->cap + PCI_VPD_DATA,
 					 &val);
 out:
-	spin_unlock_irq(&vpd->lock);
+	mutex_unlock(&vpd->lock);
 	if (ret < 0)
 		return ret;
 
@@ -220,7 +230,7 @@ static int pci_vpd_pci22_write(struct pc
 	struct pci_vpd_pci22 *vpd =
 		container_of(dev->vpd, struct pci_vpd_pci22, base);
 	u32 val;
-	int ret;
+	int ret = 0;
 
 	if (pos < 0 || pos > vpd->base.len || pos & 3 ||
 	    size > vpd->base.len - pos || size < 4)
@@ -231,7 +241,8 @@ static int pci_vpd_pci22_write(struct pc
 	val |= ((u8) *buf++) << 16;
 	val |= ((u32)(u8) *buf++) << 24;
 
-	spin_lock_irq(&vpd->lock);
+	if (mutex_lock_killable(&vpd->lock))
+		return -EINTR;
 	ret = pci_vpd_pci22_wait(dev);
 	if (ret < 0)
 		goto out;
@@ -247,7 +258,7 @@ static int pci_vpd_pci22_write(struct pc
 	vpd->flag = 0;
 	ret = pci_vpd_pci22_wait(dev);
 out:
-	spin_unlock_irq(&vpd->lock);
+	mutex_unlock(&vpd->lock);
 	if (ret < 0)
 		return ret;
 
@@ -279,7 +290,7 @@ int pci_vpd_pci22_init(struct pci_dev *d
 
 	vpd->base.len = PCI_VPD_PCI22_SIZE;
 	vpd->base.ops = &pci_vpd_pci22_ops;
-	spin_lock_init(&vpd->lock);
+	mutex_init(&vpd->lock);
 	vpd->cap = cap;
 	vpd->busy = false;
 	dev->vpd = &vpd->base;

-- 
