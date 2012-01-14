From: Michael Mueller <malware@t-online.de>
Subject: Re: de4x5
Date: Sat, 14 Jan 2012 18:55:22 +0100
Message-ID: <4F11C18A.1050802@t-online.de>
References: <4F0F641B.5090407@t-online.de> <CAP=VYLpWbcBae11fcQPcuPmdfvir7N6F9QMdzXip=i4mMHjxsQ@mail.gmail.com> <4F10A287.2070008@t-online.de> <4F11503F.6000106@t-online.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010501030806040202000007"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout11.t-online.de ([194.25.134.85]:34468 "EHLO
	mailout11.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755971Ab2ANRza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 12:55:30 -0500
In-Reply-To: <4F11503F.6000106@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010501030806040202000007
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Hi Paul,

I wrote [copy to you]:
>> When trying the de4x5 using 2.6.32 - which is what I can boot into
>> without too much problems - it did lock the machine while starting the
>> interface (ifconfig up). Sorry, but I do not feel like digging into this
>> just now.
[..]
> I changed the name from 'DE434/5' to 'DE434_5' since the slash seems to
> be no good idea within a file/directory name. This does yield a lockup
> with no message.

It hangs due to the usage of synchronize_irq within the interrupt
handler. It does not look like it was intended usage for this. Removing
this code it does not lock up anymore. But it is not working either.
Looking through the code it uses the same configuration values for BNC
and AUI which de2104x uses for AUI.

Changes done so far are appended as patch.


Michael

--------------010501030806040202000007
Content-Type: text/x-patch;
 name="de4x5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="de4x5.patch"

--- drivers/net/tulip/de4x5.c.orig	2011-12-09 17:57:05.000000000 +0100
+++ drivers/net/tulip/de4x5.c	2012-01-14 18:54:46.000000000 +0100
@@ -1551,8 +1551,6 @@
     if (test_and_set_bit(MASK_INTERRUPTS, (void*) &lp->interrupt))
 	printk("%s: Re-entering the interrupt handler.\n", dev->name);
 
-    synchronize_irq(dev->irq);
-
     for (limit=0; limit<8; limit++) {
 	sts = inl(DE4X5_STS);            /* Read IRQ status */
 	outl(sts, DE4X5_STS);            /* Reset the board interrupts */
@@ -3909,7 +3907,7 @@
     int i, status = 0, siglen = ARRAY_SIZE(de4x5_signatures);
 
     if (lp->chipset == DC21040) {
-	strcpy(name, "DE434/5");
+	strcpy(name, "DE434_5");
 	return status;
     } else {                           /* Search for a DEC name in the SROM */
 	int tmp = *((char *)&lp->srom + 19) * 3;

--------------010501030806040202000007--
