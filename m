From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: IrDA woes..
Date: Tue, 31 Dec 2013 12:08:43 -0800
Message-ID: <CA+55aFz2CQ4B1JSpQ75TuQrrd9sUnhV+u=T2dWZY2NTTT5OmpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Samuel Ortiz <samuel@sortiz.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:46698 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659Ab3LaUIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 15:08:44 -0500
Received: by mail-ee0-f50.google.com with SMTP id c41so5789623eek.9
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 12:08:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, so nobody sane likely uses IrDA any more, but - surprise surprise
- some dive computers aren't sane. And there's reports of some really
excessive slowdowns with modern kernels (downloading the memory dump
from a dive computer taking 18 minutes on a 3.2-based kernel, and 80
minutes with a 3.11 kernel (it apparently takes 12 minutes on WinXP).

There has been basically zero changes to the driver in question
(stir4200), so the slowdown is likely due to generic networking or
irda changes.. Some timeout change or whatever.

I'm still waiting for a couple of IrDA USB dongles to try things out
on real hardware (UPS is apparently still having delivery issues, so
the dongles that were supposed to arrive today won't be here until
Thursday, and nobody sells those things in brick-and-mortar stores any
more). Maybe I can reproduce the slowness, maybe I can't. We'll see.

In the meantime, I am playing with IrDA attached to a pty, and hitting
interesting kernel oopses (unrelated side note: SELinux also hates
playing irda/pty games, you have to put things into permissive mode
etc).

One of the oopses seems simple: irda_attach() will do

        if (sk->sk_prot->disconnect(sk, flags))
                sock->state = SS_DISCONNECTING;

if the connection fails. But sk_prot->disconnect is NULL for IrDA, so
that will just oops. Apparently real devices don't end up ever
triggering that, but I don't think it can ever have worked.

The next one was harder to trigger, and is much less obvious, even if
it's also a trivial NULL pointer dereference:

  Unable to handle kernel NULL pointer dereference at 00000000000000d8
  IP: skb_copy+0x11
    rdi=0x0000000000000000
    rsi=0x0000000000000020 (GFP_ATMIC = __GFP_HIGH)
  Call trace:
    irlap_resend_rejected_frames
    irlap_state_nrm_s
    irlap_do_event
    irlap_driver_rcv
    __netif_receive_skb_core
    __netif_receive_skb
    process_backlog
    net_rx_action
    __do_softirq
    irq_exit

  Code:
        55                      push   %rbp
        b9 ff ff ff ff          mov    $0xffffffff,%ecx
        48 89 e5                mov    %rsp,%rbp
        41 55                   push   %r13
        41 54                   push   %r12
        53                      push   %rbx
        48 89 fb                mov    %rdi,%rbx
        4c 8b af d8 00 00 00    mov    0xd8(%rdi),%r13          <--
trapping instruction
        0f b6 93 aa 00 00 00    movzbl 0xaa(%rbx),%edx
        4c 2b af d0 00 00 00    sub    0xd0(%rdi),%r13

so it seems that irlap_resend_rejected_frames() does a skb_copy() with
a NULL skb. Which in turn seems to be due to corruption or lack of
locking, since the skb is the result of

      skb_queue_walk(&self->wx_list, skb) {
          ...

Does anybody have any ideas? Note that this is likely *not* a new thing.

                    Linus
