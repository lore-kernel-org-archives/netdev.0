From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] net: off by one, try #2
Date: Wed, 11 Feb 2009 20:33:25 +0100
Message-ID: <49932805.7050309@gmail.com>
References: <20090211133341.GB12362@ff.dom.local> <4992DF3C.7070802@gmail.com> <20090211171403.GA2539@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:41768 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756145AbZBKTdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 14:33:24 -0500
Received: by bwz5 with SMTP id 5so523361bwz.13
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 11:33:22 -0800 (PST)
In-Reply-To: <20090211171403.GA2539@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Feb 11, 2009 at 03:22:52PM +0100, Roel Kluin wrote:
>>>> With while (x++ < n) { ... } x can reach n+1.
>>> Yes, but it looks like here is even more...
>>> i is also misused here and array can be overriden, so additional
>>> break/return is needed.
>> Thanks, is this how it should be?
> 
> It looks (almost) OK to me. :-) Except this > 80 line.
> 
> On the other hand, I wonder if it's not a good time to make it more
> readable; I mean the first while (): length, ";", and maybe ++j
> similarly to i now?
> 
> BTW, I hope you remember about irda.
> 
> Jarek P.

Thanks again for reviewing, how's this? with irda this time.
-------------------->8----------------8<-----------------------

With while (x++ < n) { ... } x can reach n+1. As Jarek Poplawski pointed out, array
pcb->data.raw was not correctly used.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index 6124605..4ade64a 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -493,15 +493,21 @@ static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
 	}
 	/* read the data */
 	spin_lock_irqsave(&adapter->lock, flags);
-	i = 0;
-	do {
-		j = 0;
-		while (((stat = get_status(dev->base_addr)) & ACRF) == 0 && j++ < 20000);
-		pcb->data.raw[i++] = inb_command(dev->base_addr);
-		if (i > MAX_PCB_DATA)
-			INVALID_PCB_MSG(i);
-	} while ((stat & ASF_PCB_MASK) != ASF_PCB_END && j < 20000);
+	for (i = 0; i < MAX_PCB_DATA; i++) {
+		for (j = 0; j < 20000; j++) {
+			stat = get_status(dev->base_addr);
+			if (stat & ACRF)
+				break;
+		}
+		pcb->data.raw[i] = inb_command(dev->base_addr);
+		if (stat & ASF_PCB_MASK == ASF_PCB_END || j >= 20000)
+			break;
+	}
 	spin_unlock_irqrestore(&adapter->lock, flags);
+	if (i >= MAX_PCB_DATA) {
+		INVALID_PCB_MSG(i);
+		return false;
+	}
 	if (j >= 20000) {
 		TIMEOUT_MSG(__LINE__);
 		return false;
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 7eafdca..85e88da 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -585,7 +585,7 @@ static int mcs_speed_change(struct mcs_cb *mcs)
 		mcs_get_reg(mcs, MCS_RESV_REG, &rval);
 	} while(cnt++ < 100 && (rval & MCS_IRINTX));
 
-	if(cnt >= 100) {
+	if (cnt > 100) {
 		IRDA_ERROR("unable to change speed\n");
 		ret = -EIO;
 		goto error;

