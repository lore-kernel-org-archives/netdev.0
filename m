From: Grant Grundler <grundler@parisc-linux.org>
Subject: [PATCH] 2.6.25-rc6 tulip_read_eeprom fixes for BUG 4420
Date: Sun, 23 Mar 2008 23:23:10 -0600
Message-ID: <20080324052310.GC474@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:57874 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752173AbYCXFXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 01:23:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,
If "location" is > "addr_len" bits, the high bits of location would interfere
with the READ_CMD sent to the eeprom controller.

A patch was submitted to bug:
    http://bugzilla.kernel.org/show_bug.cgi?id=4420

which simply truncated the "location", read whatever was in "location
modulo addr_len", and returned that value. That avoids confusing the
eeprom but seems like the wrong solution to me.

Correct would be to not read beyond "1 << addr_len" address of the eeprom.
I am submitting two changes to implement this:
1) tulip_read_eeprom will return zero (since we can't return -EINVAL)
   if this is attempted (defensive programming).
2) In tulip_core.c, fix the tulip_read_eeprom caller so they don't
   iterate past addr_len bits and make sure the entire tp->eeprom[]
   array is cleared.

I konw we don't strictly need both. I would prefer both in the tree
since it documents the issue and provides a second "defense" from
the bug from creeping back in.

thanks,
grant

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
index 206918b..843f101 100644
--- a/drivers/net/tulip/eeprom.c
+++ b/drivers/net/tulip/eeprom.c
@@ -343,6 +343,12 @@ int __devinit tulip_read_eeprom(struct net_device *dev, int location, int addr_l
 	void __iomem *ee_addr = tp->base_addr + CSR9;
 	int read_cmd = location | (EE_READ_CMD << addr_len);
 
+	/* If location is past the end of what we can address, don't
+	 * read some other location (ie truncate). Just return zero.
+	 */	
+	if (location > (1 << addr_len) - 1)
+		return 0;
+
 	iowrite32(EE_ENB & ~EE_CS, ee_addr);
 	iowrite32(EE_ENB, ee_addr);
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index ed600bf..82f404b 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1437,6 +1437,7 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	   EEPROM.
 	   */
 	ee_data = tp->eeprom;
+	memset(ee_data, 0, sizeof(tp->eeprom));
 	sum = 0;
 	if (chip_idx == LC82C168) {
 		for (i = 0; i < 3; i++) {
@@ -1458,8 +1459,12 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 		/* A serial EEPROM interface, we read now and sort it out later. */
 		int sa_offset = 0;
 		int ee_addr_size = tulip_read_eeprom(dev, 0xff, 8) & 0x40000 ? 8 : 6;
+		int ee_max_addr = ((1 << ee_addr_size) - 1) * sizeof(u16);
 
-		for (i = 0; i < sizeof(tp->eeprom); i+=2) {
+		if (ee_max_addr > sizeof(tp->eeprom))
+			ee_max_addr = sizeof(tp->eeprom);
+
+		for (i = 0; i < ee_max_addr ; i += sizeof(u16)) {
 			u16 data = tulip_read_eeprom(dev, i/2, ee_addr_size);
 			ee_data[i] = data & 0xff;
 			ee_data[i + 1] = data >> 8;
