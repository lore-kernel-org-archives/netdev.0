From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: forcedeth problems on 2.6.20-rc6-mm3
Date: Thu, 08 Feb 2007 21:57:17 -0500
Message-ID: <45CBE30D.5030006@nvidia.com>
References: <45C6BCE5.90103@shaw.ca>	 <20070204213603.a5bce839.akpm@linux-foundation.org>	 <45C6C531.20508@shaw.ca>	 <20070204221741.63152cbe.akpm@linux-foundation.org> <523e55a00702081326j43de05e3hdd8cf35e946eae9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050806070701070306040204"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Robert Hancock <hancockr@shaw.ca>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: David Ford <firefighterblu3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:13278 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946103AbXBIEvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 23:51:25 -0500
In-Reply-To: <523e55a00702081326j43de05e3hdd8cf35e946eae9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050806070701070306040204
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Ford wrote:
> On 2/5/07, *Andrew Morton* <akpm@linux-foundation.org 
> <mailto:akpm@linux-foundation.org>> wrote:
> 
>     On Sun, 04 Feb 2007 23:48:33 -0600 Robert Hancock <hancockr@shaw.ca
>     <mailto:hancockr@shaw.ca>> wrote:
> 
>      > Andrew Morton wrote:
>      > > On Sun, 04 Feb 2007 23:13:09 -0600 Robert Hancock <
>     hancockr@shaw.ca <mailto:hancockr@shaw.ca>> wrote:
>      > >
>      > >> Something's busted with forcedeth in 2.6.20-rc6-mm3 for me
>     relative to
>      > >> 2.6.20-rc6. There's no errors in dmesg, but it seems no
>     packets ever get
>      > >> received and so the machine can't get an IP address. I tried
>     reverting
>      > >> all the -mm changes to drivers/net/forcedeth.c, which didn't
>     help. The
>      > >> network controller shares an IRQ with the USB OHCI controller
>     which is
>      > >> receiving interrupts, so it doesn't seem like an interrupt routing
>      > >> problem, though I suppose something wierd could be happening
>     there.
>      > >>
>      > >> This is on an Asus A8N-SLI Deluxe (CK804 chipset) on x86_64.
>      > >>
>      > >> Any suggestions on how to debug/what to try reverting to see
>     what's
>      > >> causing this?
>      > >
>      > > There are many forcedeth changes in git-netdev-all.patch.  Can you
>      > > try reverting drivers/net/forcedeth.c back to the unpatched version
>      > > from 2.6.20-rc6?
>      > >
>      > > Thanks.
>      > >
>      >
>      > That's essentially what I did, it didn't appear to help. I assume
>     the
>      > problem must lie elsewhere..
>      >
> 
>     doh, I missed that.
> 
>     It's presumably not the driver and nobody else seems to be hitting
>     this, so
>     it must be something peculiar to your setup.  But I don't know what it
>     might be, sorry.
> 
> 
> 
> Actually it has been reported by several other people here including 
> myself but it seems to have been overlooked here ;)
> 
> See the messages with forcedeth in the subject line over the past few 
> weeks.
> 
> I put 2.6.20-gentoo on my machine this weekend with debug printks 
> enabled and right now I have yet to lose connectivity -- going on ~20 
> hours worth.
> 
> Previously I would lose connectivity within minutes of booting up.  I 
> had a script set up that detected the ping loss of a gateway and would 
> restart both interfaces (dual onboard nics).
> 
> Tonight I will disable the debug printks and see if the system remains 
> online.  There was a big patch applied to forcedeth for 2.6.20, 
> previously I was having these issues for several of the -19 series.
> 
> David

For all those who are having issues, please try out the attached patch.

Ayaz


-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------

--------------050806070701070306040204
Content-Type: text/plain;
 name="forcedeth_napi_fix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="forcedeth_napi_fix"

--- orig/drivers/net/forcedeth.c	2007-02-08 21:41:59.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-02-08 21:44:53.000000000 -0500
@@ -3104,13 +3104,17 @@
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	unsigned long flags;
+	u32 retcode;
 
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 		pkts = nv_rx_process(dev, limit);
-	else
+		retcode = nv_alloc_rx(dev);
+	} else {
 		pkts = nv_rx_process_optimized(dev, limit);
+		retcode = nv_alloc_rx_optimized(dev);
+	}
 
-	if (nv_alloc_rx(dev)) {
+	if (retcode) {
 		spin_lock_irqsave(&np->lock, flags);
 		if (!np->in_shutdown)
 			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);

--------------050806070701070306040204--
