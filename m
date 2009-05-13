From: Radek Podgorny <radek@podgorny.cz>
Subject: Re: via velocity trivial patch
Date: Wed, 13 May 2009 15:03:51 +0200
Message-ID: <4A0AC537.70605@podgorny.cz>
References: <49F1A05A.8070802@podgorny.cz> <4A01FBF6.1090001@podgorny.cz> <20090507.150213.192379856.davem@davemloft.net> <4A04184E.5040507@podgorny.cz> <20090508192948.GA19016@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 180.129.broadband3.iol.cz ([85.70.129.180]:46388 "EHLO
	home.podgorny.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755787AbZEMNEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 09:04:30 -0400
Received: from [10.25.3.4] (simir.podoli.pjih.czf [10.25.3.4])
	by home.podgorny.cz (Postfix) with ESMTP id E5F7184B34
	for <netdev@vger.kernel.org>; Wed, 13 May 2009 15:04:28 +0200 (CEST)
In-Reply-To: <20090508192948.GA19016@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello,

so I've tried to study the source a bit more and don't really get some things.
Why is there a mac_write_isr() in the IRQ handling routine? Isn't ISR supposed
to be read-only? Even if not, why does it write the exact same value as it has
read just moments ago?

    ...
    isr_status = mac_read_isr(vptr->mac_regs);

    /* Not us ? */
    if (isr_status == 0) {
        spin_unlock(&vptr->lock);
        return IRQ_NONE;
    }

    mac_disable_int(vptr->mac_regs);

    /*
     *  Keep processing the ISR until we have completed
     *  processing and the isr_status becomes zero
     */

    while (isr_status != 0) {
        mac_write_isr(vptr->mac_regs, isr_status);
        ...
        isr_status = mac_read_isr(vptr->mac_regs);
    ...

Maybe the value is mangled on write. But even if it was, it should not affect
other devices, just the one in question, right?

The other way for ISR to show 0xffffffff is in device init but I experience
repetitive all-ones. :-( Will have to test it again to be really sure, though.

Do you have any links to datasheets or something so I can try to look up the specs?
Or, do you have any ideas what I should do next to debug (or help you debug)
the issue?

Thanks in advance
Radek Podgorny


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
> 
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
>> So I'm attaching the patch again. Now with the proper sign-off.
> 
> davem's life is probably simpler if you do not include anything
> after the patch.
> 
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkoKxTcACgkQ7mej6pjlbYTLtgCaAvmxl3/FLK4mmrznEiq7+XYD
TzAAnA+EewHvGOdKvwIIMZtisH+AQbsr
=3g6c
-----END PGP SIGNATURE-----
