From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: r8169: is the work queue is initialized at wrong place?
Date: Fri, 19 Jul 2013 11:23:46 +0200
Message-ID: <23723601.GBD7pm82ZA@al>
References: <5838023.rAHnY47tlv@al> <2387149.B9WVEQm2aY@al> <20130719061017.GA3334@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:42753 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753672Ab3GSJXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 05:23:51 -0400
Received: by mail-we0-f176.google.com with SMTP id q57so357730wes.35
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 02:23:50 -0700 (PDT)
In-Reply-To: <20130719061017.GA3334@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 19 July 2013 08:10:17 Francois Romieu wrote:
> Peter Wu <lekensteyn@gmail.com> :
> > On Thursday 18 July 2013 23:53:43 Francois Romieu wrote:
> [...]
> 
> > > (or cancel_work_sync in rtl8169_close to reduce the scope)
> > 
> > Will this also work with multiple adapters? I currently have an on-board
> > chip using the r8169 driver and a separate PCI card.
> 
> As stated by David, yes.
Thanks for confirming.

> > > I do not see how the current code could hurt but it's really ugly.
> > 
> > When I googled for the warning, I found some hint about something not
> > being
> > initialized. From that I guessed that rtl_open is never called when the
> > network interface is not brought up (which seems to match the
> > documentation of struct net_device_ops[1]).
> 
> You guessed right. Please note that the relevant struct is zeroed during
> initialization (see net/core/dev.c::alloc_netdev_mqs). While it's true
> that the struct is not initialized for use by the device, cancel_work_sync
> will cope with it (bail out thanks to a 0 bitflag).
> 
> You can ignore the warning and proceed with the driver as-is.
Well, the driver appears to work, but due to this I also miss future lockdep 
warnings until I reboot.

> I'll fix it anyway. It's too ugly to be kept as is.
> 
> Side-note: if you can publish your eeprom reading code, it would be
> interesting to know how it differs from what has already been tried
> in the past.
I will certainly do this. Right not I am leveraging the existing 93cx6 driver 
in the kernel. I am having difficulties with making the reads reliable though, 
only after writing at least once to the EEPROM (which is logged as timeout, 
although the word is written), I am able to read it. Otherwise, I will only 
read 00s. This is on an external RTL8169SB Gbe PCI card (on the chip itself, I 
can read RTL8169SC though). (bought for 10$ on Ebay :P).

Initially, this chip could not detect a link (it reported itself with PCI 
VID:PID 10ec:8129), probably due to a bad driver that overwrote part of the 
EEPROM (maybe this one[1]?). After writing the EEPROM signature (29 81) (and 
making the card load from EEPROM by writing 0x40 to register 0x50)), the card 
MAC version does not get recognized and is detected as generic "RTL8169" 
(unbind/bind). After a reboot, the card got detected "properly" 
RTL8169sb/8110sb ("properly", because I really see "RTL8169SC" on the 
chip...).

On another onboard RTL8111E chip, I only read FFs. I haven't tried writing to 
that one as it is working perfectly.

Regards,
Peter

 [1]: http://www.gossamer-threads.com/lists/linux/kernel/990061
