From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: TI CPSW Ethernet Tx performance regression
Date: Tue, 4 Feb 2014 00:04:07 +0530
Message-ID: <52EFE11F.5040605@ti.com>
References: <1389790129-5721-1-git-send-email-mugunthanvnm@ti.com> <1389808467.11912.9.camel@bwh-desktop.uk.level5networks.com> <CAGVrzca+jeetqMbQ8NvVgddrjEuay+GWZjZadekV2-AiE4OLyw@mail.gmail.com> <52D77716.1020205@ti.com> <CAGVrzcbdDAAfFXjYc-ksxqxeJWeY_Jyh1DbwFiOW=p7WqRvzFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:34725 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753237AbaBCSeP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Feb 2014 13:34:15 -0500
In-Reply-To: <CAGVrzcbdDAAfFXjYc-ksxqxeJWeY_Jyh1DbwFiOW=p7WqRvzFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Friday 17 January 2014 05:05 AM, Florian Fainelli wrote:
> Whenever I had bad TX performance with hardware, the culprit was that
> transmit buffers were not freed quickly enough so the transmit
> scheduler cannot push as many packets as expected. When this happens,
> the root cause for me was bad TX interrupt which messed up the TX flow
> control, but there are plenty other stuff that can go wrong.
>
> You could try to check a few things like TX interrupt rate for the
> same workload on both kernels, dump the queue usage every few seconds
> etc...

I did a further analysis using oprofile and found some more info. In
v3.2 kernel most of the time is spend in csum_partial_copy_from_user and
cpdma_chan_submit which are in the path of tx but the dump in v3.12 cpu
is held more in __do_softirq and __irq_put_desc_unlock. I think because
of this Tx performance is affected. Since __do_softirq is used to invode
NAPI, how to reduce its priority or is there any other code that I
should be looking into?

Pasting the O-Profile dump with iperf running in v3.2 and v3.12 kernel

v3.2:
====
samples  %        app name                 symbol name
33152     9.3792  vmlinux-3.2              csum_partial_copy_from_user
23960     6.7786  vmlinux-3.2              cpdma_chan_submit
19288     5.4569  vmlinux-3.2              __do_softirq
13425     3.7981  vmlinux-3.2              __irq_put_desc_unlock
11065     3.1305  vmlinux-3.2              tcp_packet
8458      2.3929  vmlinux-3.2              __cpdma_chan_free
8386      2.3725  vmlinux-3.2              cpdma_ctlr_int_ctrl
7316      2.0698  vmlinux-3.2              __cpdma_chan_process
5186      1.4672  vmlinux-3.2              tcp_transmit_skb
5118      1.4480  vmlinux-3.2              ipt_do_table
4954      1.4016  vmlinux-3.2              kfree
4857      1.3741  vmlinux-3.2              nf_iterate
4797      1.3571  vmlinux-3.2              tcp_ack
4511      1.2762  vmlinux-3.2              __kmalloc
4433      1.2542  vmlinux-3.2              v7_dma_inv_range
4393      1.2428  vmlinux-3.2              nf_conntrack_in
4069      1.1512  vmlinux-3.2              tcp_sendmsg
3607      1.0205  vmlinux-3.2              local_bh_enable
3148      0.8906  vmlinux-3.2              __memzero
3127      0.8847  vmlinux-3.2              csum_partial
2850      0.8063  vmlinux-3.2              __alloc_skb
2825      0.7992  vmlinux-3.2              ip_queue_xmit
2559      0.7240  vmlinux-3.2              tcp_write_xmit
2399      0.6787  vmlinux-3.2              clocksource_read_cycles
2091      0.5916  vmlinux-3.2              dev_hard_start_xmit


v3.12:
=====
samples  %        app name                 symbol name
9040     15.8034  vmlinux                  __do_softirq
6410     11.2057  vmlinux                  __irq_put_desc_unlock
3584      6.2654  vmlinux                  cpdma_chan_submit
3250      5.6815  vmlinux                  csum_partial_copy_from_user
3070      5.3669  vmlinux                  __cpdma_chan_process
2894      5.0592  vmlinux                  resend_irqs
2567      4.4875  vmlinux                  cpdma_ctlr_int_ctrl
2214      3.8704  vmlinux                  mod_timer
1922      3.3600  vmlinux                  lock_acquire
1402      2.4509  vmlinux                  __cpdma_chan_free
1063      1.8583  vmlinux                  local_bh_enable
783       1.3688  vmlinux                  cpdma_check_free_tx_desc
668       1.1678  vmlinux                  lock_is_held
610       1.0664  vmlinux                  __kmalloc_track_caller
584       1.0209  vmlinux                  lock_release
559       0.9772  vmlinux                  kmem_cache_alloc
557       0.9737  vmlinux                  kfree
460       0.8042  vmlinux                  tcp_transmit_skb
429       0.7500  vmlinux                  tcp_ack
418       0.7307  vmlinux                  tcp_sendmsg
378       0.6608  vmlinux                  kmem_cache_free
366       0.6398  vmlinux                  ip_queue_xmit
363       0.6346  vmlinux                  cache_alloc_refill
351       0.6136  vmlinux                  sub_preempt_count
347       0.6066  vmlinux                  napi_complete
335       0.5856  vmlinux                  __alloc_skb
311       0.5437  vmlinux                  ip_finish_output
