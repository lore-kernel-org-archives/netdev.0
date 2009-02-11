From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] net: off by one, try #2
Date: Wed, 11 Feb 2009 15:22:52 +0100
Message-ID: <4992DF3C.7070802@gmail.com>
References: <20090211133341.GB12362@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:60650 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755381AbZBKOWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 09:22:50 -0500
Received: by mu-out-0910.google.com with SMTP id i10so75628mue.1
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 06:22:48 -0800 (PST)
In-Reply-To: <20090211133341.GB12362@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> With while (x++ < n) { ... } x can reach n+1.
> 
> Yes, but it looks like here is even more...
> i is also misused here and array can be overriden, so additional
> break/return is needed.

Thanks, is this how it should be?
-------------------->8----------------8<-----------------------

With while (x++ < n) { ... } x can reach n+1. As Jarek Poplawski pointed out, array
pcb->data.raw was not correctly used.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index 6124605..4cf3050 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -497,12 +497,15 @@ static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
 	do {
 		j = 0;
 		while (((stat = get_status(dev->base_addr)) & ACRF) == 0 && j++ < 20000);
-		pcb->data.raw[i++] = inb_command(dev->base_addr);
-		if (i > MAX_PCB_DATA)
-			INVALID_PCB_MSG(i);
-	} while ((stat & ASF_PCB_MASK) != ASF_PCB_END && j < 20000);
+		pcb->data.raw[i] = inb_command(dev->base_addr);
+	} while (++i < MAX_PCB_DATA && (stat & ASF_PCB_MASK) != ASF_PCB_END && j <= 20000);
+
 	spin_unlock_irqrestore(&adapter->lock, flags);
-	if (j >= 20000) {
+	if (i >= MAX_PCB_DATA) {
+		INVALID_PCB_MSG(i);
+		return false;
+	}
+	if (j > 20000) {
 		TIMEOUT_MSG(__LINE__);
 		return false;
 	}
