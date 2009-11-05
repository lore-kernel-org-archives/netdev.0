From: Jon Loeliger <jdl@jdl.com>
Subject: Re: [PATCH RFC] gianfar: Make polling safe with IRQs disabled
Date: Thu, 05 Nov 2009 09:43:18 -0600
Message-ID: <E1N64UY-00049g-Hb@jdl.com>
References: <20091104225711.GA30844@oksana.dev.rtsoft.ru> <E1N62ti-0003iS-K2@jdl.com> <20091105142028.GB17171@oksana.dev.rtsoft.ru> <E1N63WM-0003xK-PN@jdl.com>
Cc: linuxppc-dev@ozlabs.org, Jason Wessel <jason.wessel@windriver.com>,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from jdl.com ([208.123.74.7]:49600 "EHLO jdl.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755991AbZKEPna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 10:43:30 -0500
In-reply-to: <E1N63WM-0003xK-PN@jdl.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > 
> > If it's easily reproducible, could you replace the printk() with
> > WARN_ON(1) and post the backtrace? Or I can try to reproduce the
> > issue if you tell me how.
> > 
> > Thanks!
> 
> Yeah, I can reproduce it.  I'll try and get that for you.
> 
> jdl

This is with essentially a stock 2.6.31 kernel for an 8315.
I've seen the problem for both task 'insmod' and 'iptables'.
Um, conn_track is a module being loaded here.  Our brief analysis
runs like this:

    This is an issue with the gianfar driver.  In gfar_poll(), irqs are
    disabled for the handling of gfar_clean_tx_ring(dev) (line 1928).
    In this call, skbs can call skb_recycle_check, which can release
    head state (net/core/skbuff.c@506), which can cause conntrack
    cleanup (net/core/skbuff.c@402->include/linux/skbuff.h@1923), which
    cannot be done with IRQs disabled...that is the badness.

HTH,
jdl


[   34.775619] nf_conntrack version 0.5.0 (1008 buckets, 4032 max)
[   34.963135] ------------[ cut here ]------------
[   34.967804] Badness at kernel/softirq.c:143
[   34.972016] NIP: c003e3c4 LR: c423a528 CTR: c003e344
[   34.977018] REGS: c15d1ab0 TRAP: 0700   Not tainted  (2.6.31-xeno)
[   34.983236] MSR: 00021032 <ME,CE,IR,DR>  CR: 24000284  XER: 20000000
[   34.989689] TASK = c343a060[977] 'insmod' THREAD: c15d0000
[   34.995032] GPR00: 00000001 c15d1b60 c343a060 00000001 000000a4 00000052 00000001 00000000 
[   35.003501] GPR08: 00000101 c0450000 c3572d20 c003e344 24000282 100c5288 00000001 00000040 
[   35.011971] GPR16: c2e5c2f0 00009032 c2e5c2c0 c2e5c000 00000100 00000000 c2e5c340 00000098 
[   35.020440] GPR24: 00000260 c2428760 00000800 c153b800 00000000 c1018c98 c15d0000 c15d1b60 
[   35.029120] NIP [c003e3c4] local_bh_enable+0x80/0xc4
[   35.034174] LR [c423a528] destroy_conntrack+0xd4/0x13c [nf_conntrack]
[   35.040652] Call Trace:
[   35.043128] [c15d1b60] [c003e32c] local_bh_disable+0x1c/0x34 (unreliable)
[   35.050001] [c15d1b70] [c423a528] destroy_conntrack+0xd4/0x13c [nf_conntrack]
[   35.057205] [c15d1b80] [c02c6370] nf_conntrack_destroy+0x3c/0x70
[   35.063263] --- Exception: c428168c at 0xc15d1c50
[   35.063272]     LR = 0xc15d1c40
[   35.071165] [c15d1ba0] [c0286f3c] skb_release_head_state+0x100/0x104 (unreliable)
[   35.078718] [c15d1bb0] [c0288340] skb_recycle_check+0x8c/0x10c
[   35.084611] [c15d1bc0] [c01e1688] gfar_poll+0x190/0x384
[   35.089887] [c15d1c10] [c02935ac] net_rx_action+0xec/0x22c
[   35.095432] [c15d1c50] [c003dd8c] __do_softirq+0xe8/0x224
[   35.100885] [c15d1ca0] [c000624c] do_softirq+0x78/0x80
[   35.106071] [c15d1cb0] [c003d868] irq_exit+0x60/0x78
[   35.111082] [c15d1cc0] [c0006714] do_IRQ+0x98/0xb0
[   35.115921] [c15d1ce0] [c0014af8] ret_from_except+0x0/0x14
[   35.121474] --- Exception: 501 at strcmp+0xc/0x24
[   35.121483]     LR = find_symbol_in_section+0x38/0xc0
[   35.131285] [c15d1da0] [00000000] (null) (unreliable)
[   35.136390] [c15d1dc0] [c0064e08] each_symbol_in_section+0x7c/0xb4
[   35.142623] [c15d1df0] [c0065340] each_symbol+0x34/0x148
[   35.147983] [c15d1e70] [c0065488] find_symbol+0x34/0x78
[   35.153257] [c15d1ea0] [c00681d8] load_module+0x8e4/0x12ec
[   35.158792] [c15d1f20] [c0068c60] sys_init_module+0x80/0x208
[   35.164501] [c15d1f40] [c0014460] ret_from_syscall+0x0/0x38
[   35.170124] --- Exception: c01 at 0xfea6a8c
[   35.170132]     LR = 0x10016dcc
[   35.177485] Instruction dump:
[   35.180477] 70090004 40820068 81610000 800b0004 bbcbfff8 7d615b78 7c0803a6 4e800020 
[   35.188332] 3d20c045 8009b3c0 7c000034 5400d97e <0f000000> 2f800000 419effa8 38000001 
