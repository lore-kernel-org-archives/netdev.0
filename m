From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: Intel 82559 NIC corrupted EEPROM
Date: Tue, 13 Feb 2007 11:45:37 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5201E1D1D0@orsmsx418.amr.corp.intel.com>
References: <45C9B2BB.3010404@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C74FA7.89B22D54"
Cc: <jesse.brandeburg@gmail.com>, <netdev@vger.kernel.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <bunk@stusta.de>,
	<jgarzik@pobox.com>, <saw@saw.sw.com.sg>
To: "John" <linux.kernel@free.fr>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:34712 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbXBMTpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:45:46 -0500
Content-class: urn:content-classes:message
In-Reply-To: <45C9B2BB.3010404@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C74FA7.89B22D54
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

John wrote:
> Jesse Brandeburg wrote:
>> What would you like to do?  At this stage I would like e100 to work
>> better than it is, but I'm not sure what to do next.
>=20
> Hello everyone,
>=20
> I'm resurrecting this thread because it appears we'll need to support
> these motherboards for several months to come, yet Adrian Bunk has
> scheduled the removal of eepro100 in January 2007.
>=20
> To recap, we have to support ~30 EBC-2000T motherboards.
> http://www.adlinktech.com/PD/web/PD_detail.php?pid=3D213
> These motherboards come with three on-board Intel 82559 NICs.
>=20
> Last time I checked, i.e. two months ago, e100 did not correctly
> initialize all three NICs on these motherboards. Therefore, we've been
> using eepro100.
>=20
> I will be testing the latest 2.6.20 kernel to see if the situation has
> changed, but I wanted to let you all know that there are still some
> eepro100 users out there, out of necessity.

John, I've made this patch against 2.6.20 to enable IO access for e100,
in the hope it might change something with the timings. I smoke tested
it against one e100 in one of my machines, and I disabled the Mem bit in
the COMMAND register after loading the driver to make sure that it
wasn't using memory access to the registers.

Please test with insmod e100.ko use_io=3D1

The patch is actually short, considering the magnitude of the change,
its inline and attached in case my mailer corrupts it.

Please let me know if it changes something, I still believe this is
something very specific to your systems (or more likely the eeprom on
your systems)

=3D=3D begin patch =3D=3D

e100: try using io only
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e100.c |   74
++++++++++++++++++++++++++++------------------------
 1 files changed, 40 insertions(+), 34 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 0cefef5..df3d2e7 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -159,7 +159,7 @@ #include <asm/unaligned.h>
=20
 #define DRV_NAME		"e100"
 #define DRV_EXT			"-NAPI"
-#define DRV_VERSION		"3.5.17-k2"DRV_EXT
+#define DRV_VERSION		"3.5.17-k2_iodebug"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network
Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2006 Intel
Corporation"
 #define PFX			DRV_NAME ": "
@@ -174,10 +174,13 @@ MODULE_VERSION(DRV_VERSION);
=20
 static int debug =3D 3;
 static int eeprom_bad_csum_allow =3D 0;
+static int use_io =3D 0;
 module_param(debug, int, 0);
 module_param(eeprom_bad_csum_allow, int, 0);
+module_param(use_io, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
 MODULE_PARM_DESC(eeprom_bad_csum_allow, "Allow bad eeprom checksums");
+MODULE_PARM_DESC(use_io, "Force use of i/o access mode");
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	(void)((NETIF_MSG_##nlevel & nic->msg_enable) && \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, nic->netdev->name, \
@@ -591,7 +594,7 @@ static inline void e100_write_flush(stru
 {
 	/* Flush previous PCI writes through intermediate bridges
 	 * by doing a benign read */
-	(void)readb(&nic->csr->scb.status);
+	(void)ioread8(&nic->csr->scb.status);
 }
=20
 static void e100_enable_irq(struct nic *nic)
@@ -599,7 +602,7 @@ static void e100_enable_irq(struct nic *
 	unsigned long flags;
=20
 	spin_lock_irqsave(&nic->cmd_lock, flags);
-	writeb(irq_mask_none, &nic->csr->scb.cmd_hi);
+	iowrite8(irq_mask_none, &nic->csr->scb.cmd_hi);
 	e100_write_flush(nic);
 	spin_unlock_irqrestore(&nic->cmd_lock, flags);
 }
@@ -609,7 +612,7 @@ static void e100_disable_irq(struct nic=20
 	unsigned long flags;
=20
 	spin_lock_irqsave(&nic->cmd_lock, flags);
-	writeb(irq_mask_all, &nic->csr->scb.cmd_hi);
+	iowrite8(irq_mask_all, &nic->csr->scb.cmd_hi);
 	e100_write_flush(nic);
 	spin_unlock_irqrestore(&nic->cmd_lock, flags);
 }
@@ -618,11 +621,11 @@ static void e100_hw_reset(struct nic *ni
 {
 	/* Put CU and RU into idle with a selective reset to get
 	 * device off of PCI bus */
-	writel(selective_reset, &nic->csr->port);
+	iowrite32(selective_reset, &nic->csr->port);
 	e100_write_flush(nic); udelay(20);
=20
 	/* Now fully reset device */
-	writel(software_reset, &nic->csr->port);
+	iowrite32(software_reset, &nic->csr->port);
 	e100_write_flush(nic); udelay(20);
=20
 	/* Mask off our interrupt line - it's unmasked after reset */
@@ -639,7 +642,7 @@ static int e100_self_test(struct nic *ni
 	nic->mem->selftest.signature =3D 0;
 	nic->mem->selftest.result =3D 0xFFFFFFFF;
=20
-	writel(selftest | dma_addr, &nic->csr->port);
+	iowrite32(selftest | dma_addr, &nic->csr->port);
 	e100_write_flush(nic);
 	/* Wait 10 msec for self-test to complete */
 	msleep(10);
@@ -677,23 +680,23 @@ static void e100_eeprom_write(struct nic
 	for(j =3D 0; j < 3; j++) {
=20
 		/* Chip select */
-		writeb(eecs | eesk, &nic->csr->eeprom_ctrl_lo);
+		iowrite8(eecs | eesk, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
=20
 		for(i =3D 31; i >=3D 0; i--) {
 			ctrl =3D (cmd_addr_data[j] & (1 << i)) ?
 				eecs | eedi : eecs;
-			writeb(ctrl, &nic->csr->eeprom_ctrl_lo);
+			iowrite8(ctrl, &nic->csr->eeprom_ctrl_lo);
 			e100_write_flush(nic); udelay(4);
=20
-			writeb(ctrl | eesk, &nic->csr->eeprom_ctrl_lo);
+			iowrite8(ctrl | eesk,
&nic->csr->eeprom_ctrl_lo);
 			e100_write_flush(nic); udelay(4);
 		}
 		/* Wait 10 msec for cmd to complete */
 		msleep(10);
=20
 		/* Chip deselect */
-		writeb(0, &nic->csr->eeprom_ctrl_lo);
+		iowrite8(0, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
 	}
 };
@@ -709,21 +712,21 @@ static u16 e100_eeprom_read(struct nic *
 	cmd_addr_data =3D ((op_read << *addr_len) | addr) << 16;
=20
 	/* Chip select */
-	writeb(eecs | eesk, &nic->csr->eeprom_ctrl_lo);
+	iowrite8(eecs | eesk, &nic->csr->eeprom_ctrl_lo);
 	e100_write_flush(nic); udelay(4);
=20
 	/* Bit-bang to read word from eeprom */
 	for(i =3D 31; i >=3D 0; i--) {
 		ctrl =3D (cmd_addr_data & (1 << i)) ? eecs | eedi : eecs;
-		writeb(ctrl, &nic->csr->eeprom_ctrl_lo);
+		iowrite8(ctrl, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
=20
-		writeb(ctrl | eesk, &nic->csr->eeprom_ctrl_lo);
+		iowrite8(ctrl | eesk, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
=20
 		/* Eeprom drives a dummy zero to EEDO after receiving
 		 * complete address.  Use this to adjust addr_len. */
-		ctrl =3D readb(&nic->csr->eeprom_ctrl_lo);
+		ctrl =3D ioread8(&nic->csr->eeprom_ctrl_lo);
 		if(!(ctrl & eedo) && i > 16) {
 			*addr_len -=3D (i - 16);
 			i =3D 17;
@@ -733,7 +736,7 @@ static u16 e100_eeprom_read(struct nic *
 	}
=20
 	/* Chip deselect */
-	writeb(0, &nic->csr->eeprom_ctrl_lo);
+	iowrite8(0, &nic->csr->eeprom_ctrl_lo);
 	e100_write_flush(nic); udelay(4);
=20
 	return le16_to_cpu(data);
@@ -804,7 +807,7 @@ static int e100_exec_cmd(struct nic *nic
=20
 	/* Previous command is accepted when SCB clears */
 	for(i =3D 0; i < E100_WAIT_SCB_TIMEOUT; i++) {
-		if(likely(!readb(&nic->csr->scb.cmd_lo)))
+		if(likely(!ioread8(&nic->csr->scb.cmd_lo)))
 			break;
 		cpu_relax();
 		if(unlikely(i > E100_WAIT_SCB_FAST))
@@ -816,8 +819,8 @@ static int e100_exec_cmd(struct nic *nic
 	}
=20
 	if(unlikely(cmd !=3D cuc_resume))
-		writel(dma_addr, &nic->csr->scb.gen_ptr);
-	writeb(cmd, &nic->csr->scb.cmd_lo);
+		iowrite32(dma_addr, &nic->csr->scb.gen_ptr);
+	iowrite8(cmd, &nic->csr->scb.cmd_lo);
=20
 err_unlock:
 	spin_unlock_irqrestore(&nic->cmd_lock, flags);
@@ -895,7 +898,7 @@ static u16 mdio_ctrl(struct nic *nic, u3
 	 */
 	spin_lock_irqsave(&nic->mdio_lock, flags);
 	for (i =3D 100; i; --i) {
-		if (readl(&nic->csr->mdi_ctrl) & mdi_ready)
+		if (ioread32(&nic->csr->mdi_ctrl) & mdi_ready)
 			break;
 		udelay(20);
 	}
@@ -905,11 +908,11 @@ static u16 mdio_ctrl(struct nic *nic, u3
 		spin_unlock_irqrestore(&nic->mdio_lock, flags);
 		return 0;		/* No way to indicate timeout
error */
 	}
-	writel((reg << 16) | (addr << 21) | dir | data,
&nic->csr->mdi_ctrl);
+	iowrite32((reg << 16) | (addr << 21) | dir | data,
&nic->csr->mdi_ctrl);
=20
 	for (i =3D 0; i < 100; i++) {
 		udelay(20);
-		if ((data_out =3D readl(&nic->csr->mdi_ctrl)) & mdi_ready)
+		if ((data_out =3D ioread32(&nic->csr->mdi_ctrl)) &
mdi_ready)
 			break;
 	}
 	spin_unlock_irqrestore(&nic->mdio_lock, flags);
@@ -1318,7 +1321,7 @@ static inline int e100_exec_cb_wait(stru
 	}
=20
 	/* ack any interupts, something could have been set */
-	writeb(~0, &nic->csr->scb.stat_ack);
+	iowrite8(~0, &nic->csr->scb.stat_ack);
=20
 	/* if the command failed, or is not OK, notify and return */
 	if (!counter || !(cb->status & cpu_to_le16(cb_ok))) {
@@ -1580,7 +1583,7 @@ static void e100_watchdog(unsigned long=20
 	 * accidentally, due to hardware that shares a register between
the
 	 * interrupt mask bit and the SW Interrupt generation bit */
 	spin_lock_irq(&nic->cmd_lock);
-	writeb(readb(&nic->csr->scb.cmd_hi) |
irq_sw_gen,&nic->csr->scb.cmd_hi);
+	iowrite8(ioread8(&nic->csr->scb.cmd_hi) |
irq_sw_gen,&nic->csr->scb.cmd_hi);
 	e100_write_flush(nic);
 	spin_unlock_irq(&nic->cmd_lock);
=20
@@ -1893,7 +1896,7 @@ static void e100_rx_clean(struct nic *ni
=20
 	if(restart_required) {
 		// ack the rnr?
-		writeb(stat_ack_rnr, &nic->csr->scb.stat_ack);
+		iowrite8(stat_ack_rnr, &nic->csr->scb.stat_ack);
 		e100_start_receiver(nic, rx_to_start);
 		if(work_done)
 			(*work_done)++;
@@ -1952,7 +1955,7 @@ static irqreturn_t e100_intr(int irq, vo
 {
 	struct net_device *netdev =3D dev_id;
 	struct nic *nic =3D netdev_priv(netdev);
-	u8 stat_ack =3D readb(&nic->csr->scb.stat_ack);
+	u8 stat_ack =3D ioread8(&nic->csr->scb.stat_ack);
=20
 	DPRINTK(INTR, DEBUG, "stat_ack =3D 0x%02X\n", stat_ack);
=20
@@ -1961,7 +1964,7 @@ static irqreturn_t e100_intr(int irq, vo
 		return IRQ_NONE;
=20
 	/* Ack interrupt(s) */
-	writeb(stat_ack, &nic->csr->scb.stat_ack);
+	iowrite8(stat_ack, &nic->csr->scb.stat_ack);
=20
 	/* We hit Receive No Resource (RNR); restart RU after cleaning
*/
 	if(stat_ack & stat_ack_rnr)
@@ -2107,7 +2110,7 @@ static void e100_tx_timeout_task(struct=20
 	struct net_device *netdev =3D nic->netdev;
=20
 	DPRINTK(TX_ERR, DEBUG, "scb.status=3D0x%02X\n",
-		readb(&nic->csr->scb.status));
+		ioread8(&nic->csr->scb.status));
 	e100_down(netdev_priv(netdev));
 	e100_up(netdev_priv(netdev));
 }
@@ -2230,9 +2233,9 @@ static void e100_get_regs(struct net_dev
 	int i;
=20
 	regs->version =3D (1 << 24) | nic->rev_id;
-	buff[0] =3D readb(&nic->csr->scb.cmd_hi) << 24 |
-		readb(&nic->csr->scb.cmd_lo) << 16 |
-		readw(&nic->csr->scb.status);
+	buff[0] =3D ioread8(&nic->csr->scb.cmd_hi) << 24 |
+		ioread8(&nic->csr->scb.cmd_lo) << 16 |
+		ioread16(&nic->csr->scb.status);
 	for(i =3D E100_PHY_REGS; i >=3D 0; i--)
 		buff[1 + E100_PHY_REGS - i] =3D
 			mdio_read(netdev, nic->mii.phy_id, i);
@@ -2604,7 +2607,10 @@ #endif
 	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
=20
-	nic->csr =3D ioremap(pci_resource_start(pdev, 0), sizeof(struct
csr));
+	if (use_io)
+		DPRINTK(PROBE, INFO, "using i/o access mode\n");
+
+	nic->csr =3D pci_iomap(pdev, (use_io ? 1 : 0), sizeof(struct
csr));
 	if(!nic->csr) {
 		DPRINTK(PROBE, ERR, "Cannot map device registers,
aborting.\n");
 		err =3D -ENOMEM;
@@ -2676,7 +2682,7 @@ #endif
=20
 	DPRINTK(PROBE, INFO, "addr 0x%llx, irq %d, "
 		"MAC addr %02X:%02X:%02X:%02X:%02X:%02X\n",
-		(unsigned long long)pci_resource_start(pdev, 0),
pdev->irq,
+		(unsigned long long)pci_resource_start(pdev, use_io ? 1
: 0), pdev->irq,
 		netdev->dev_addr[0], netdev->dev_addr[1],
netdev->dev_addr[2],
 		netdev->dev_addr[3], netdev->dev_addr[4],
netdev->dev_addr[5]);
=20
@@ -2685,7 +2691,7 @@ #endif
 err_out_free:
 	e100_free(nic);
 err_out_iounmap:
-	iounmap(nic->csr);
+	pci_iounmap(pdev, nic->csr);
 err_out_free_res:
 	pci_release_regions(pdev);
 err_out_disable_pdev:


------_=_NextPart_001_01C74FA7.89B22D54
Content-Type: application/octet-stream;
	name="e100_io_enable.patch"
Content-Transfer-Encoding: base64
Content-Description: e100_io_enable.patch
Content-Disposition: attachment;
	filename="e100_io_enable.patch"

ZTEwMDogdHJ5IHVzaW5nIGlvIG9ubHkKCkZyb206ICA8PgoKU2lnbmVkLW9mZi1ieTogSmVzc2Ug
QnJhbmRlYnVyZyA8amVzc2UuYnJhbmRlYnVyZ0BpbnRlbC5jb20+Ci0tLQoKIGRyaXZlcnMvbmV0
L2UxMDAuYyB8ICAgNzQgKysrKysrKysrKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLQogMSBmaWxlcyBjaGFuZ2VkLCA0MCBpbnNlcnRpb25zKCspLCAzNCBkZWxldGlv
bnMoLSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9lMTAwLmMgYi9kcml2ZXJzL25ldC9lMTAw
LmMKaW5kZXggMGNlZmVmNS4uZGYzZDJlNyAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvZTEwMC5j
CisrKyBiL2RyaXZlcnMvbmV0L2UxMDAuYwpAQCAtMTU5LDcgKzE1OSw3IEBAICNpbmNsdWRlIDxh
c20vdW5hbGlnbmVkLmg+CiAKICNkZWZpbmUgRFJWX05BTUUJCSJlMTAwIgogI2RlZmluZSBEUlZf
RVhUCQkJIi1OQVBJIgotI2RlZmluZSBEUlZfVkVSU0lPTgkJIjMuNS4xNy1rMiJEUlZfRVhUCisj
ZGVmaW5lIERSVl9WRVJTSU9OCQkiMy41LjE3LWsyX2lvZGVidWciRFJWX0VYVAogI2RlZmluZSBE
UlZfREVTQ1JJUFRJT04JCSJJbnRlbChSKSBQUk8vMTAwIE5ldHdvcmsgRHJpdmVyIgogI2RlZmlu
ZSBEUlZfQ09QWVJJR0hUCQkiQ29weXJpZ2h0KGMpIDE5OTktMjAwNiBJbnRlbCBDb3Jwb3JhdGlv
biIKICNkZWZpbmUgUEZYCQkJRFJWX05BTUUgIjogIgpAQCAtMTc0LDEwICsxNzQsMTMgQEAgTU9E
VUxFX1ZFUlNJT04oRFJWX1ZFUlNJT04pOwogCiBzdGF0aWMgaW50IGRlYnVnID0gMzsKIHN0YXRp
YyBpbnQgZWVwcm9tX2JhZF9jc3VtX2FsbG93ID0gMDsKK3N0YXRpYyBpbnQgdXNlX2lvID0gMDsK
IG1vZHVsZV9wYXJhbShkZWJ1ZywgaW50LCAwKTsKIG1vZHVsZV9wYXJhbShlZXByb21fYmFkX2Nz
dW1fYWxsb3csIGludCwgMCk7Cittb2R1bGVfcGFyYW0odXNlX2lvLCBpbnQsIDApOwogTU9EVUxF
X1BBUk1fREVTQyhkZWJ1ZywgIkRlYnVnIGxldmVsICgwPW5vbmUsLi4uLDE2PWFsbCkiKTsKIE1P
RFVMRV9QQVJNX0RFU0MoZWVwcm9tX2JhZF9jc3VtX2FsbG93LCAiQWxsb3cgYmFkIGVlcHJvbSBj
aGVja3N1bXMiKTsKK01PRFVMRV9QQVJNX0RFU0ModXNlX2lvLCAiRm9yY2UgdXNlIG9mIGkvbyBh
Y2Nlc3MgbW9kZSIpOwogI2RlZmluZSBEUFJJTlRLKG5sZXZlbCwga2xldmVsLCBmbXQsIGFyZ3Mu
Li4pIFwKIAkodm9pZCkoKE5FVElGX01TR18jI25sZXZlbCAmIG5pYy0+bXNnX2VuYWJsZSkgJiYg
XAogCXByaW50ayhLRVJOXyMja2xldmVsIFBGWCAiJXM6ICVzOiAiIGZtdCwgbmljLT5uZXRkZXYt
Pm5hbWUsIFwKQEAgLTU5MSw3ICs1OTQsNyBAQCBzdGF0aWMgaW5saW5lIHZvaWQgZTEwMF93cml0
ZV9mbHVzaChzdHJ1CiB7CiAJLyogRmx1c2ggcHJldmlvdXMgUENJIHdyaXRlcyB0aHJvdWdoIGlu
dGVybWVkaWF0ZSBicmlkZ2VzCiAJICogYnkgZG9pbmcgYSBiZW5pZ24gcmVhZCAqLwotCSh2b2lk
KXJlYWRiKCZuaWMtPmNzci0+c2NiLnN0YXR1cyk7CisJKHZvaWQpaW9yZWFkOCgmbmljLT5jc3It
PnNjYi5zdGF0dXMpOwogfQogCiBzdGF0aWMgdm9pZCBlMTAwX2VuYWJsZV9pcnEoc3RydWN0IG5p
YyAqbmljKQpAQCAtNTk5LDcgKzYwMiw3IEBAIHN0YXRpYyB2b2lkIGUxMDBfZW5hYmxlX2lycShz
dHJ1Y3QgbmljICoKIAl1bnNpZ25lZCBsb25nIGZsYWdzOwogCiAJc3Bpbl9sb2NrX2lycXNhdmUo
Jm5pYy0+Y21kX2xvY2ssIGZsYWdzKTsKLQl3cml0ZWIoaXJxX21hc2tfbm9uZSwgJm5pYy0+Y3Ny
LT5zY2IuY21kX2hpKTsKKwlpb3dyaXRlOChpcnFfbWFza19ub25lLCAmbmljLT5jc3ItPnNjYi5j
bWRfaGkpOwogCWUxMDBfd3JpdGVfZmx1c2gobmljKTsKIAlzcGluX3VubG9ja19pcnFyZXN0b3Jl
KCZuaWMtPmNtZF9sb2NrLCBmbGFncyk7CiB9CkBAIC02MDksNyArNjEyLDcgQEAgc3RhdGljIHZv
aWQgZTEwMF9kaXNhYmxlX2lycShzdHJ1Y3QgbmljIAogCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAK
IAlzcGluX2xvY2tfaXJxc2F2ZSgmbmljLT5jbWRfbG9jaywgZmxhZ3MpOwotCXdyaXRlYihpcnFf
bWFza19hbGwsICZuaWMtPmNzci0+c2NiLmNtZF9oaSk7CisJaW93cml0ZTgoaXJxX21hc2tfYWxs
LCAmbmljLT5jc3ItPnNjYi5jbWRfaGkpOwogCWUxMDBfd3JpdGVfZmx1c2gobmljKTsKIAlzcGlu
X3VubG9ja19pcnFyZXN0b3JlKCZuaWMtPmNtZF9sb2NrLCBmbGFncyk7CiB9CkBAIC02MTgsMTEg
KzYyMSwxMSBAQCBzdGF0aWMgdm9pZCBlMTAwX2h3X3Jlc2V0KHN0cnVjdCBuaWMgKm5pCiB7CiAJ
LyogUHV0IENVIGFuZCBSVSBpbnRvIGlkbGUgd2l0aCBhIHNlbGVjdGl2ZSByZXNldCB0byBnZXQK
IAkgKiBkZXZpY2Ugb2ZmIG9mIFBDSSBidXMgKi8KLQl3cml0ZWwoc2VsZWN0aXZlX3Jlc2V0LCAm
bmljLT5jc3ItPnBvcnQpOworCWlvd3JpdGUzMihzZWxlY3RpdmVfcmVzZXQsICZuaWMtPmNzci0+
cG9ydCk7CiAJZTEwMF93cml0ZV9mbHVzaChuaWMpOyB1ZGVsYXkoMjApOwogCiAJLyogTm93IGZ1
bGx5IHJlc2V0IGRldmljZSAqLwotCXdyaXRlbChzb2Z0d2FyZV9yZXNldCwgJm5pYy0+Y3NyLT5w
b3J0KTsKKwlpb3dyaXRlMzIoc29mdHdhcmVfcmVzZXQsICZuaWMtPmNzci0+cG9ydCk7CiAJZTEw
MF93cml0ZV9mbHVzaChuaWMpOyB1ZGVsYXkoMjApOwogCiAJLyogTWFzayBvZmYgb3VyIGludGVy
cnVwdCBsaW5lIC0gaXQncyB1bm1hc2tlZCBhZnRlciByZXNldCAqLwpAQCAtNjM5LDcgKzY0Miw3
IEBAIHN0YXRpYyBpbnQgZTEwMF9zZWxmX3Rlc3Qoc3RydWN0IG5pYyAqbmkKIAluaWMtPm1lbS0+
c2VsZnRlc3Quc2lnbmF0dXJlID0gMDsKIAluaWMtPm1lbS0+c2VsZnRlc3QucmVzdWx0ID0gMHhG
RkZGRkZGRjsKIAotCXdyaXRlbChzZWxmdGVzdCB8IGRtYV9hZGRyLCAmbmljLT5jc3ItPnBvcnQp
OworCWlvd3JpdGUzMihzZWxmdGVzdCB8IGRtYV9hZGRyLCAmbmljLT5jc3ItPnBvcnQpOwogCWUx
MDBfd3JpdGVfZmx1c2gobmljKTsKIAkvKiBXYWl0IDEwIG1zZWMgZm9yIHNlbGYtdGVzdCB0byBj
b21wbGV0ZSAqLwogCW1zbGVlcCgxMCk7CkBAIC02NzcsMjMgKzY4MCwyMyBAQCBzdGF0aWMgdm9p
ZCBlMTAwX2VlcHJvbV93cml0ZShzdHJ1Y3QgbmljCiAJZm9yKGogPSAwOyBqIDwgMzsgaisrKSB7
CiAKIAkJLyogQ2hpcCBzZWxlY3QgKi8KLQkJd3JpdGViKGVlY3MgfCBlZXNrLCAmbmljLT5jc3It
PmVlcHJvbV9jdHJsX2xvKTsKKwkJaW93cml0ZTgoZWVjcyB8IGVlc2ssICZuaWMtPmNzci0+ZWVw
cm9tX2N0cmxfbG8pOwogCQllMTAwX3dyaXRlX2ZsdXNoKG5pYyk7IHVkZWxheSg0KTsKIAogCQlm
b3IoaSA9IDMxOyBpID49IDA7IGktLSkgewogCQkJY3RybCA9IChjbWRfYWRkcl9kYXRhW2pdICYg
KDEgPDwgaSkpID8KIAkJCQllZWNzIHwgZWVkaSA6IGVlY3M7Ci0JCQl3cml0ZWIoY3RybCwgJm5p
Yy0+Y3NyLT5lZXByb21fY3RybF9sbyk7CisJCQlpb3dyaXRlOChjdHJsLCAmbmljLT5jc3ItPmVl
cHJvbV9jdHJsX2xvKTsKIAkJCWUxMDBfd3JpdGVfZmx1c2gobmljKTsgdWRlbGF5KDQpOwogCi0J
CQl3cml0ZWIoY3RybCB8IGVlc2ssICZuaWMtPmNzci0+ZWVwcm9tX2N0cmxfbG8pOworCQkJaW93
cml0ZTgoY3RybCB8IGVlc2ssICZuaWMtPmNzci0+ZWVwcm9tX2N0cmxfbG8pOwogCQkJZTEwMF93
cml0ZV9mbHVzaChuaWMpOyB1ZGVsYXkoNCk7CiAJCX0KIAkJLyogV2FpdCAxMCBtc2VjIGZvciBj
bWQgdG8gY29tcGxldGUgKi8KIAkJbXNsZWVwKDEwKTsKIAogCQkvKiBDaGlwIGRlc2VsZWN0ICov
Ci0JCXdyaXRlYigwLCAmbmljLT5jc3ItPmVlcHJvbV9jdHJsX2xvKTsKKwkJaW93cml0ZTgoMCwg
Jm5pYy0+Y3NyLT5lZXByb21fY3RybF9sbyk7CiAJCWUxMDBfd3JpdGVfZmx1c2gobmljKTsgdWRl
bGF5KDQpOwogCX0KIH07CkBAIC03MDksMjEgKzcxMiwyMSBAQCBzdGF0aWMgdTE2IGUxMDBfZWVw
cm9tX3JlYWQoc3RydWN0IG5pYyAqCiAJY21kX2FkZHJfZGF0YSA9ICgob3BfcmVhZCA8PCAqYWRk
cl9sZW4pIHwgYWRkcikgPDwgMTY7CiAKIAkvKiBDaGlwIHNlbGVjdCAqLwotCXdyaXRlYihlZWNz
IHwgZWVzaywgJm5pYy0+Y3NyLT5lZXByb21fY3RybF9sbyk7CisJaW93cml0ZTgoZWVjcyB8IGVl
c2ssICZuaWMtPmNzci0+ZWVwcm9tX2N0cmxfbG8pOwogCWUxMDBfd3JpdGVfZmx1c2gobmljKTsg
dWRlbGF5KDQpOwogCiAJLyogQml0LWJhbmcgdG8gcmVhZCB3b3JkIGZyb20gZWVwcm9tICovCiAJ
Zm9yKGkgPSAzMTsgaSA+PSAwOyBpLS0pIHsKIAkJY3RybCA9IChjbWRfYWRkcl9kYXRhICYgKDEg
PDwgaSkpID8gZWVjcyB8IGVlZGkgOiBlZWNzOwotCQl3cml0ZWIoY3RybCwgJm5pYy0+Y3NyLT5l
ZXByb21fY3RybF9sbyk7CisJCWlvd3JpdGU4KGN0cmwsICZuaWMtPmNzci0+ZWVwcm9tX2N0cmxf
bG8pOwogCQllMTAwX3dyaXRlX2ZsdXNoKG5pYyk7IHVkZWxheSg0KTsKIAotCQl3cml0ZWIoY3Ry
bCB8IGVlc2ssICZuaWMtPmNzci0+ZWVwcm9tX2N0cmxfbG8pOworCQlpb3dyaXRlOChjdHJsIHwg
ZWVzaywgJm5pYy0+Y3NyLT5lZXByb21fY3RybF9sbyk7CiAJCWUxMDBfd3JpdGVfZmx1c2gobmlj
KTsgdWRlbGF5KDQpOwogCiAJCS8qIEVlcHJvbSBkcml2ZXMgYSBkdW1teSB6ZXJvIHRvIEVFRE8g
YWZ0ZXIgcmVjZWl2aW5nCiAJCSAqIGNvbXBsZXRlIGFkZHJlc3MuICBVc2UgdGhpcyB0byBhZGp1
c3QgYWRkcl9sZW4uICovCi0JCWN0cmwgPSByZWFkYigmbmljLT5jc3ItPmVlcHJvbV9jdHJsX2xv
KTsKKwkJY3RybCA9IGlvcmVhZDgoJm5pYy0+Y3NyLT5lZXByb21fY3RybF9sbyk7CiAJCWlmKCEo
Y3RybCAmIGVlZG8pICYmIGkgPiAxNikgewogCQkJKmFkZHJfbGVuIC09IChpIC0gMTYpOwogCQkJ
aSA9IDE3OwpAQCAtNzMzLDcgKzczNiw3IEBAIHN0YXRpYyB1MTYgZTEwMF9lZXByb21fcmVhZChz
dHJ1Y3QgbmljICoKIAl9CiAKIAkvKiBDaGlwIGRlc2VsZWN0ICovCi0Jd3JpdGViKDAsICZuaWMt
PmNzci0+ZWVwcm9tX2N0cmxfbG8pOworCWlvd3JpdGU4KDAsICZuaWMtPmNzci0+ZWVwcm9tX2N0
cmxfbG8pOwogCWUxMDBfd3JpdGVfZmx1c2gobmljKTsgdWRlbGF5KDQpOwogCiAJcmV0dXJuIGxl
MTZfdG9fY3B1KGRhdGEpOwpAQCAtODA0LDcgKzgwNyw3IEBAIHN0YXRpYyBpbnQgZTEwMF9leGVj
X2NtZChzdHJ1Y3QgbmljICpuaWMKIAogCS8qIFByZXZpb3VzIGNvbW1hbmQgaXMgYWNjZXB0ZWQg
d2hlbiBTQ0IgY2xlYXJzICovCiAJZm9yKGkgPSAwOyBpIDwgRTEwMF9XQUlUX1NDQl9USU1FT1VU
OyBpKyspIHsKLQkJaWYobGlrZWx5KCFyZWFkYigmbmljLT5jc3ItPnNjYi5jbWRfbG8pKSkKKwkJ
aWYobGlrZWx5KCFpb3JlYWQ4KCZuaWMtPmNzci0+c2NiLmNtZF9sbykpKQogCQkJYnJlYWs7CiAJ
CWNwdV9yZWxheCgpOwogCQlpZih1bmxpa2VseShpID4gRTEwMF9XQUlUX1NDQl9GQVNUKSkKQEAg
LTgxNiw4ICs4MTksOCBAQCBzdGF0aWMgaW50IGUxMDBfZXhlY19jbWQoc3RydWN0IG5pYyAqbmlj
CiAJfQogCiAJaWYodW5saWtlbHkoY21kICE9IGN1Y19yZXN1bWUpKQotCQl3cml0ZWwoZG1hX2Fk
ZHIsICZuaWMtPmNzci0+c2NiLmdlbl9wdHIpOwotCXdyaXRlYihjbWQsICZuaWMtPmNzci0+c2Ni
LmNtZF9sbyk7CisJCWlvd3JpdGUzMihkbWFfYWRkciwgJm5pYy0+Y3NyLT5zY2IuZ2VuX3B0cik7
CisJaW93cml0ZTgoY21kLCAmbmljLT5jc3ItPnNjYi5jbWRfbG8pOwogCiBlcnJfdW5sb2NrOgog
CXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJm5pYy0+Y21kX2xvY2ssIGZsYWdzKTsKQEAgLTg5NSw3
ICs4OTgsNyBAQCBzdGF0aWMgdTE2IG1kaW9fY3RybChzdHJ1Y3QgbmljICpuaWMsIHUzCiAJICov
CiAJc3Bpbl9sb2NrX2lycXNhdmUoJm5pYy0+bWRpb19sb2NrLCBmbGFncyk7CiAJZm9yIChpID0g
MTAwOyBpOyAtLWkpIHsKLQkJaWYgKHJlYWRsKCZuaWMtPmNzci0+bWRpX2N0cmwpICYgbWRpX3Jl
YWR5KQorCQlpZiAoaW9yZWFkMzIoJm5pYy0+Y3NyLT5tZGlfY3RybCkgJiBtZGlfcmVhZHkpCiAJ
CQlicmVhazsKIAkJdWRlbGF5KDIwKTsKIAl9CkBAIC05MDUsMTEgKzkwOCwxMSBAQCBzdGF0aWMg
dTE2IG1kaW9fY3RybChzdHJ1Y3QgbmljICpuaWMsIHUzCiAJCXNwaW5fdW5sb2NrX2lycXJlc3Rv
cmUoJm5pYy0+bWRpb19sb2NrLCBmbGFncyk7CiAJCXJldHVybiAwOwkJLyogTm8gd2F5IHRvIGlu
ZGljYXRlIHRpbWVvdXQgZXJyb3IgKi8KIAl9Ci0Jd3JpdGVsKChyZWcgPDwgMTYpIHwgKGFkZHIg
PDwgMjEpIHwgZGlyIHwgZGF0YSwgJm5pYy0+Y3NyLT5tZGlfY3RybCk7CisJaW93cml0ZTMyKChy
ZWcgPDwgMTYpIHwgKGFkZHIgPDwgMjEpIHwgZGlyIHwgZGF0YSwgJm5pYy0+Y3NyLT5tZGlfY3Ry
bCk7CiAKIAlmb3IgKGkgPSAwOyBpIDwgMTAwOyBpKyspIHsKIAkJdWRlbGF5KDIwKTsKLQkJaWYg
KChkYXRhX291dCA9IHJlYWRsKCZuaWMtPmNzci0+bWRpX2N0cmwpKSAmIG1kaV9yZWFkeSkKKwkJ
aWYgKChkYXRhX291dCA9IGlvcmVhZDMyKCZuaWMtPmNzci0+bWRpX2N0cmwpKSAmIG1kaV9yZWFk
eSkKIAkJCWJyZWFrOwogCX0KIAlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZuaWMtPm1kaW9fbG9j
aywgZmxhZ3MpOwpAQCAtMTMxOCw3ICsxMzIxLDcgQEAgc3RhdGljIGlubGluZSBpbnQgZTEwMF9l
eGVjX2NiX3dhaXQoc3RydQogCX0KIAogCS8qIGFjayBhbnkgaW50ZXJ1cHRzLCBzb21ldGhpbmcg
Y291bGQgaGF2ZSBiZWVuIHNldCAqLwotCXdyaXRlYih+MCwgJm5pYy0+Y3NyLT5zY2Iuc3RhdF9h
Y2spOworCWlvd3JpdGU4KH4wLCAmbmljLT5jc3ItPnNjYi5zdGF0X2Fjayk7CiAKIAkvKiBpZiB0
aGUgY29tbWFuZCBmYWlsZWQsIG9yIGlzIG5vdCBPSywgbm90aWZ5IGFuZCByZXR1cm4gKi8KIAlp
ZiAoIWNvdW50ZXIgfHwgIShjYi0+c3RhdHVzICYgY3B1X3RvX2xlMTYoY2Jfb2spKSkgewpAQCAt
MTU4MCw3ICsxNTgzLDcgQEAgc3RhdGljIHZvaWQgZTEwMF93YXRjaGRvZyh1bnNpZ25lZCBsb25n
IAogCSAqIGFjY2lkZW50YWxseSwgZHVlIHRvIGhhcmR3YXJlIHRoYXQgc2hhcmVzIGEgcmVnaXN0
ZXIgYmV0d2VlbiB0aGUKIAkgKiBpbnRlcnJ1cHQgbWFzayBiaXQgYW5kIHRoZSBTVyBJbnRlcnJ1
cHQgZ2VuZXJhdGlvbiBiaXQgKi8KIAlzcGluX2xvY2tfaXJxKCZuaWMtPmNtZF9sb2NrKTsKLQl3
cml0ZWIocmVhZGIoJm5pYy0+Y3NyLT5zY2IuY21kX2hpKSB8IGlycV9zd19nZW4sJm5pYy0+Y3Ny
LT5zY2IuY21kX2hpKTsKKwlpb3dyaXRlOChpb3JlYWQ4KCZuaWMtPmNzci0+c2NiLmNtZF9oaSkg
fCBpcnFfc3dfZ2VuLCZuaWMtPmNzci0+c2NiLmNtZF9oaSk7CiAJZTEwMF93cml0ZV9mbHVzaChu
aWMpOwogCXNwaW5fdW5sb2NrX2lycSgmbmljLT5jbWRfbG9jayk7CiAKQEAgLTE4OTMsNyArMTg5
Niw3IEBAIHN0YXRpYyB2b2lkIGUxMDBfcnhfY2xlYW4oc3RydWN0IG5pYyAqbmkKIAogCWlmKHJl
c3RhcnRfcmVxdWlyZWQpIHsKIAkJLy8gYWNrIHRoZSBybnI/Ci0JCXdyaXRlYihzdGF0X2Fja19y
bnIsICZuaWMtPmNzci0+c2NiLnN0YXRfYWNrKTsKKwkJaW93cml0ZTgoc3RhdF9hY2tfcm5yLCAm
bmljLT5jc3ItPnNjYi5zdGF0X2Fjayk7CiAJCWUxMDBfc3RhcnRfcmVjZWl2ZXIobmljLCByeF90
b19zdGFydCk7CiAJCWlmKHdvcmtfZG9uZSkKIAkJCSgqd29ya19kb25lKSsrOwpAQCAtMTk1Miw3
ICsxOTU1LDcgQEAgc3RhdGljIGlycXJldHVybl90IGUxMDBfaW50cihpbnQgaXJxLCB2bwogewog
CXN0cnVjdCBuZXRfZGV2aWNlICpuZXRkZXYgPSBkZXZfaWQ7CiAJc3RydWN0IG5pYyAqbmljID0g
bmV0ZGV2X3ByaXYobmV0ZGV2KTsKLQl1OCBzdGF0X2FjayA9IHJlYWRiKCZuaWMtPmNzci0+c2Ni
LnN0YXRfYWNrKTsKKwl1OCBzdGF0X2FjayA9IGlvcmVhZDgoJm5pYy0+Y3NyLT5zY2Iuc3RhdF9h
Y2spOwogCiAJRFBSSU5USyhJTlRSLCBERUJVRywgInN0YXRfYWNrID0gMHglMDJYXG4iLCBzdGF0
X2Fjayk7CiAKQEAgLTE5NjEsNyArMTk2NCw3IEBAIHN0YXRpYyBpcnFyZXR1cm5fdCBlMTAwX2lu
dHIoaW50IGlycSwgdm8KIAkJcmV0dXJuIElSUV9OT05FOwogCiAJLyogQWNrIGludGVycnVwdChz
KSAqLwotCXdyaXRlYihzdGF0X2FjaywgJm5pYy0+Y3NyLT5zY2Iuc3RhdF9hY2spOworCWlvd3Jp
dGU4KHN0YXRfYWNrLCAmbmljLT5jc3ItPnNjYi5zdGF0X2Fjayk7CiAKIAkvKiBXZSBoaXQgUmVj
ZWl2ZSBObyBSZXNvdXJjZSAoUk5SKTsgcmVzdGFydCBSVSBhZnRlciBjbGVhbmluZyAqLwogCWlm
KHN0YXRfYWNrICYgc3RhdF9hY2tfcm5yKQpAQCAtMjEwNyw3ICsyMTEwLDcgQEAgc3RhdGljIHZv
aWQgZTEwMF90eF90aW1lb3V0X3Rhc2soc3RydWN0IAogCXN0cnVjdCBuZXRfZGV2aWNlICpuZXRk
ZXYgPSBuaWMtPm5ldGRldjsKIAogCURQUklOVEsoVFhfRVJSLCBERUJVRywgInNjYi5zdGF0dXM9
MHglMDJYXG4iLAotCQlyZWFkYigmbmljLT5jc3ItPnNjYi5zdGF0dXMpKTsKKwkJaW9yZWFkOCgm
bmljLT5jc3ItPnNjYi5zdGF0dXMpKTsKIAllMTAwX2Rvd24obmV0ZGV2X3ByaXYobmV0ZGV2KSk7
CiAJZTEwMF91cChuZXRkZXZfcHJpdihuZXRkZXYpKTsKIH0KQEAgLTIyMzAsOSArMjIzMyw5IEBA
IHN0YXRpYyB2b2lkIGUxMDBfZ2V0X3JlZ3Moc3RydWN0IG5ldF9kZXYKIAlpbnQgaTsKIAogCXJl
Z3MtPnZlcnNpb24gPSAoMSA8PCAyNCkgfCBuaWMtPnJldl9pZDsKLQlidWZmWzBdID0gcmVhZGIo
Jm5pYy0+Y3NyLT5zY2IuY21kX2hpKSA8PCAyNCB8Ci0JCXJlYWRiKCZuaWMtPmNzci0+c2NiLmNt
ZF9sbykgPDwgMTYgfAotCQlyZWFkdygmbmljLT5jc3ItPnNjYi5zdGF0dXMpOworCWJ1ZmZbMF0g
PSBpb3JlYWQ4KCZuaWMtPmNzci0+c2NiLmNtZF9oaSkgPDwgMjQgfAorCQlpb3JlYWQ4KCZuaWMt
PmNzci0+c2NiLmNtZF9sbykgPDwgMTYgfAorCQlpb3JlYWQxNigmbmljLT5jc3ItPnNjYi5zdGF0
dXMpOwogCWZvcihpID0gRTEwMF9QSFlfUkVHUzsgaSA+PSAwOyBpLS0pCiAJCWJ1ZmZbMSArIEUx
MDBfUEhZX1JFR1MgLSBpXSA9CiAJCQltZGlvX3JlYWQobmV0ZGV2LCBuaWMtPm1paS5waHlfaWQs
IGkpOwpAQCAtMjYwNCw3ICsyNjA3LDEwIEBAICNlbmRpZgogCVNFVF9NT0RVTEVfT1dORVIobmV0
ZGV2KTsKIAlTRVRfTkVUREVWX0RFVihuZXRkZXYsICZwZGV2LT5kZXYpOwogCi0JbmljLT5jc3Ig
PSBpb3JlbWFwKHBjaV9yZXNvdXJjZV9zdGFydChwZGV2LCAwKSwgc2l6ZW9mKHN0cnVjdCBjc3Ip
KTsKKwlpZiAodXNlX2lvKQorCQlEUFJJTlRLKFBST0JFLCBJTkZPLCAidXNpbmcgaS9vIGFjY2Vz
cyBtb2RlXG4iKTsKKworCW5pYy0+Y3NyID0gcGNpX2lvbWFwKHBkZXYsICh1c2VfaW8gPyAxIDog
MCksIHNpemVvZihzdHJ1Y3QgY3NyKSk7CiAJaWYoIW5pYy0+Y3NyKSB7CiAJCURQUklOVEsoUFJP
QkUsIEVSUiwgIkNhbm5vdCBtYXAgZGV2aWNlIHJlZ2lzdGVycywgYWJvcnRpbmcuXG4iKTsKIAkJ
ZXJyID0gLUVOT01FTTsKQEAgLTI2NzYsNyArMjY4Miw3IEBAICNlbmRpZgogCiAJRFBSSU5USyhQ
Uk9CRSwgSU5GTywgImFkZHIgMHglbGx4LCBpcnEgJWQsICIKIAkJIk1BQyBhZGRyICUwMlg6JTAy
WDolMDJYOiUwMlg6JTAyWDolMDJYXG4iLAotCQkodW5zaWduZWQgbG9uZyBsb25nKXBjaV9yZXNv
dXJjZV9zdGFydChwZGV2LCAwKSwgcGRldi0+aXJxLAorCQkodW5zaWduZWQgbG9uZyBsb25nKXBj
aV9yZXNvdXJjZV9zdGFydChwZGV2LCB1c2VfaW8gPyAxIDogMCksIHBkZXYtPmlycSwKIAkJbmV0
ZGV2LT5kZXZfYWRkclswXSwgbmV0ZGV2LT5kZXZfYWRkclsxXSwgbmV0ZGV2LT5kZXZfYWRkclsy
XSwKIAkJbmV0ZGV2LT5kZXZfYWRkclszXSwgbmV0ZGV2LT5kZXZfYWRkcls0XSwgbmV0ZGV2LT5k
ZXZfYWRkcls1XSk7CiAKQEAgLTI2ODUsNyArMjY5MSw3IEBAICNlbmRpZgogZXJyX291dF9mcmVl
OgogCWUxMDBfZnJlZShuaWMpOwogZXJyX291dF9pb3VubWFwOgotCWlvdW5tYXAobmljLT5jc3Ip
OworCXBjaV9pb3VubWFwKHBkZXYsIG5pYy0+Y3NyKTsKIGVycl9vdXRfZnJlZV9yZXM6CiAJcGNp
X3JlbGVhc2VfcmVnaW9ucyhwZGV2KTsKIGVycl9vdXRfZGlzYWJsZV9wZGV2Ogo=

------_=_NextPart_001_01C74FA7.89B22D54--
