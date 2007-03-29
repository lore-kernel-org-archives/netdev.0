From: "Cureington, Tony" <tony.cureington@hp.com>
Subject: [PATCH 2.6.21-rc5] bnx2: fix buffer overrun in bnx2_nvram_write
Date: Thu, 29 Mar 2007 22:47:16 -0000
Message-ID: <A6ACA33CD952BB47867438765C49F4F302370DF9@G3W0071.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <mchan@broadcom.com>, "Cureington, Tony" <tony.cureington@hp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelbas04.cce.hp.com ([161.114.21.107]:55374 "EHLO
	ccerelbas04.cce.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945913AbXC2XCI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 19:02:08 -0400
Received: from G3W0060.americas.hpqcorp.net (g3w0060.americas.hpqcorp.net [16.232.1.19])
	by ccerelbas04.cce.hp.com (Postfix) with ESMTP id 9962934578
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 17:48:12 -0500 (CDT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A buffer overrun issue exists in the bnx2_nvram_write function. This
issue
is exposed by calling ethtool to write to the eeprom as shown below.

   ethtool -E eth4 magic 0x669955AA offset 0x137 value 0xC4

The problem happens when align_buf is allocated only 2 bytes in the
kmalloc
call and later 4 bytes written to it. The len32 variable is calculated
in the
below code segment at around line 3102.

        if ((align_start = (offset32 & 3))) {
                offset32 &= ~3;
                len32 += (4 - align_start);
                :

The next "if" conditional in the code that could alter these values is
not
entered, so we end up with:
   len32=2
   align_start=3
   offset32=308

This results in align_buf being allocated 2 bytes, and overwritten with
4 bytes in the "if (align_start)" segment just below the allocation.

I made a change adjust the len32 to the next 4 byte boundary.

I also made changes so the call to erase the eeprom page is not called
unless
the page will be written. To achieve this I just moved the code inside
the
conditional that writes the page. After doing this I realized the page
erase
functions were no-ops since the same conditional checked for before the
page
is written in this function is checked in the erase function. I left the

changes in because it makes it more logical and removes unneeded calls.

Also note that if len32 is not on a 4 byte boundary the, data_end
variable
(offset32 + len32 in this case) will never equal data_start plus a
multiple of 4 to cause the BNX2_NVM_COMMAND_LAST to be issued to the
board
at around line 3220.

Signed-Off-By: Tony Cureington (tony.cureington@hp.com)

--- linux-2.6.21-rc5.orig/drivers/net/bnx2.c	2007-03-29
12:49:33.000000000 -0500
+++ linux/drivers/net/bnx2.c	2007-03-29 17:06:36.000000000 -0500
@@ -3116,6 +3116,10 @@
 	}
 
 	if (align_start || align_end) {
+		if (len32&3) {
+			// adjust to 4 byte boundary
+			len32 += 4-(len32&3);
+		}
 		align_buf = kmalloc(len32, GFP_KERNEL);
 		if (align_buf == NULL)
 			return -ENOMEM;
@@ -3187,17 +3191,17 @@
 		if ((rc = bnx2_enable_nvram_write(bp)) != 0)
 			goto nvram_write_end;
 
-		/* Erase the page */
-		if ((rc = bnx2_nvram_erase_page(bp, page_start)) != 0)
-			goto nvram_write_end;
-
-		/* Re-enable the write again for the actual write */
-		bnx2_enable_nvram_write(bp);
-
 		/* Loop to write back the buffer data from page_start to
 		 * data_start */
 		i = 0;
 		if (bp->flash_info->buffered == 0) {
+			/* Erase the page */
+			if ((rc = bnx2_nvram_erase_page(bp, page_start))
!= 0)
+				goto nvram_write_end;
+
+			/* Re-enable the write again for the actual
write */
+			bnx2_enable_nvram_write(bp);
+
 			for (addr = page_start; addr < data_start;
 				addr += 4, i += 4) {
 

