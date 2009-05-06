From: Radek Podgorny <radek@podgorny.cz>
Subject: via velocity trivial patch
Date: Wed, 06 May 2009 23:07:02 +0200
Message-ID: <4A01FBF6.1090001@podgorny.cz>
References: <49F1A05A.8070802@podgorny.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070903050309070100070205"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 180.129.broadband3.iol.cz ([85.70.129.180]:42383 "EHLO
	home.podgorny.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbZEFVNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 17:13:45 -0400
Received: from [10.25.3.4] (simir.podoli.pjih.czf [10.25.3.4])
	by home.podgorny.cz (Postfix) with ESMTP id 311009A8A3
	for <netdev@vger.kernel.org>; Wed,  6 May 2009 23:07:04 +0200 (CEST)
In-Reply-To: <49F1A05A.8070802@podgorny.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070903050309070100070205
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello everyone!

I've sent the following mail to Francois Romieu <romieu@fr.zoreil.com>
but did not get any reply. So I'm sending directly here. It's a trivial
patch for via-velocity driver.

Sincerely
Radek Podgorny


Radek Podgorny wrote:
> Hello,
> 
> attached is my trivial patch for the via-velocity driver. The actual
> change has been suggested years ago by Jeff Garzik
> (http://lkml.indiana.edu/hypermail/linux/kernel/0406.0/0500.html).
> 
> The problem:
> 
> When multiple velocity cards share the same interrupt (I have a 4x combo
> card on a very old motherboard without APIC or anything) the interrupt
> routine gets called for all of them (which is correct) but the chip that
> is not in question tries to react (which is wrong). The patch should
> explain the case better.
> 
> It has been tested on my old (and until now broken) system and on a
> modern one (APIC, no shared interrupts) and works flawlessly.
> 
> Sincerely
> Radek Podgorny
> 
> diff -ru linux-2.6.29.1-orig/drivers/net/via-velocity.c
> linux-2.6.29.1/drivers/net/via-velocity.c
> --- linux-2.6.29.1-orig/drivers/net/via-velocity.c	2009-04-02
> 22:55:27.000000000 +0200
> +++ linux-2.6.29.1/drivers/net/via-velocity.c	2009-04-24
> 13:09:45.945318255 +0200
> @@ -2226,8 +2226,8 @@
>  	spin_lock(&vptr->lock);
>  	isr_status = mac_read_isr(vptr->mac_regs);
> 
> -	/* Not us ? */
> -	if (isr_status == 0) {
> +	/* Not us or garbage ? */
> +	if (isr_status == 0 || isr_status == 0xffffffff) {
>  		spin_unlock(&vptr->lock);
>  		return IRQ_NONE;
>  	}
> @@ -2236,10 +2236,11 @@
> 
>  	/*
>  	 *	Keep processing the ISR until we have completed
> -	 *	processing and the isr_status becomes zero
> +	 *	processing and the isr_status becomes zero or
> +	 *	we read out some garbage
>  	 */
> 
> -	while (isr_status != 0) {
> +	while (isr_status != 0 && isr_status != 0xffffffff) {
>  		mac_write_isr(vptr->mac_regs, isr_status);
>  		if (isr_status & (~(ISR_PRXI | ISR_PPRXI | ISR_PTXI | ISR_PPTXI)))
>  			velocity_error(vptr, isr_status);
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkoB+/UACgkQ7mej6pjlbYTriwCgvMZ7md0ilITiVqWQphzoyCHq
Ko4AoMqxNS2dSt6QyE29N6DK9eCInbMp
=/ZrZ
-----END PGP SIGNATURE-----

--------------070903050309070100070205
Content-Type: text/plain;
 name="via-velocity.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="via-velocity.patch"

diff -ru linux-2.6.29.1-orig/drivers/net/via-velocity.c linux-2.6.29.1/drivers/net/via-velocity.c
--- linux-2.6.29.1-orig/drivers/net/via-velocity.c	2009-04-02 22:55:27.000000000 +0200
+++ linux-2.6.29.1/drivers/net/via-velocity.c	2009-04-24 13:09:45.945318255 +0200
@@ -2226,8 +2226,8 @@
 	spin_lock(&vptr->lock);
 	isr_status = mac_read_isr(vptr->mac_regs);
 
-	/* Not us ? */
-	if (isr_status == 0) {
+	/* Not us or garbage ? */
+	if (isr_status == 0 || isr_status == 0xffffffff) {
 		spin_unlock(&vptr->lock);
 		return IRQ_NONE;
 	}
@@ -2236,10 +2236,11 @@
 
 	/*
 	 *	Keep processing the ISR until we have completed
-	 *	processing and the isr_status becomes zero
+	 *	processing and the isr_status becomes zero or
+	 *	we read out some garbage
 	 */
 
-	while (isr_status != 0) {
+	while (isr_status != 0 && isr_status != 0xffffffff) {
 		mac_write_isr(vptr->mac_regs, isr_status);
 		if (isr_status & (~(ISR_PRXI | ISR_PPRXI | ISR_PTXI | ISR_PPTXI)))
 			velocity_error(vptr, isr_status);

--------------070903050309070100070205--
