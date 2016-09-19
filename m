From: Alan <alan@linux.intel.com>
Subject: [PATCH] 6pack: fix buffer length mishandling
Date: Mon, 19 Sep 2016 20:15:24 +0100
Message-ID: <147431251411.53012.5151201638797223106.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:45876 "EHLO
        lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbcISTPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 15:15:32 -0400
Received: from localhost.localdomain (proxy [81.2.110.250])
        by lxorguk.ukuu.org.uk (8.15.2/8.14.1) with ESMTP id u8JK4gQI029879
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 21:04:48 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Vyukov wrote:
> different runs). Looking at code, the following looks suspicious -- we
> limit copy by 512 bytes, but use the original count which can be
> larger than 512:
>
> static void sixpack_receive_buf(struct tty_struct *tty,
>     const unsigned char *cp, char *fp, int count)
> {
>     unsigned char buf[512];
>     ....
>     memcpy(buf, cp, count < sizeof(buf) ? count : sizeof(buf));
>     ....
>     sixpack_decode(sp, buf, count1);

With the sane tty locking we now have I believe the following is safe as
we consume the bytes and move them into the decoded buffer before
returning.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---
 drivers/net/hamradio/6pack.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 5a1e985..470b3dc 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -127,7 +127,7 @@ struct sixpack {
 
 #define AX25_6PACK_HEADER_LEN 0
 
-static void sixpack_decode(struct sixpack *, unsigned char[], int);
+static void sixpack_decode(struct sixpack *, const unsigned char[], int);
 static int encode_sixpack(unsigned char *, unsigned char *, int, unsigned char);
 
 /*
@@ -428,7 +428,7 @@ static void sixpack_write_wakeup(struct tty_struct *tty)
 
 /*
  * Handle the 'receiver data ready' interrupt.
- * This function is called by the 'tty_io' module in the kernel when
+ * This function is called by the tty module in the kernel when
  * a block of 6pack data has been received, which can now be decapsulated
  * and sent on to some IP layer for further processing.
  */
@@ -436,7 +436,6 @@ static void sixpack_receive_buf(struct tty_struct *tty,
 	const unsigned char *cp, char *fp, int count)
 {
 	struct sixpack *sp;
-	unsigned char buf[512];
 	int count1;
 
 	if (!count)
@@ -446,10 +445,7 @@ static void sixpack_receive_buf(struct tty_struct *tty,
 	if (!sp)
 		return;
 
-	memcpy(buf, cp, count < sizeof(buf) ? count : sizeof(buf));
-
 	/* Read the characters out of the buffer */
-
 	count1 = count;
 	while (count) {
 		count--;
@@ -459,7 +455,7 @@ static void sixpack_receive_buf(struct tty_struct *tty,
 			continue;
 		}
 	}
-	sixpack_decode(sp, buf, count1);
+	sixpack_decode(sp, cp, count1);
 
 	sp_put(sp);
 	tty_unthrottle(tty);
@@ -992,7 +988,7 @@ static void decode_std_command(struct sixpack *sp, unsigned char cmd)
 /* decode a 6pack packet */
 
 static void
-sixpack_decode(struct sixpack *sp, unsigned char *pre_rbuff, int count)
+sixpack_decode(struct sixpack *sp, const unsigned char *pre_rbuff, int count)
 {
 	unsigned char inbyte;
 	int count1;
