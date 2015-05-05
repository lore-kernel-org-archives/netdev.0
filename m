From: Kamal Mostafa <kamal@canonical.com>
Subject: [PATCH 3.13.y-ckt 28/90] net: ethernet: pcnet32: Setup the SRAM and NOUFLO on Am79C97{3, 5}
Date: Tue,  5 May 2015 13:54:00 -0700
Message-ID: <1430859302-5886-29-git-send-email-kamal@canonical.com>
References: <1430859302-5886-1-git-send-email-kamal@canonical.com>
Cc: <netdev@vger.kernel.org>, Don Fry <pcnet32@frontier.com>,
	Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Kamal Mostafa <kamal@canonical.com>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	kernel-team@lists.ubuntu.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1430859302-5886-1-git-send-email-kamal@canonical.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.13.11-ckt20 -stable review patch.  If anyone has any objections, please let me know.

------------------

From: Markos Chandras <markos.chandras@imgtec.com>

commit 87f966d97b89774162df04d2106c6350c8fe4cb3 upstream.

On a MIPS Malta board, tons of fifo underflow errors have been observed
when using u-boot as bootloader instead of YAMON. The reason for that
is that YAMON used to set the pcnet device to SRAM mode but u-boot does
not. As a result, the default Tx threshold (64 bytes) is now too small to
keep the fifo relatively used and it can result to Tx fifo underflow errors.
As a result of which, it's best to setup the SRAM on supported controllers
so we can always use the NOUFLO bit.

Cc: <netdev@vger.kernel.org>
Cc: <linux-kernel@vger.kernel.org>
Cc: Don Fry <pcnet32@frontier.com>
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Kamal Mostafa <kamal@canonical.com>
---
 drivers/net/ethernet/amd/pcnet32.c | 31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 38492e0..26e0653 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1516,7 +1516,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 {
 	struct pcnet32_private *lp;
 	int i, media;
-	int fdx, mii, fset, dxsuflo;
+	int fdx, mii, fset, dxsuflo, sram;
 	int chip_version;
 	char *chipname;
 	struct net_device *dev;
@@ -1553,7 +1553,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	}
 
 	/* initialize variables */
-	fdx = mii = fset = dxsuflo = 0;
+	fdx = mii = fset = dxsuflo = sram = 0;
 	chip_version = (chip_version >> 12) & 0xffff;
 
 	switch (chip_version) {
@@ -1586,6 +1586,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		chipname = "PCnet/FAST III 79C973";	/* PCI */
 		fdx = 1;
 		mii = 1;
+		sram = 1;
 		break;
 	case 0x2626:
 		chipname = "PCnet/Home 79C978";	/* PCI */
@@ -1609,6 +1610,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		chipname = "PCnet/FAST III 79C975";	/* PCI */
 		fdx = 1;
 		mii = 1;
+		sram = 1;
 		break;
 	case 0x2628:
 		chipname = "PCnet/PRO 79C976";
@@ -1637,6 +1639,31 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		dxsuflo = 1;
 	}
 
+	/*
+	 * The Am79C973/Am79C975 controllers come with 12K of SRAM
+	 * which we can use for the Tx/Rx buffers but most importantly,
+	 * the use of SRAM allow us to use the BCR18:NOUFLO bit to avoid
+	 * Tx fifo underflows.
+	 */
+	if (sram) {
+		/*
+		 * The SRAM is being configured in two steps. First we
+		 * set the SRAM size in the BCR25:SRAM_SIZE bits. According
+		 * to the datasheet, each bit corresponds to a 512-byte
+		 * page so we can have at most 24 pages. The SRAM_SIZE
+		 * holds the value of the upper 8 bits of the 16-bit SRAM size.
+		 * The low 8-bits start at 0x00 and end at 0xff. So the
+		 * address range is from 0x0000 up to 0x17ff. Therefore,
+		 * the SRAM_SIZE is set to 0x17. The next step is to set
+		 * the BCR26:SRAM_BND midway through so the Tx and Rx
+		 * buffers can share the SRAM equally.
+		 */
+		a->write_bcr(ioaddr, 25, 0x17);
+		a->write_bcr(ioaddr, 26, 0xc);
+		/* And finally enable the NOUFLO bit */
+		a->write_bcr(ioaddr, 18, a->read_bcr(ioaddr, 18) | (1 << 11));
+	}
+
 	dev = alloc_etherdev(sizeof(*lp));
 	if (!dev) {
 		ret = -ENOMEM;
-- 
1.9.1
