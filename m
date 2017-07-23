From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: af_packet: use after free in prb_retire_rx_blk_timer_expired
Date: Sun, 23 Jul 2017 10:03:32 -0700
Message-ID: <CAM_iQpXJZwFC3gG40UpCvt9GTcJ+ETaCKRvN7A=z7NB2CVtPRA@mail.gmail.com>
References: <20170410190350.ngfw435zzr7gpw7e@sasha-lappy> <20170410192309.35x7ddya2cyyv4y6@codemonkey.org.uk>
 <CAF=yD-+MiyTvC=F=ApyF=+bCUgWWDT_4dTxPXsGRziuVTqQSiw@mail.gmail.com>
 <4F88C5DDA1E80143B232E89585ACE27D018C33F1@DGGEMA502-MBX.china.huawei.com>
 <CAM_iQpWHfUZGpf6dzT2kJ3fgtAiMeGbuwKYQ5ekGMxEOzm7ihQ@mail.gmail.com>
 <aa4874ba-3eaf-bf19-ea60-c7b76a972833@huawei.com> <CAM_iQpXdyNeeojLfh0ZPMy1LQwOoQZfV7Az2=Q5WALM00Za9SA@mail.gmail.com>
 <4F88C5DDA1E80143B232E89585ACE27D018CB6E0@DGGEMA502-MBS.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dingtianhong <dingtianhong@huawei.com>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
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
In-Reply-To: <4F88C5DDA1E80143B232E89585ACE27D018CB6E0@DGGEMA502-MBS.china.huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 23, 2017 at 5:48 AM, liujian (CE) <liujian56@huawei.com> wrote:
> Hi
>
> I find it caused by below steps:
> 1. set tp_version to TPACKET_V3 and req->tp_block_nr to 1
> 2. set tp_block_nr to 0
> Then pg_vec was freed, and we did not delete the timer?

Thanks for testing!

Ah, I overlook the initialization case in my previous patch.

How about the following one? Does it cover all the cases?


diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 008bb34ee324..0615c2a950fa 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -4329,7 +4329,7 @@ static int packet_set_ring(struct sock *sk,
union tpacket_req_u *req_u,
                register_prot_hook(sk);
        }
        spin_unlock(&po->bind_lock);
-       if (closing && (po->tp_version > TPACKET_V2)) {
+       if (pg_vec && (po->tp_version > TPACKET_V2)) {
                /* Because we don't support block-based V3 on tx-ring */
                if (!tx_ring)
                        prb_shutdown_retire_blk_timer(po, rb_queue);
