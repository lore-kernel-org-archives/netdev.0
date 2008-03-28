From: akpm@linux-foundation.org
Subject: [patch 21/21] tulip: tulip_read_eeprom() fixes for BUG 4420
Date: Fri, 28 Mar 2008 14:41:31 -0700
Message-ID: <200803282141.m2SLfVYi011861@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	grundler@parisc-linux.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42112 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756925AbYC1VmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:42:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@parisc-linux.org>

If "location" is > "addr_len" bits, the high bits of location would interfere
with the READ_CMD sent to the eeprom controller.

A patch was submitted to bug:
    http://bugzilla.kernel.org/show_bug.cgi?id=4420

which simply truncated the "location", read whatever was in "location modulo
addr_len", and returned that value.  That avoids confusing the eeprom but
seems like the wrong solution to me.

Correct would be to not read beyond "1 << addr_len" address of the eeprom.
I am submitting two changes to implement this:

1) tulip_read_eeprom will return zero (since we can't return -EINVAL)
   if this is attempted (defensive programming).

2) In tulip_core.c, fix the tulip_read_eeprom caller so they don't
   iterate past addr_len bits and make sure the entire tp->eeprom[]
   array is cleared.

I know we don't strictly need both.  I would prefer both in the tree since it
documents the issue and provides a second "defense" from the bug from creeping
back in.

[akpm@linux-foundation.org: coding-style fixes]
Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tulip/eeprom.c     |    6 ++++++
 drivers/net/tulip/tulip_core.c |    7 ++++++-
 2 files changed, 12 insertions(+), 1 deletion(-)

diff -puN drivers/net/tulip/eeprom.c~tulip-tulip_read_eeprom-fixes-for-bug-4420 drivers/net/tulip/eeprom.c
--- a/drivers/net/tulip/eeprom.c~tulip-tulip_read_eeprom-fixes-for-bug-4420
+++ a/drivers/net/tulip/eeprom.c
@@ -343,6 +343,12 @@ int __devinit tulip_read_eeprom(struct n
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
 
diff -puN drivers/net/tulip/tulip_core.c~tulip-tulip_read_eeprom-fixes-for-bug-4420 drivers/net/tulip/tulip_core.c
--- a/drivers/net/tulip/tulip_core.c~tulip-tulip_read_eeprom-fixes-for-bug-4420
+++ a/drivers/net/tulip/tulip_core.c
@@ -1437,6 +1437,7 @@ static int __devinit tulip_init_one (str
 	   EEPROM.
 	   */
 	ee_data = tp->eeprom;
+	memset(ee_data, 0, sizeof(tp->eeprom));
 	sum = 0;
 	if (chip_idx == LC82C168) {
 		for (i = 0; i < 3; i++) {
@@ -1458,8 +1459,12 @@ static int __devinit tulip_init_one (str
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
_
