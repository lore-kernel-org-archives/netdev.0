From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] eexpress: Read buffer overflow
Date: Wed, 29 Jul 2009 15:18:56 +0200
Message-ID: <4A704C40.1070606@gmail.com>
References: <20090729122953.GC5490@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:40253 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015AbZG2NQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 09:16:04 -0400
Received: by ewy26 with SMTP id 26so811977ewy.37
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 06:16:03 -0700 (PDT)
In-Reply-To: <20090729122953.GC5490@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

start_code is 69 words, but the code always writes a multiple of 16 words,
so the last 11 words written are outside the array.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
> Now you seem to make my previous math working :-)
> 
>>> (max) i = 64, (max) j = 14, (64+14+16)/2 = 47 < 69, so it seems to copy
>>> less than its size?
> 
> Jarek P.
> 

You're right, thanks for reviewing, this one should be correct.

diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 1686dca..1f016d6 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -1474,13 +1474,13 @@ static void eexp_hw_init586(struct net_device *dev)
 	outw(0x0000, ioaddr + 0x800c);
 	outw(0x0000, ioaddr + 0x800e);
 
-	for (i = 0; i < (sizeof(start_code)); i+=32) {
+	for (i = 0; i < ARRAY_SIZE(start_code) * 2; i+=32) {
 		int j;
 		outw(i, ioaddr + SM_PTR);
-		for (j = 0; j < 16; j+=2)
+		for (j = 0; j < 16 && (i+j)/2 < ARRAY_SIZE(start_code); j+=2)
 			outw(start_code[(i+j)/2],
 			     ioaddr+0x4000+j);
-		for (j = 0; j < 16; j+=2)
+		for (j = 0; j < 16 && (i+j+16)/2 < ARRAY_SIZE(start_code); j+=2)
 			outw(start_code[(i+j+16)/2],
 			     ioaddr+0x8000+j);
 	}
