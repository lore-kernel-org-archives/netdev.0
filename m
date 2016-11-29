From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 4.9-rc7: (forcedeth?) BUG: sleeping function called from invalid
 context at kernel/irq/manage.c:110
Date: Tue, 29 Nov 2016 11:11:08 -0800
Message-ID: <CAADWXX8GM5Xdf1Of09ABXEB8eb=eVqPjHTaT7ZzcStnX8=cO_A@mail.gmail.com>
References: <alpine.LRH.2.20.1611292222200.31348@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36519 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752046AbcK2TLJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 14:11:09 -0500
Received: by mail-io0-f170.google.com with SMTP id m5so169272228ioe.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 11:11:09 -0800 (PST)
In-Reply-To: <alpine.LRH.2.20.1611292222200.31348@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 12:26 PM, Meelis Roos <mroos@linux.ee> wrote:
> This is 4.9-rc7 on Sun Ultra 20 (Opteron 175 on NVidia chipset PC with
> NVidia ethernet).
>
> BUG: sleeping function called from invalid context at kernel/irq/manage.c:110

Hmm. No changes in either forcedeth or in the synchronize_irq() debugging.

It seems to be due to netconsole. Did you enable new debugging (like
the DEBUG_ATOMIC_SLEEP config option) or change any netconsole things?

It looks like it's simply the dev_info() call in usb_add_hcd():

        dev_info(hcd->self.controller, "%s\n", hcd->product_desc);

and the printk() in amd64_edac_init():

        printk(KERN_INFO "AMD64 EDAC driver v%s\n", EDAC_AMD64_VERSION);

and yes, netconsole does "write_msg()" which is run with interrupts
disabled and the 'target_list_lock' spinlock held.

So when netpoll_send_udp() then calls down to the NIC poll routine, we
definitely are in an atomic context.

But none of this looks new. I don't see _anything_ in any of these
areas that has changed since 4.8.

Which is why I suspect you changed something in your setup wrt
netconsole or your kernel config?

                 Linus
