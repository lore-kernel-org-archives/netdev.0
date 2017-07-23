From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: af_packet: use after free in prb_retire_rx_blk_timer_expired
Date: Sat, 22 Jul 2017 22:59:08 -0700
Message-ID: <CAM_iQpXdyNeeojLfh0ZPMy1LQwOoQZfV7Az2=Q5WALM00Za9SA@mail.gmail.com>
References: <20170410190350.ngfw435zzr7gpw7e@sasha-lappy> <20170410192309.35x7ddya2cyyv4y6@codemonkey.org.uk>
 <CAF=yD-+MiyTvC=F=ApyF=+bCUgWWDT_4dTxPXsGRziuVTqQSiw@mail.gmail.com>
 <4F88C5DDA1E80143B232E89585ACE27D018C33F1@DGGEMA502-MBX.china.huawei.com>
 <CAM_iQpWHfUZGpf6dzT2kJ3fgtAiMeGbuwKYQ5ekGMxEOzm7ihQ@mail.gmail.com> <aa4874ba-3eaf-bf19-ea60-c7b76a972833@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "liujian (CE)" <liujian56@huawei.com>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Dave Jones <davej@codemonkey.org.uk>,
        "alexander.levin@verizon.com" <alexander.levin@verizon.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>,
        "willemb@google.com" <willemb@google.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <aa4874ba-3eaf-bf19-ea60-c7b76a972833@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 22, 2017 at 8:40 PM, Ding Tianhong <dingtianhong@huawei.com> wrote:
> Hi, Cong:
>
> Thanks for your quirk solution, but I still has some doubts about it,
> it looks like fix the problem in the packet_setsockopt->packet_set_ring processing,
> but when in packet_release processing, it may could not release the
> real pg_vec for the TPACKET_V3 ring, and then cause the mem leak,
> maybe I miss something here, nice to hear from your feedback. :)

Yes you miss that packet_release() has memset()'s so we won't hit
that path. :)

However, I missed the swap() in this messy function, actually I
believe the bug is that we modify tpacket_kbdq_core inside rx_ring
in non-closing case without actually stopping its timer. I feel
more confident with the following patch:


diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 008bb34ee324..267b181fef15 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -4263,6 +4263,7 @@ static int packet_set_ring(struct sock *sk,
union tpacket_req_u *req_u,
                case TPACKET_V3:
                        /* Block transmit is not supported yet */
                        if (!tx_ring) {
+                               prb_shutdown_retire_blk_timer(po, rb_queue);
                                init_prb_bdqc(po, rb, pg_vec, req_u);
                        } else {
                                struct tpacket_req3 *req3 = &req_u->req3;
