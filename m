From: Ingo Molnar <mingo@elte.hu>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- connection between
	HPET and lockups found
Date: Tue, 19 Aug 2008 15:08:07 +0200
Message-ID: <20080819130807.GB20210@elte.hu>
References: <452065.84245.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:42298 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753373AbYHSNIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 09:08:42 -0400
Content-Disposition: inline
In-Reply-To: <452065.84245.qm@web82105.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Witbrodt <dawitbro@sbcglobal.net> wrote:

> > Just to make sure: on a working kernel, do you get the HPET 
> > messages? I.e. does the hpet truly work in that case?
> 
> On the "fileserver", where 2.6.25 works but 2.6.26 locks up, the HPET 
> _does_ work on a working kernel:
> 
> $ uname -r
> 2.6.26.revert1
> 
> $ dmesg | grep -i hpet
> ACPI: HPET 77FE80C0, 0038 (r1 RS690  AWRDACPI 42302E31 AWRD       98)
> ACPI: HPET id: 0x10b9a201 base: 0xfed00000
> hpet clockevent registered
> hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
> hpet0: 4 32-bit timers, 14318180 Hz
> hpet_resources: 0xfed00000 is busy

btw., you might also want to look into drivers/char/hpet.c and 
instrument that a bit. In particular the ioremap()s done there will show 
exactly how the hpet is mapped.

In particular this bit:

                if (hpet_is_known(hdp)) {
                        printk(KERN_DEBUG "%s: 0x%lx is busy\n",
                                __func__, hdp->hd_phys_address);
                        iounmap(hdp->hd_address);
                        return AE_ALREADY_EXISTS;
                }


suggests that you've got multiple hpets listed by the BIOS?

> What I didn't realize is that the "desktop" machine, where 2.6.26 has 
> always "worked", does NOT have a working HPET after all, even though I 
> have enabled all HPET options in .config:

that's OK - you've still got a regression.

> (I don't know what is going on with "desktop": does the motherboard 
> lack HPET, or does the Linux kernel not support the HPET hardware on 
> the motherboard?)

Whether the system has a hpet listed in the BIOS data structures can be 
seen in acpidump [in the pmtools package]

Even if the BIOS does not list it, the system might have hpet in the 
chipset - hpet=force can be tried to force-enable it.

	Ingo
