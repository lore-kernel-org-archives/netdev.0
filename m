From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][net-next] gianfar: Simplify MQ polling to avoid soft
 lockup
Date: Mon, 14 Oct 2013 07:34:27 -0700
Message-ID: <1381761267.3392.49.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381759509-26882-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:41693 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab3JNOea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 10:34:30 -0400
Received: by mail-pa0-f44.google.com with SMTP id lf10so7604936pab.17
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 07:34:29 -0700 (PDT)
In-Reply-To: <1381759509-26882-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-14 at 17:05 +0300, Claudiu Manoil wrote:
> Under certain low traffic conditions, the single core
> devices with multiple Rx/Tx queues (MQ mode) may reach
> soft lockup due to gfar_poll not returning in proper time.
> The following exception was obtained using iperf on a 100Mbit
> half-duplex link, for a p1010 single core device:
> 
> BUG: soft lockup - CPU#0 stuck for 23s! [iperf:2847]
> Modules linked in:
> CPU: 0 PID: 2847 Comm: iperf Not tainted 3.12.0-rc3 #16
> task: e8bf8000 ti: eeb16000 task.ti: ee646000
> NIP: c0255b6c LR: c0367ae8 CTR: c0461c18
> REGS: eeb17e70 TRAP: 0901   Not tainted  (3.12.0-rc3)
> MSR: 00029000 <CE,EE,ME>  CR: 44228428  XER: 20000000
> 
> GPR00: c0367ad4 eeb17f20 e8bf8000 ee01f4b4 00000008 ffffffff ffffffff
> 00000000
> GPR08: 000000c0 00000008 000000ff ffffffc0 000193fe
> NIP [c0255b6c] find_next_bit+0xb8/0xc4
> LR [c0367ae8] gfar_poll+0xc8/0x1d8
> Call Trace:
> [eeb17f20] [c0367ad4] gfar_poll+0xb4/0x1d8 (unreliable)
> [eeb17f70] [c0422100] net_rx_action+0xa4/0x158
> [eeb17fa0] [c003ec6c] __do_softirq+0xcc/0x17c
> [eeb17ff0] [c000c28c] call_do_softirq+0x24/0x3c
> [ee647cc0] [c0004660] do_softirq+0x6c/0x94
> [ee647ce0] [c003eb9c] local_bh_enable+0x9c/0xa0
> [ee647cf0] [c0454fe8] tcp_prequeue_process+0xa4/0xdc
> [ee647d10] [c0457e44] tcp_recvmsg+0x498/0x96c
> [ee647d80] [c047b630] inet_recvmsg+0x40/0x64
> [ee647da0] [c040ca8c] sock_recvmsg+0x90/0xc0
> [ee647e30] [c040edb8] SyS_recvfrom+0x98/0xfc
> 
> To prevent this, the outer while() loop has been removed
> allowing gfar_poll() to return faster even if there's
> still budget left.  Also, there's no need to recompute
> the budget per Rx queue anymore.

It seems there is a race condition, and this patch only makes it happen
less often ?

return faster means what exactly ?
