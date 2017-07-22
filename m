From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: af_packet: use after free in prb_retire_rx_blk_timer_expired
Date: Sat, 22 Jul 2017 12:02:01 -0700
Message-ID: <CAM_iQpWHfUZGpf6dzT2kJ3fgtAiMeGbuwKYQ5ekGMxEOzm7ihQ@mail.gmail.com>
References: <20170410190350.ngfw435zzr7gpw7e@sasha-lappy> <20170410192309.35x7ddya2cyyv4y6@codemonkey.org.uk>
 <CAF=yD-+MiyTvC=F=ApyF=+bCUgWWDT_4dTxPXsGRziuVTqQSiw@mail.gmail.com> <4F88C5DDA1E80143B232E89585ACE27D018C33F1@DGGEMA502-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Dave Jones <davej@codemonkey.org.uk>,
        "alexander.levin@verizon.com" <alexander.levin@verizon.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>,
        "willemb@google.com" <willemb@google.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "liujian (CE)" <liujian56@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F88C5DDA1E80143B232E89585ACE27D018C33F1@DGGEMA502-MBX.china.huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sat, Jul 22, 2017 at 2:55 AM, liujian (CE) <liujian56@huawei.com> wrote:
> I also hit this issue with trinity test:
>
> The call trace:
>   [exception RIP: prb_retire_rx_blk_timer_expired+70]
>     RIP: ffffffff81633be6  RSP: ffff8801bec03dc0  RFLAGS: 00010246
>     RAX: 0000000000000000  RBX: ffff8801b49d0948  RCX: 0000000000000000
>     RDX: ffff8801b31057a0  RSI: a56b6b6b6b6b6b6b  RDI: ffff8801b49d09ec
>     RBP: ffff8801bec03dd8   R8: 0000000000000001   R9: ffffffff83e1bf80
>     R10: 0000000000000002  R11: 0000000000000005  R12: ffff8801b49d09ec
>     R13: 0000000000000100  R14: ffffffff81633ba0  R15: ffff8801b49d0948
>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
>  #7 [ffff8801bec03de0] call_timer_fn at ffffffff8108cb76
>  #8 [ffff8801bec03e18] run_timer_softirq at ffffffff8108f87c
>  #9 [ffff8801bec03e90] __do_softirq at ffffffff8108629f
> #10 [ffff8801bec03f00] call_softirq at ffffffff8166a01c
> #11 [ffff8801bec03f18] do_softirq at ffffffff810172ad
> #12 [ffff8801bec03f30] irq_exit at ffffffff81086655
> #13 [ffff8801bec03f48] msa_irq_exit at ffffffff810b1ab3
> #14 [ffff8801bec03f88] smp_apic_timer_interrupt at ffffffff8166aeae
> #15 [ffff8801bec03fb0] apic_timer_interrupt at ffffffff816692dd
> --- <IRQ stack> ---
>
> And from vmcore, I can see the pointer GET_CURR_PBLOCK_DESC_FROM_CORE(pkc); is a56b6b6b6b6b6b6b
>

Does the following quick fix help?


diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 008bb34ee324..09ec1640e5f7 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -4264,6 +4264,7 @@ static int packet_set_ring(struct sock *sk,
union tpacket_req_u *req_u,
                        /* Block transmit is not supported yet */
                        if (!tx_ring) {
                                init_prb_bdqc(po, rb, pg_vec, req_u);
+                               pg_vec = NULL;
                        } else {
                                struct tpacket_req3 *req3 = &req_u->req3;
