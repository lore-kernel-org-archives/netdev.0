From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] pci: VPD access timeout increase
Date: Wed, 3 Sep 2008 15:57:13 -0700
Message-ID: <20080903155713.7fab2e19@extreme>
References: <20080827204626.4b65862f@extreme>
 <20080828111323.GI7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20080828111323.GI7908@solarflare.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Accessing the VPD area can take a long time. There are comments in the
SysKonnect vendor driver that it can take up to 25ms.  The existing vpd
access code fails consistently on my hardware.

Change the access routines to:
  * use a mutex rather than spinning with IRQ's disabled and lock held
  * have a longer timeout
  * call schedule while spinning to provide some responsivness

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/pci/access.c	2008-09-02 10:42:12.000000000 -0700
+++ b/drivers/pci/access.c	2008-09-03 08:47:49.000000000 -0700
@@ -133,7 +133,7 @@ PCI_USER_WRITE_CONFIG(dword, u32)
 
 struct pci_vpd_pci22 {
 	struct pci_vpd base;
-	spinlock_t lock; /* controls access to hardware and the flags */
+	struct mutex lock;
 	u8	cap;
 	bool	busy;
 	bool	flag; /* value of F bit to wait for */
@@ -144,29 +144,30 @@ static int pci_vpd_pci22_wait(struct pci
 {
 	struct pci_vpd_pci22 *vpd =
 		container_of(dev->vpd, struct pci_vpd_pci22, base);
-	u16 flag, status;
-	int wait;
+	u16 flag = vpd->flag ? PCI_VPD_ADDR_F : 0;
+	unsigned long timeout = jiffies + (vpd->flag ? HZ/50 : HZ/10);
+	u16 status;
 	int ret;
 
 	if (!vpd->busy)
 		return 0;
 
-	flag = vpd->flag ? PCI_VPD_ADDR_F : 0;
-	wait = vpd->flag ? 10 : 1000; /* read: 100 us; write: 10 ms */
-	for (;;) {
-		ret = pci_user_read_config_word(dev,
-						vpd->cap + PCI_VPD_ADDR,
-						&status);
-		if (ret < 0)
-			return ret;
+	while ( (ret = pci_user_read_config_word(dev,
+						 vpd->cap + PCI_VPD_ADDR,
+						 &status)) == 0) {
 		if ((status & PCI_VPD_ADDR_F) == flag) {
 			vpd->busy = false;
-			return 0;
+			break;
 		}
-		if (wait-- == 0)
+
+		if (time_after(jiffies, timeout))
 			return -ETIMEDOUT;
-		udelay(10);
+		if (signal_pending(current))
+			return -EINTR;
+		schedule();
 	}
+
+	return ret;
 }
 
 static int pci_vpd_pci22_read(struct pci_dev *dev, int pos, int size,
@@ -183,7 +184,7 @@ static int pci_vpd_pci22_read(struct pci
 	if (size == 0)
 		return 0;
 
-	spin_lock_irq(&vpd->lock);
+	mutex_lock(&vpd->lock);
 	ret = pci_vpd_pci22_wait(dev);
 	if (ret < 0)
 		goto out;
@@ -199,7 +200,7 @@ static int pci_vpd_pci22_read(struct pci
 	ret = pci_user_read_config_dword(dev, vpd->cap + PCI_VPD_DATA,
 					 &val);
 out:
-	spin_unlock_irq(&vpd->lock);
+	mutex_unlock(&vpd->lock);
 	if (ret < 0)
 		return ret;
 
@@ -231,7 +232,7 @@ static int pci_vpd_pci22_write(struct pc
 	val |= ((u8) *buf++) << 16;
 	val |= ((u32)(u8) *buf++) << 24;
 
-	spin_lock_irq(&vpd->lock);
+	mutex_lock(&vpd->lock);
 	ret = pci_vpd_pci22_wait(dev);
 	if (ret < 0)
 		goto out;
@@ -247,7 +248,7 @@ static int pci_vpd_pci22_write(struct pc
 	vpd->flag = 0;
 	ret = pci_vpd_pci22_wait(dev);
 out:
-	spin_unlock_irq(&vpd->lock);
+	mutex_unlock(&vpd->lock);
 	if (ret < 0)
 		return ret;
 
@@ -279,7 +280,7 @@ int pci_vpd_pci22_init(struct pci_dev *d
 
 	vpd->base.len = PCI_VPD_PCI22_SIZE;
 	vpd->base.ops = &pci_vpd_pci22_ops;
-	spin_lock_init(&vpd->lock);
+	mutex_init(&vpd->lock);
 	vpd->cap = cap;
 	vpd->busy = false;
 	dev->vpd = &vpd->base;
