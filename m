From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Sat, 23 Aug 2008 04:42:52 -0700 (PDT)
Message-ID: <959691.49749.qm@web82107.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Vivek Goyal <vgoyal@redhat.com>,
	Bill Fink <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82107.mail.mud.yahoo.com ([209.191.84.220]:26763 "HELO
	web82107.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752723AbYHWLmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 07:42:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> pnp 00:0d: mem resource (0xfed00000-0xfed000ff) overlaps 0000:00:14.0
> BAR 1 (0xfed00000-0xfed003ff), disabling
> request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.0) [fa00,
> fa0f] conflict 0
> request_resource: root: (PCI mem) [0, ffffffffffffffff], new:
> (0000:00:14.0) [fed00000, fed003ff] conflict 1
> pci 0000:00:14.0: BAR 1: can't allocate resource
> piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xfa00, revision 0
> 
> 
> because  (0000:00:14.0) [fed00000, fed003ff]  conflicts to (reserved)
> [fec00000, ffffffff] from e820.

[...]

> so old kernel lapic 0xfee0000, is insert at first, it will prevent
> 0xfec, ... 0xfffffff from e820 to be registered,
> then (0000:00:14.0) [fed00000, fed003ff] got chance to be
> registered..., timer will work...
> 
> 
> root cause could be the chipset BAR1
> request_resource: root: (PCI mem) [0, ffffffffffffffff], new:
> (0000:00:14.0) [fed00000, fed003ff] conflict 1
> is not handled properly...
> 
> guess when it can not get request_resource, it could clear that
> BAR1...may need one quirk to save that.
> just like we trust IO APIC addr in BAR for some devices.

Ahh, thank you for reviewing that with me.  It looks like you are
getting very close to a fix.

FYI, I have asked the other user who first reported a similar problem
(back in May) to try booting his kernel with "hpet=disable" and
report his results here.  We cannot be sure that his problem is
identical to mine, but I believe he has been compiling his own
kernels since May by manually reverting commit number 3def3d6d.

I'm hoping that he will be able to help us test patches which attempt
to fix the problem, but my understanding is that he is using the
machine quite heavily... so he may not be willing to do as much
testing as I.

I do know that his kernel hangs at a different point in the kernel
sources:  mine hangs before inet_init() returns, while his hangs
in ide_scan_pcibus() [or pci_init(), if he tried to add printk's
to the previous function, trying to get more info].

I'm hoping that the changes in 3def3d6d aren't going to force the
kernel team to create a different quirk for each motherboard that
experiences kernel hangs!  Once 2.6.26, there is some possibility
that you will start seeing a lot more reports of it.  (I'm hoping
not, though.)


Thanks,
Dave W.
