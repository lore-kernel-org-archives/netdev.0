From: Radek Podgorny <radek@podgorny.cz>
Subject: Re: via velocity trivial patch
Date: Sun, 10 May 2009 23:06:31 +0200
Message-ID: <4A0741D7.1050509@podgorny.cz>
References: <49F1A05A.8070802@podgorny.cz> <4A01FBF6.1090001@podgorny.cz> <20090507.150213.192379856.davem@davemloft.net> <4A04184E.5040507@podgorny.cz> <20090508192948.GA19016@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 180.129.broadband3.iol.cz ([85.70.129.180]:33285 "EHLO
	home.podgorny.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbZEJVGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2009 17:06:35 -0400
Received: from [10.25.3.4] (simir.podoli.pjih.czf [10.25.3.4])
	by home.podgorny.cz (Postfix) with ESMTP id 910B786560
	for <netdev@vger.kernel.org>; Sun, 10 May 2009 23:06:32 +0200 (CEST)
In-Reply-To: <20090508192948.GA19016@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi Francois,

Francois Romieu wrote:
> Radek Podgorny <radek@podgorny.cz> :
> [...]
>> Anyway, I've verified this is really happening on my hardware when
>> multiple via velocity devices share the same interrupt. The one the
>> interrupt is for reads the correct ISR value, the others sometimes read
>> 0 and sometimes 0xffffffff. I'm not educated enough to tell why.
> 
> Your quad port network card includes its own pci bus, right ?
> If so can you send a 'lspci -vt' of the host ?

I don't know much about the card except for it's this model
http://www.roc-noc.com/product.php?productid=55. The output of lspci follows:

radek@europa ~ % sudo lspci -vt 
- -[0000:00]-+-00.0  Intel Corporation 82815 815 Chipset Host Bridge and Memory Controller Hub
           +-01.0-[0000:01]----00.0  NVidia / SGS Thomson (Joint Venture) Riva128
           +-1e.0-[0000:02-03]--+-00.0-[0000:03]--+-08.0  VIA Technologies, Inc. VT6120/VT6121/VT6122 Gigabit Ethernet Adapter
           |                    |                 +-09.0  VIA Technologies, Inc. VT6120/VT6121/VT6122 Gigabit Ethernet Adapter
           |                    |                 +-0a.0  VIA Technologies, Inc. VT6120/VT6121/VT6122 Gigabit Ethernet Adapter
           |                    |                 \-0b.0  VIA Technologies, Inc. VT6120/VT6121/VT6122 Gigabit Ethernet Adapter
           |                    \-04.0  Intersil Corporation Prism 2.5 Wavelan chipset
           +-1f.0  Intel Corporation 82801BA ISA Bridge (LPC)
           +-1f.1  Intel Corporation 82801BA IDE U100 Controller
           +-1f.2  Intel Corporation 82801BA/BAM USB Controller #1
           +-1f.3  Intel Corporation 82801BA/BAM SMBus Controller
           +-1f.4  Intel Corporation 82801BA/BAM USB Controller #1
           \-1f.5  Intel Corporation 82801BA/BAM AC'97 Audio Controller

>> Reasons to include the fix:
>> 1) Someone smarter than me suggested it (Jeff Garzik).
>> 2) Fixed my problem.
>> 3) Does not introduce a new problem.
> 
> 3. probably stands: there is no reason for the driver to see a
> 0xffffffff interupt status register (hardware fault or unplug apart).
> 
> Well, almost:
> 
> $ grep mac.*isr drivers/net/via-velocity.h
> #define mac_read_isr(regs)              readl(&((regs)->ISR))
> #define mac_write_isr(regs, x)          writel((x),&((regs)->ISR))
> #define mac_clear_isr(regs)             writel(0xffffffffL,&((regs)->ISR))
> 
> I can figure that there is a window through which the 2nd, 3rd and 4th
> devices can read a 0xffffffff when they are brought up but it should
> not be noticeable after this stage (and it may happen on the 1st device
> as well if it shares its interrupt with some other device).
> 
> Does it match your experience ?

Well I haven't done any extensive data gathering (how often the 0xffffffff situation
happens and so on) because I've found a way way to fix (workaround?) it and
unfortunately it's a production machine. But, if you have any suggestions on
what I shall do to help you debug it, please let me know. I can do some tests for
short periods of time during a day.
> 
>> So I'm attaching the patch again. Now with the proper sign-off.
> 
> davem's life is probably simpler if you do not include anything
> after the patch.
> 
Thanks for the info. I don't mean to complicate things.

Radek Podgorny
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkoHQdYACgkQ7mej6pjlbYQOYgCgoe19dnfkh74del3hXODGPEM1
RqYAn05j7ysqpJykjxyGdHsMB3x6FkV7
=bUxK
-----END PGP SIGNATURE-----
