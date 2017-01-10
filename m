From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/3] Revert "icmp: avoid allocating large
 struct on stack"
Date: Tue, 10 Jan 2017 13:48:11 -0800
Message-ID: <1484084891.21472.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1483985224.21472.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170109.135259.988711786570465428.davem@davemloft.net>
         <CAM_iQpUbcVogq7jGePkgPJ0z_J=46hnK8KcTiX1svVXr1Hoh-w@mail.gmail.com>
         <20170110.131223.748150430551443881.davem@davemloft.net>
         <CAM_iQpV0V23fndi6DOW1gu9kq+2UufHNrnfRYCME7uOOLCaX-Q@mail.gmail.com>
         <20170110210820.1c5dbc87@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33325 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752514AbdAJVsO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 16:48:14 -0500
Received: by mail-pf0-f194.google.com with SMTP id 127so30593732pfg.0
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 13:48:13 -0800 (PST)
In-Reply-To: <20170110210820.1c5dbc87@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-10 at 21:08 +0100, Jesper Dangaard Brouer wrote:
> On Tue, 10 Jan 2017 10:44:59 -0800 Cong Wang <xiyou.wangcong@gmail.com> wrote:
> 
> > On Tue, Jan 10, 2017 at 10:12 AM, David Miller <davem@davemloft.net> wrote:
> [...]
> > > You can keep showing us how expertly you can deflect the real
> > > issue we are discussion here, but that won't improve the situation
> > > at all I am afraid.  
> > 
> > Of course, there are just too many people too lazy to do a google search:
> > 
> > https://lists.debian.org/debian-kernel/2013/05/msg00500.html
> 
> My analysis of the problem shown in above link is not related to using
> all the stack space, but instead that skb->cb was not cleared.  This
> can cause the ip_options_echo() call in icmp_send() to access garbage
> as this is: __ip_options_echo(dopt, skb, &IPCB(skb)->opt).
> 
> Fixed by commit a622260254ee ("ip_tunnel: fix kernel panic with icmp_dest_unreach")
>  https://git.kernel.org/torvalds/c/a622260254ee
> 
> Thus, it is (likely) the __ip_options_echo() call that violates stack
> access, as it is passed in a pointer to the stack, and advance this
> based on garbage "optlen".
> 

I totally agree.

This can not be stack being too small in current kernels.

> #0 [ffff88003fd03798] machine_kexec at ffffffff81027430
> #1 [ffff88003fd037e8] crash_kexec at ffffffff8107da80
> #2 [ffff88003fd038b8] panic at ffffffff81540026
> #3 [ffff88003fd03938] __stack_chk_fail at ffffffff81037f77
> #4 [ffff88003fd03948] icmp_send at ffffffff814d5fec
> #5 [ffff88003fd03b78] dev_hard_start_xmit at ffffffff8146e032
> #6 [ffff88003fd03bc8] sch_direct_xmit at ffffffff81487d66
> #7 [ffff88003fd03c08] __qdisc_run at ffffffff81487efd
> #8 [ffff88003fd03c48] dev_queue_xmit at ffffffff8146e5a7
> #9 [ffff88003fd03c88] ip_finish_output at ffffffff814ab596
> #10 [ffff88003fd03ce8] __netif_receive_skb at ffffffff8146ed13
> #11 [ffff88003fd03d88] napi_gro_receive at ffffffff8146fc50
> #12 [ffff88003fd03da8] e1000_clean_rx_irq at ffffffff813bc67b
> #13 [ffff88003fd03e48] e1000e_poll at ffffffff813c3a20
> #14 [ffff88003fd03e98] net_rx_action at ffffffff8146f796
> #15 [ffff88003fd03ee8] __do_softirq at ffffffff8103ebb9
> #16 [ffff88003fd03f38] call_softirq at ffffffff8154444c
> #17 [ffff88003fd03f50] do_softirq at ffffffff810047dd
> #18 [ffff88003fd03f80] do_IRQ at ffffffff81003f6c

Total stack used is about 3FFF - 3938, which is less than 2KB.

x86_64 is supposed to have at least 16 KB irq stacks.
