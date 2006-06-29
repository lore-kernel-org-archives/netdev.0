From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.17-mm4
Date: Fri, 30 Jun 2006 01:05:17 +0200
Message-ID: <20060629230517.GA18838@elte.hu>
References: <20060629013643.4b47e8bd.akpm@osdl.org> <6bffcb0e0606291339s69a16bc5ie108c0b8d4e29ed6@mail.gmail.com> <20060629204330.GC13619@redhat.com> <20060629210950.GA300@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:63129 "EHLO mx3.mail.elte.hu")
	by vger.kernel.org with ESMTP id S933081AbWF2XKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 19:10:04 -0400
To: Dave Jones <davej@redhat.com>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060629210950.GA300@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> i'm too hunting use-after-free bugs - the ones fixed below fix certain 
> crashes, but i'm still seeing a nasty one.
> 
> the crash is independent on lockdep enabled or disabled. See:
> 
>   http://redhat.com/~mingo/misc/
> 
> for the config and the crash.log.

ok, managed to debug the reason for this crash via .config bisecting, 
it's caused by:

   CONFIG_SCSI_PATA_QDI=y

which is a new option in -mm4. Disabling it makes the -mm4 allyesconfig 
bzImage work again.

and running qdi_init() either causes memory corruption, or it causes 
something to be misprogrammed on the motherboard (something wrt. irq 
routing perhaps), which crashes the box afterwards. (but that happens 
dozens of initcalls later, so the breakage is subtle)

it does things like:

        static const unsigned long qd_port[2] = { 0x30, 0xB0 };
        static const unsigned long ide_port[2] = { 0x170, 0x1F0 };

        [...]
                unsigned long port = qd_port[i];
        [...]
                        r = inb_p(port);
                        outb_p(0x19, port);
                        res = inb_p(port);
                        outb_p(r, port);

so it reads/writes port 0x30 and 0xb0. Are those used by something else 
on modern hardware?

i know, i shouldnt be running an ancient Vesa Local Bus driver's init 
routine, but still, the allyesconfig bzImage is quite useful in finding 
various bugs ...

	Ingo
