From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver fixes
Date: Sun, 20 Feb 2005 21:30:50 -0500
Message-ID: <421947DA.7030603@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030308020401070601070604"
Cc: Netdev <netdev@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030308020401070601070604
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

see attached changelog and patch.

--------------030308020401070601070604
Content-Type: text/plain;
 name="changelog.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changelog.txt"

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/natsemi.c        |    4 +++-
 drivers/net/s2io.c           |    5 +++++
 drivers/net/wireless/strip.c |    4 ++--
 3 files changed, 10 insertions(+), 3 deletions(-)

through these ChangeSets:

<Gary.Spiess@Intermec.com> (05/02/20 1.2078)
   [PATCH] natsemi long cable fix
   
   This is a minor modification to the previous patch submission that does
   not assume the default contents of the DSPCFG register are zero.
   
   When used with Revision D of the DP83815, the "Recommended Registers
   Configuration" from page 78 of the DP83815 data sheet is not entirely
   compatible with the driver's "short cable patch".  When the DSPCFG
   register is written with the value suggested in the document, then
   do_cable_magic() can't read the DSP coefficient and determines that all
   cables attached to the DP83815D are 'short', regardless of actual
   length.  Short cables (< 30m) cause do_cable_magic to enable additional
   attenuation to reduce CRC and idle errors.  If the extra attenuation is
   unintentionally enabled for long cables (> 50m?), they will not operate
   properly.  The National Semiconductor driver, 'dp83815.c' from
   http://www.national.com/appinfo/networks/files/linux_2_4.tar.gz was used
   as a basis for this modification.
   
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<ravinandan.arakali@neterion.com> (05/02/20 1.2077)
   [PATCH] S2io: Multicast fix
   
   Attached is the patch to address the incorrect programming of
   individual multicast address into the NIC.
   
   Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<akpm@osdl.org> (05/02/20 1.2076)
   [PATCH] strip.c build fix
   
   Someone added a new dev_set_mac_address() to netdevice.h
   
   Signed-off-by: Andrew Morton <akpm@osdl.org>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>


--------------030308020401070601070604
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/drivers/net/natsemi.c b/drivers/net/natsemi.c
--- a/drivers/net/natsemi.c	2005-02-20 21:30:01 -05:00
+++ b/drivers/net/natsemi.c	2005-02-20 21:30:01 -05:00
@@ -441,6 +441,7 @@
 #define DSPCFG_VAL	0x5040
 #define SDCFG_VAL	0x008c	/* set voltage thresholds for Signal Detect */
 #define DSPCFG_LOCK	0x20	/* coefficient lock bit in DSPCFG */
+#define DSPCFG_COEF	0x1000	/* see coefficient (in TSTDAT) bit in DSPCFG */
 #define TSTDAT_FIXED	0xe8	/* magic number for bad coefficients */
 
 /* misc PCI space registers */
@@ -1243,7 +1244,8 @@
 		writew(1, ioaddr + PGSEL);
 		writew(PMDCSR_VAL, ioaddr + PMDCSR);
 		writew(TSTDAT_VAL, ioaddr + TSTDAT);
-		np->dspcfg = DSPCFG_VAL;
+		np->dspcfg = (np->srr <= SRR_DP83815_C)?
+			DSPCFG_VAL : (DSPCFG_COEF | readw(ioaddr + DSPCFG));
 		writew(np->dspcfg, ioaddr + DSPCFG);
 		writew(SDCFG_VAL, ioaddr + SDCFG);
 		writew(0, ioaddr + PGSEL);
diff -Nru a/drivers/net/s2io.c b/drivers/net/s2io.c
--- a/drivers/net/s2io.c	2005-02-20 21:30:01 -05:00
+++ b/drivers/net/s2io.c	2005-02-20 21:30:01 -05:00
@@ -3025,6 +3025,8 @@
 		for (i = 0; i < prev_cnt; i++) {
 			writeq(RMAC_ADDR_DATA0_MEM_ADDR(dis_addr),
 			       &bar0->rmac_addr_data0_mem);
+			writeq(RMAC_ADDR_DATA1_MEM_MASK(0ULL),
+		       		&bar0->rmac_addr_data1_mem);
 			val64 = RMAC_ADDR_CMD_MEM_WE |
 			    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
 			    RMAC_ADDR_CMD_MEM_OFFSET
@@ -3049,8 +3051,11 @@
 				mac_addr |= mclist->dmi_addr[j];
 				mac_addr <<= 8;
 			}
+			mac_addr >>= 8;
 			writeq(RMAC_ADDR_DATA0_MEM_ADDR(mac_addr),
 			       &bar0->rmac_addr_data0_mem);
+			writeq(RMAC_ADDR_DATA1_MEM_MASK(0ULL),
+		       		&bar0->rmac_addr_data1_mem);
 
 			val64 = RMAC_ADDR_CMD_MEM_WE |
 			    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
diff -Nru a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
--- a/drivers/net/wireless/strip.c	2005-02-20 21:30:01 -05:00
+++ b/drivers/net/wireless/strip.c	2005-02-20 21:30:01 -05:00
@@ -2398,7 +2398,7 @@
 	return 0;
 }
 
-static int dev_set_mac_address(struct net_device *dev, void *addr)
+static int strip_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct strip *strip_info = (struct strip *) (dev->priv);
 	struct sockaddr *sa = addr;
@@ -2552,7 +2552,7 @@
 	dev->hard_start_xmit = strip_xmit;
 	dev->hard_header = strip_header;
 	dev->rebuild_header = strip_rebuild_header;
-	dev->set_mac_address = dev_set_mac_address;
+	dev->set_mac_address = strip_set_mac_address;
 	dev->get_stats = strip_get_stats;
 	dev->change_mtu = strip_change_mtu;
 }

--------------030308020401070601070604--
