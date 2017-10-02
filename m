From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: v4.14-rc2/arm64 kernel BUG at net/core/skbuff.c:2626
Date: Mon, 02 Oct 2017 07:48:28 -0700
Message-ID: <1506955708.8061.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171002104947.GE20737@leverpostej>
         <CANn89i++X2rzsaHkTRayMpCED_exL8WPq12=RwD_hXsZ6cN-wQ@mail.gmail.com>
         <20171002142156.GB21696@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-arm-kernel@lists.infradead.org,
        syzkaller <syzkaller@googlegroups.com>,
        "David S. Miller" <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36181 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdJBOsc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 10:48:32 -0400
In-Reply-To: <20171002142156.GB21696@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-02 at 15:21 +0100, Mark Rutland wrote:
> Hi Eric,
> 
> On Mon, Oct 02, 2017 at 06:36:32AM -0700, Eric Dumazet wrote:
> > On Mon, Oct 2, 2017 at 3:49 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> > > I hit the below splat at net/core/skbuff.c:2626 while fuzzing v4.14-rc2
> > > on arm64 with Syzkaller. This is the BUG_ON(len) at the end of
> > > skb_copy_and_csum_bits().
> 
> > > kernel BUG at net/core/skbuff.c:2626!
> 
> > > [<ffff200009e03214>] skb_copy_and_csum_bits+0x8dc/0xae0 net/core/skbuff.c:2626
> > > [<ffff20000a01d244>] icmp_glue_bits+0xa4/0x2a0 net/ipv4/icmp.c:357
> > > [<ffff200009f3f0d4>] __ip_append_data+0x10e4/0x20a8 net/ipv4/ip_output.c:1018
> > > [<ffff200009f41a88>] ip_append_data.part.3+0xe8/0x1a0 net/ipv4/ip_output.c:1170
> > > [<ffff200009f46e74>] ip_append_data+0xa4/0xb0 net/ipv4/ip_output.c:1173
> > > [<ffff20000a01ccc8>] icmp_push_reply+0x1b8/0x690 net/ipv4/icmp.c:375
> > > [<ffff20000a0211b0>] icmp_send+0x1070/0x1890 net/ipv4/icmp.c:741
> > > [<ffff200009f41d48>] ip_fragment.constprop.4+0x208/0x340 net/ipv4/ip_output.c:552
> > > [<ffff200009f42228>] ip_finish_output+0x3a8/0xab0 net/ipv4/ip_output.c:315
> > > [<ffff200009f468c4>] NF_HOOK_COND include/linux/netfilter.h:238 [inline]
> > > [<ffff200009f468c4>] ip_output+0x284/0x790 net/ipv4/ip_output.c:405
> > > [<ffff200009f43204>] dst_output include/net/dst.h:458 [inline]
> > > [<ffff200009f43204>] ip_local_out+0x9c/0x1b8 net/ipv4/ip_output.c:124
> > > [<ffff200009f445e8>] ip_queue_xmit+0x850/0x18e0 net/ipv4/ip_output.c:504
> > > [<ffff200009fb091c>] tcp_transmit_skb+0x107c/0x3338 net/ipv4/tcp_output.c:1123
> > > [<ffff200009fbbcc4>] __tcp_retransmit_skb+0x614/0x1d18 net/ipv4/tcp_output.c:2847
> > > [<ffff200009fbd840>] tcp_send_loss_probe+0x478/0x7d0 net/ipv4/tcp_output.c:2457
> > > [<ffff200009fc707c>] tcp_write_timer_handler+0x50c/0x7e8 net/ipv4/tcp_timer.c:557
> > > [<ffff200009fc73d0>] tcp_write_timer+0x78/0x170 net/ipv4/tcp_timer.c:579
> > > [<ffff2000082f8980>] call_timer_fn+0x1b8/0x430 kernel/time/timer.c:1281
> > > [<ffff2000082f8dcc>] expire_timers+0x1d4/0x320 kernel/time/timer.c:1320
> > > [<ffff2000082f912c>] __run_timers kernel/time/timer.c:1620 [inline]
> > > [<ffff2000082f912c>] run_timer_softirq+0x214/0x5f0 kernel/time/timer.c:1646
> > > [<ffff2000080826c0>] __do_softirq+0x350/0xc0c kernel/softirq.c:284
> > > [<ffff200008170af4>] do_softirq_own_stack include/linux/interrupt.h:498 [inline]
> > > [<ffff200008170af4>] invoke_softirq kernel/softirq.c:371 [inline]
> > > [<ffff200008170af4>] irq_exit+0x1dc/0x2f8 kernel/softirq.c:405
> > > [<ffff2000082a95bc>] __handle_domain_irq+0xdc/0x230 kernel/irq/irqdesc.c:647
> > > [<ffff2000080820ac>] handle_domain_irq include/linux/irqdesc.h:175 [inline]
> > > [<ffff2000080820ac>] gic_handle_irq+0x6c/0xe0 drivers/irqchip/irq-gic.c:367

Please try the following fool proof patch.

This is what I had in my local tree back in August but could not
conclude on the syzkaller bug I was working on.


diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 681e33998e03b609fdca83a83e0fc62a3fee8c39..e51d777797a927058760a1ab7af00579f7488cb5 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -732,7 +732,8 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		room = 576;
 	room -= sizeof(struct iphdr) + icmp_param.replyopts.opt.opt.optlen;
 	room -= sizeof(struct icmphdr);
-
+	if (room < 0)
+		goto ende;
 	icmp_param.data_len = skb_in->len - icmp_param.offset;
 	if (icmp_param.data_len > room)
 		icmp_param.data_len = room;
