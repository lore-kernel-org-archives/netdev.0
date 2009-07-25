From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] eexpress: Read buffer overflow
Date: Sat, 25 Jul 2009 21:50:19 +0200
Message-ID: <4A6B61FB.4050304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:58178 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbZGYTrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 15:47:46 -0400
Received: by ewy26 with SMTP id 26so2408437ewy.37
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2009 12:47:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

start_code is 69 words, but the code always writes a multiple of 16 words,
so the last 11 words written are outside the array.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
This was observed using Parfait http://research.sun.com/projects/parfait/

diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 1686dca..e304abb 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -1474,15 +1474,14 @@ static void eexp_hw_init586(struct net_device *dev)
 	outw(0x0000, ioaddr + 0x800c);
 	outw(0x0000, ioaddr + 0x800e);
 
-	for (i = 0; i < (sizeof(start_code)); i+=32) {
-		int j;
-		outw(i, ioaddr + SM_PTR);
-		for (j = 0; j < 16; j+=2)
-			outw(start_code[(i+j)/2],
-			     ioaddr+0x4000+j);
-		for (j = 0; j < 16; j+=2)
-			outw(start_code[(i+j+16)/2],
-			     ioaddr+0x8000+j);
+	for (i = 0; i < ARRAY_SIZE(start_code); i += 16) {
+		int j, jmax;
+		outw(i * 2, ioaddr + SM_PTR);
+
+		jmax = min_t(int, 16, ARRAY_SIZE(start_code) - i);
+		for (j = 0; j < jmax; j++)
+			outw(start_code[i + j],
+			     ioaddr + j * 2 + (j < 8 ? 0x4000 : 0x8000 - 16));
 	}
 
 	/* Do we want promiscuous mode or multicast? */
