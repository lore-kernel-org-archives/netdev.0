From: Radek Podgorny <radek@podgorny.cz>
Subject: Re: via velocity trivial patch
Date: Fri, 08 May 2009 13:32:30 +0200
Message-ID: <4A04184E.5040507@podgorny.cz>
References: <49F1A05A.8070802@podgorny.cz>	<4A01FBF6.1090001@podgorny.cz> <20090507.150213.192379856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 180.129.broadband3.iol.cz ([85.70.129.180]:38743 "EHLO
	home.podgorny.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926AbZEHLce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 07:32:34 -0400
In-Reply-To: <20090507.150213.192379856.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi David,

thanks for the feedback. I apologize for the inconvenience, this is my
first try on kernel contribution.

The "some garbage" are just my words for what Jeff Garzik called "also
bail if 0xffffffff (hardware fault / hardware unplugged)" in
http://lkml.indiana.edu/hypermail/linux/kernel/0406.0/0500.html in 2004.
Should I change that?

Anyway, I've verified this is really happening on my hardware when
multiple via velocity devices share the same interrupt. The one the
interrupt is for reads the correct ISR value, the others sometimes read
0 and sometimes 0xffffffff. I'm not educated enough to tell why.

Reasons to include the fix:
1) Someone smarter than me suggested it (Jeff Garzik).
2) Fixed my problem.
3) Does not introduce a new problem.

So I'm attaching the patch again. Now with the proper sign-off.

Sincerely
Radek Podgorny

Signed-off-by: Radek Podgorny <radek@podgorny.cz>

diff -ru linux-2.6.29.1-orig/drivers/net/via-velocity.c linux-2.6.29.1/drivers/net/via-velocity.c
- --- linux-2.6.29.1-orig/drivers/net/via-velocity.c	2009-04-02 22:55:27.000000000 +0200
+++ linux-2.6.29.1/drivers/net/via-velocity.c	2009-04-24 13:09:45.945318255 +0200
@@ -2226,8 +2226,8 @@
 	spin_lock(&vptr->lock);
 	isr_status = mac_read_isr(vptr->mac_regs);
 
- -	/* Not us ? */
- -	if (isr_status == 0) {
+	/* Not us or garbage ? */
+	if (isr_status == 0 || isr_status == 0xffffffff) {
 		spin_unlock(&vptr->lock);
 		return IRQ_NONE;
 	}
@@ -2236,10 +2236,11 @@
 
 	/*
 	 *	Keep processing the ISR until we have completed
- -	 *	processing and the isr_status becomes zero
+	 *	processing and the isr_status becomes zero or
+	 *	we read out some garbage
 	 */
 
- -	while (isr_status != 0) {
+	while (isr_status != 0 && isr_status != 0xffffffff) {
 		mac_write_isr(vptr->mac_regs, isr_status);
 		if (isr_status & (~(ISR_PRXI | ISR_PPRXI | ISR_PTXI | ISR_PPTXI)))
 			velocity_error(vptr, isr_status);

David Miller wrote:
> From: Radek Podgorny <radek@podgorny.cz>
> Date: Wed, 06 May 2009 23:07:02 +0200
> 
>> I've sent the following mail to Francois Romieu <romieu@fr.zoreil.com>
>> but did not get any reply. So I'm sending directly here. It's a trivial
>> patch for via-velocity driver.
> 
> "some garbage"...
> 
> Why would the interrupt status register give us all 1's
> if it is properly initialized?  I should report a zero,
> rather than "some garbage".
> 
> You also failed to provide a proper sign-off as described
> in Documentation/SubmittingPatches
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkoEGE0ACgkQ7mej6pjlbYSKVgCcCIr64sZq9N+yQhdjMgui3HfP
6ZcAnjXkaeVuiCA4vXkwK1+IQNfLO/9Q
=XZap
-----END PGP SIGNATURE-----
