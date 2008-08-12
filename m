From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: latest -git: kernel hangs when pulling the plug on 8139too
Date: Tue, 12 Aug 2008 19:20:24 +0200
Message-ID: <19f34abd0808121020l4a0552a0v3d48b181d980d600@mail.gmail.com>
References: <19f34abd0808110949n5d7d363es66325b87a8fb0fd1@mail.gmail.com>
	 <20080811192739.GB5791@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Alexey Dobriyan" <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:27908 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbYHLRUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 13:20:25 -0400
Received: by py-out-1112.google.com with SMTP id p76so1563459pyb.10
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 10:20:24 -0700 (PDT)
In-Reply-To: <20080811192739.GB5791@martell.zuzino.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 9:27 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
> On Mon, Aug 11, 2008 at 06:49:13PM +0200, Vegard Nossum wrote:
>> I am experiencing a system hang as soon as pull the cable out of eth0.
>> Kernel version is unmodified latest -git
>> (v2.6.27-rc2/796aadeb1b2db9b5d463946766c5bbfd7717158c) and my network
>> driver is 8139too (for both eth0 and eth1).
>>
>> I am running netconsole on eth0 (the interface which I disconnect).
>>
>> A bit of serial console (ttyS0) output:
>>
>> Linux version 2.6.27-rc2-00325-g796aade (vegardno@ben.ifi.uio.no) (gcc
>> version 4.1.2 20071124 (Red Hat 4.1.2-42)) #2 SMP PREEMPT Mon Aug 11
>> 18:29:29 CEST 2008
>> ...
>> Kernel command line: ro root=/dev/VolGroup00/LogVol00 rhgb
>> console=tty0 console=ttyS0,115200 ignore_loglevel debug initcall_debug
>> nmi_watchdog=1 panic=30 sysrq_always_enabled
>> netconsole=@192.168.0.172/,@192.168.0.11/ 3
>> ...
>> calling  rtl8139_init_module+0x0/0x20
>> 8139too Fast Ethernet driver 0.9.28
>> 8139too 0000:02:01.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
>> eth0: RealTek RTL8139 at 0xf881ac00, 00:10:a7:09:48:52, IRQ 18
>> eth0:  Identified 8139 chip type 'RTL-8139C'
>> 8139too 0000:02:05.0: PCI INT A -> GSI 21 (level, low) -> IRQ 21
>> eth1: RealTek RTL8139 at 0xf881c000, 00:16:ec:ee:ad:b9, IRQ 21
>> eth1:  Identified 8139 chip type 'RTL-8100B/8139D'
>> initcall rtl8139_init_module+0x0/0x20 returned 0 after 37 msecs
>> ...
>> eth0: link down
>> [hangs here; num lock + scroll lock flashing]
>> [reboots automatically, probably due to NMI watchdog?]
>>
>> There is no detailed crash output on either tty0 or ttyS0. Keyboard
>> sysrq does not work.
>>
>> Is it expected that pulling the plug on an interface running
>> netconsole should hang the machine?
>
> Of course, no!

I meant: "Is this a known problem?" I guess it came out wrong. :-)

>
>> Is there anything I can do to help narrow down the problem?
>
> I have two realteks and one of them showed very similar symptoms:
> cable unplug and immediate panic without anything. If this is a same
> bug, it's pretty old.

Now I've tried to use kdump to catch the panic, but it doesn't help :-(

At boot, I have this:

    Reserving 64MB of memory at 16MB for crashkernel (System RAM: 1023MB)

Loading the dump-capture kernel succeeds:

    # build/sbin/kexec -p --initrd=/boot/initrd-2.6.23.8-34.fc7.img
--append="ro root=/dev/VolGroup00/LogVol00 rhgb console=tty0
console=ttyS0,115200 nmi_watchdog=1 panic=30 sysrq_always_enabled
maxcpus=1 irqpoll reset_devices 3" /boot/testing/bzImage

...but after pulling the cable and seeing the keyboard blink for five
seconds, the CPU resets without running the new kernel (i.e. it
reboots and I see the BIOS messages, etc.).

Maybe I did something wrong? (Though I don't think so.)

I will try to replace some printk()s to early_printk() (allows me to
maybe capture some messages on ttyS0 without trying to send anything
over netconsole).


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
