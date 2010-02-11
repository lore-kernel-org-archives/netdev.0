From: Tiago Pierezan Camargo <tcamargo@gmail.com>
Subject: Re: Problem with VLANs and via-velocity driver
Date: Thu, 11 Feb 2010 14:50:07 -0200
Message-ID: <2ab8a3251002110850k2def5137qb791b100145a3bd2@mail.gmail.com>
References: <20091113033217.GQ838@cubit> <4AFCFF67.3060802@trash.net>
	 <20091116005750.GR838@cubit> <loom.20100210T171704-457@post.gmane.org>
	 <4B72E2FC.1060003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f189.google.com ([209.85.211.189]:45530 "EHLO
	mail-yw0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830Ab0BKQzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 11:55:19 -0500
Received: by ywh27 with SMTP id 27so1234980ywh.1
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2010 08:55:18 -0800 (PST)
In-Reply-To: <4B72E2FC.1060003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber <at> trash.net> writes:
> > ...
> >
> > Any suggestions?
>
> This should be fixed in the driver as discussed previously.

Well, the following patch completely disables hw vlan filtering
(against 2.6.31).

--- ../via_kernel_org/via-velocity.c	2010-02-10 11:45:14.000000000 -0200
+++ via-velocity.c	2010-02-11 11:24:37.000000000 -0200
@@ -607,9 +607,10 @@
 {
 	struct mac_regs __iomem * regs = vptr->mac_regs;

-	/* Turn on MCFG_PQEN, turn off MCFG_RTGOPT */
-	WORD_REG_BITS_SET(MCFG_PQEN, MCFG_RTGOPT, &regs->MCFG);
-	WORD_REG_BITS_ON(MCFG_VIDFR, &regs->MCFG);
+	/* Completely disable vlan filtering */
+	WORD_REG_BITS_OFF(MCFG_PQEN, &regs->MCFG);
+	WORD_REG_BITS_OFF(MCFG_VIDFR, &regs->MCFG);
+	WORD_REG_BITS_OFF(MCFG_RTGOPT, &regs->MCFG);

 	/* Disable all CAMs */
 	memset(vptr->vCAMmask, 0, sizeof(u8) * 8);
@@ -1406,7 +1407,7 @@
 		/*
 		 *	Don't drop CE or RL error frame although RXOK is off
 		 */
-		if (rd->rdesc0.RSR & (RSR_RXOK | RSR_CE | RSR_RL)) {
+		if (rd->rdesc0.RSR & (RSR_RXOK | RSR_CE | RSR_RL | RSR_VIDM)) {
 			if (velocity_receive_frame(vptr, rd_curr) < 0)
 				stats->rx_dropped++;

I know it's not the best solution. I can come up with a better patch
but I'm a bit confused about the expected behavior.

- Should we only disable vlan filtering when promiscuous mode is
enabled? (should we care about hw tag stripping?)
- Should we disable vlan filtering entirely and let the software deal
with it? (this seems to be the semantics implemented in the freebsd
driver)

Suggestions?

Regards,

-- 
Tiago Pierezan Camargo
tcamargo at gmail dot com
