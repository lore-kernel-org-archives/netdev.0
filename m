From: akpm@osdl.org
Subject: [patch 2/7] b44: fix eeprom endianess issue
Date: Tue, 10 Oct 2006 14:33:26 -0700
Message-ID: <200610102133.k9ALXQqC024965@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53145 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030446AbWJJVdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2006 17:33:38 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>

This fixes eeprom read on big-endian architectures.

readw returns the data in CPU order.  With cpu_to_le16 we convert it to little
endian, because "ptr" is a pointer to a _byte_ arrray.  See the cast above.  A
byte array is little endian.

The bug is:

Reading u16 values with readw, casting them into an u8 array and accessing
this u8 array as an u8 (byte) array.  The correct fix is to swap the
CPU-ordering value returned by readw into little endian, as the u8 array is
little endian.

This compiles to nothing on little endian hardware (so it does not change b44
code on LE hardware), but _fixes_ code on BE hardware.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/b44.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/b44.c~b44-fix-eeprom-endianess-issue drivers/net/b44.c
--- a/drivers/net/b44.c~b44-fix-eeprom-endianess-issue
+++ a/drivers/net/b44.c
@@ -2056,7 +2056,7 @@ static int b44_read_eeprom(struct b44 *b
 	u16 *ptr = (u16 *) data;
 
 	for (i = 0; i < 128; i += 2)
-		ptr[i / 2] = readw(bp->regs + 4096 + i);
+		ptr[i / 2] = cpu_to_le16(readw(bp->regs + 4096 + i));
 
 	return 0;
 }
_
