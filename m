From: Luis Henriques <luis.henriques@canonical.com>
Subject: [PATCH 3.16.y-ckt 093/144] net: ethernet: pcnet32: Setup the SRAM and
 NOUFLO on Am79C97{3, 5}
Date: Tue, 21 Apr 2015 16:31:18 +0100
Message-ID: <1429630329-21748-94-git-send-email-luis.henriques@canonical.com>
References: <1429630329-21748-1-git-send-email-luis.henriques@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Don Fry <pcnet32@frontier.com>,
 Markos Chandras <markos.chandras@imgtec.com>,
 "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
 kernel-team@lists.ubuntu.com
Return-path: <kernel-team-bounces@lists.ubuntu.com>
In-Reply-To: <1429630329-21748-1-git-send-email-luis.henriques@canonical.com>
List-Unsubscribe: <https://lists.ubuntu.com/mailman/options/kernel-team>,
 <mailto:kernel-team-request@lists.ubuntu.com?subject=unsubscribe>
List-Archive: <https://lists.ubuntu.com/archives/kernel-team>
List-Post: <mailto:kernel-team@lists.ubuntu.com>
List-Help: <mailto:kernel-team-request@lists.ubuntu.com?subject=help>
List-Subscribe: <https://lists.ubuntu.com/mailman/listinfo/kernel-team>,
 <mailto:kernel-team-request@lists.ubuntu.com?subject=subscribe>
Errors-To: kernel-team-bounces@lists.ubuntu.com
Sender: kernel-team-bounces@lists.ubuntu.com
List-Id: netdev.vger.kernel.org

3.16.7-ckt10 -stable review patch.  If anyone has any objections, please let me know.

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
Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
---
 drivers/net/ethernet/amd/pcnet32.c | 31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index e7cc9174e364..02d3b7975835 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1552,7 +1552,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 {
 	struct pcnet32_private *lp;
 	int i, media;
-	int fdx, mii, fset, dxsuflo;
+	int fdx, mii, fset, dxsuflo, sram;
 	int chip_version;
 	char *chipname;
 	struct net_device *dev;
@@ -1589,7 +1589,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	}
 
 	/* initialize variables */
-	fdx = mii = fset = dxsuflo = 0;
+	fdx = mii = fset = dxsuflo = sram = 0;
 	chip_version = (chip_version >> 12) & 0xffff;
 
 	switch (chip_version) {
@@ -1622,6 +1622,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		chipname = "PCnet/FAST III 79C973";	/* PCI */
 		fdx = 1;
 		mii = 1;
+		sram = 1;
 		break;
 	case 0x2626:
 		chipname = "PCnet/Home 79C978";	/* PCI */
@@ -1645,6 +1646,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		chipname = "PCnet/FAST III 79C975";	/* PCI */
 		fdx = 1;
 		mii = 1;
+		sram = 1;
 		break;
 	case 0x2628:
 		chipname = "PCnet/PRO 79C976";
@@ -1673,6 +1675,31 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
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
