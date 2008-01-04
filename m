From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/6]: [CASSINI]: Program parent Intel31154 bridge when
 necessary.
Date: Fri, 04 Jan 2008 00:33:56 -0800 (PST)
Message-ID: <20080104.003356.07503650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panther@balabit.hu, bazsi@balabit.hu, hidden@sch.bme.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51622
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753699AbYADIvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 03:51:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[CASSINI]: Program parent Intel31154 bridge when necessary.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/cassini.c |   86 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 86 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index ff957f2..2336223 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4846,6 +4846,90 @@ static int cas_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return rc;
 }
 
+/* When this chip sits underneath an Intel 31154 bridge, it is the
+ * only subordinate device and we can tweak the bridge settings to
+ * reflect that fact.
+ */
+static void __devinit cas_program_bridge(struct pci_dev *cas_pdev)
+{
+	struct pci_dev *pdev = cas_pdev->bus->self;
+	u32 val;
+
+	if (!pdev)
+		return;
+
+	if (pdev->vendor != 0x8086 || pdev->device != 0x537c)
+		return;
+
+	/* Clear bit 10 (Bus Parking Control) in the Secondary
+	 * Arbiter Control/Status Register which lives at offset
+	 * 0x41.  Using a 32-bit word read/modify/write at 0x40
+	 * is much simpler so that's how we do this.
+	 */
+	pci_read_config_dword(pdev, 0x40, &val);
+	val &= ~0x00040000;
+	pci_write_config_dword(pdev, 0x40, val);
+
+	/* Max out the Multi-Transaction Timer settings since
+	 * Cassini is the only device present.
+	 *
+	 * The register is 16-bit and lives at 0x50.  When the
+	 * settings are enabled, it extends the GRANT# signal
+	 * for a requestor after a transaction is complete.  This
+	 * allows the next request to run without first needing
+	 * to negotiate the GRANT# signal back.
+	 *
+	 * Bits 12:10 define the grant duration:
+	 *
+	 *	1	--	16 clocks
+	 *	2	--	32 clocks
+	 *	3	--	64 clocks
+	 *	4	--	128 clocks
+	 *	5	--	256 clocks
+	 *
+	 * All other values are illegal.
+	 *
+	 * Bits 09:00 define which REQ/GNT signal pairs get the
+	 * GRANT# signal treatment.  We set them all.
+	 */
+	pci_write_config_word(pdev, 0x50, (5 << 10) | 0x3ff);
+
+	/* The Read Prefecth Policy register is 16-bit and sits at
+	 * offset 0x52.  It enables a "smart" pre-fetch policy.  We
+	 * enable it and max out all of the settings since only one
+	 * device is sitting underneath and thus bandwidth sharing is
+	 * not an issue.
+	 *
+	 * The register has several 3 bit fields, which indicates a
+	 * multiplier applied to the base amount of prefetching the
+	 * chip would do.  These fields are at:
+	 *
+	 *	15:13	---	ReRead Primary Bus
+	 *	12:10	---	FirstRead Primary Bus
+	 *	09:07	---	ReRead Secondary Bus
+	 *	06:04	---	FirstRead Secondary Bus
+	 *
+	 * Bits 03:00 control which REQ/GNT pairs the prefetch settings
+	 * get enabled on.  Bit 3 is a grouped enabler which controls
+	 * all of the REQ/GNT pairs from [8:3].  Bits 2 to 0 control
+	 * the individual REQ/GNT pairs [2:0].
+	 */
+	pci_write_config_word(pdev, 0x52,
+			      (0x7 << 13) |
+			      (0x7 << 10) |
+			      (0x7 <<  7) |
+			      (0x7 <<  4) |
+			      (0xf <<  0));
+
+	/* Force cacheline size to 0x8 */
+	pci_write_config_byte(pdev, PCI_CACHE_LINE_SIZE, 0x08);
+
+	/* Force latency timer to maximum setting so Cassini can
+	 * sit on the bus as long as it likes.
+	 */
+	pci_write_config_byte(pdev, PCI_LATENCY_TIMER, 0xff);
+}
+
 static int __devinit cas_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -4901,6 +4985,8 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 		printk(KERN_WARNING PFX "Could not enable MWI for %s\n",
 		       pci_name(pdev));
 
+	cas_program_bridge(pdev);
+
 	/*
 	 * On some architectures, the default cache line size set
 	 * by pci_try_set_mwi reduces perforamnce.  We have to increase
-- 
1.5.4.rc2.17.g257f

