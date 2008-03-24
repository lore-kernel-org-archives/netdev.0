From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] de2104x: remove BUG_ON() when changing media type
Date: Sun, 23 Mar 2008 20:45:14 -0600
Message-ID: <20080324024514.GB474@colo.lackof.org>
References: <200801262158.12016.linux@rainbow-software.org> <200802181740.44196.linux@rainbow-software.org> <20080225071505.GC26674@colo.lackof.org> <200802251845.51562.linux@rainbow-software.org> <47C30051.3020909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ondrej Zary <linux@rainbow-software.org>,
	Grant Grundler <grundler@parisc-linux.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:55437 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753119AbYCXCp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 22:45:26 -0400
Content-Disposition: inline
In-Reply-To: <47C30051.3020909@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 25, 2008 at 12:52:17PM -0500, Jeff Garzik wrote:
> Ondrej Zary wrote:
>> When the chip dies (probably because of a bug somewhere in the driver), 
>> de_stop_rxtx() fails and changing the media type crashes the whole 
>> machine. Replace BUG_ON() in de_set_media() with a warning.
>> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
>> --- linux-2.6.24-orig/drivers/net/tulip/de2104x.c	2008-02-25 
>> 18:27:34.000000000 +0100
>> +++ linux-2.6.24-pentium/drivers/net/tulip/de2104x.c	2008-02-25 
>> 18:34:56.000000000 +0100
>> @@ -910,7 +910,8 @@
>>  	unsigned media = de->media_type;
>>  	u32 macmode = dr32(MacMode);
>>  -	BUG_ON(de_is_running(de));
>> +	if (de_is_running(de))
>> +		printk(KERN_WARNING "%s: chip is running while changing media!\n", 
>> de->dev->name);
>
> Certainly a sane improvement...

Jeff, 
The above patch was applied and fixes the 'panic' part of the problme.
Can you take a look at this patch to fix the "chip is still running"
part of this bug?

BTW, I inherited a bug report for the same symptom:
    http://bugzilla.kernel.org/show_bug.cgi?id=3156

thanks,
grant

Signed-off-by: Grant Grundler

--- linux-2.6.23/drivers/net/tulip/de2104x.c	2007-10-09 13:31:38.000000000 -0700
+++ linux-2.6.23/drivers/net/tulip/de2104x.c-ggg	2007-11-02 23:24:46.000000000 -0700
@@ -842,7 +842,7 @@
 static void de_stop_rxtx (struct de_private *de)
 {
 	u32 macmode;
-	unsigned int work = 1000;
+	unsigned int i = 1300/100;
 
 	macmode = dr32(MacMode);
 	if (macmode & RxTx) {
@@ -850,10 +850,14 @@
 		dr32(MacMode);
 	}
 
-	while (--work > 0) {
+	/* wait until in-flight frame completes.
+	 * Max time @ 10BT: 1500*8b/10Mbps == 1200us (+ 100us margin)
+	 * Typically expect this loop to end in < 50 us on 100BT.
+	 */
+	while (--i) {
 		if (!de_is_running(de))
 			return;
-		cpu_relax();
+		udelay(100);
 	}
 
 	printk(KERN_WARNING "%s: timeout expired stopping DMA\n", de->dev->name);
