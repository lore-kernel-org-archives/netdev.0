From: Ian Abbott <abbotti@mev.co.uk>
Subject: [PATCH] lib/checksum.c: optimize do_csum a bit
Date: Thu, 7 Jul 2011 12:18:49 +0100
Message-ID: <1310037529-30854-1-git-send-email-abbotti@mev.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Abbott <abbotti@mev.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>, <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce the number of variables modified by the loop in do_csum() by 1,
which seems like a good idea.  On Nios II (a RISC CPU with 3-operand
instruction set) it reduces the loop from 7 to 6 instructions, including
the conditional branch.

Signed-off-by: Ian Abbott <abbotti@mev.co.uk>
---
 lib/checksum.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/lib/checksum.c b/lib/checksum.c
index 0975087..8df2f91 100644
--- a/lib/checksum.c
+++ b/lib/checksum.c
@@ -49,7 +49,7 @@ static inline unsigned short from32to16(unsigned int x)
 
 static unsigned int do_csum(const unsigned char *buff, int len)
 {
-	int odd, count;
+	int odd;
 	unsigned int result = 0;
 
 	if (len <= 0)
@@ -64,25 +64,22 @@ static unsigned int do_csum(const unsigned char *buff, int len)
 		len--;
 		buff++;
 	}
-	count = len >> 1;		/* nr of 16-bit words.. */
-	if (count) {
+	if (len >= 2) {
 		if (2 & (unsigned long) buff) {
 			result += *(unsigned short *) buff;
-			count--;
 			len -= 2;
 			buff += 2;
 		}
-		count >>= 1;		/* nr of 32-bit words.. */
-		if (count) {
+		if (len >= 4) {
+			const unsigned char *end = buff + ((unsigned)len & ~3);
 			unsigned int carry = 0;
 			do {
 				unsigned int w = *(unsigned int *) buff;
-				count--;
 				buff += 4;
 				result += carry;
 				result += w;
 				carry = (w > result);
-			} while (count);
+			} while (buff < end);
 			result += carry;
 			result = (result & 0xffff) + (result >> 16);
 		}
-- 
1.7.6
