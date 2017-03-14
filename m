From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Mon, 13 Mar 2017 18:02:11 -0700
Message-ID: <1489453331.28631.102.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170313005848.7076-1-edumazet@google.com>
         <20170313173432.GA31333@ast-mbp.thefacebook.com>
         <CANn89iL_C8CMaxmkSvFxBMCjHx49JkEaKGoUPWMRYucrx09LnA@mail.gmail.com>
         <20170313183121.GA36306@ast-mbp.thefacebook.com>
         <CANn89iK1eyXH_6ViU0sj=yH+3+WVtVdXaAVBUkkcA=0dCvTkOA@mail.gmail.com>
         <20170313202300.GA52396@ast-mbp.thefacebook.com>
         <CANn89iK6+1KMuxv11TqvfNd2cWRPjWDNkFnO00uC15GMQfqs-g@mail.gmail.com>
         <20170313232137.GA77943@ast-mbp.thefacebook.com>
         <CANn89iL3ODh0xf=+P0gSYN-mGwACeeCO+OwtJzK5JEtOtMdPuw@mail.gmail.com>
         <20170313234050.GA82263@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35793 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752082AbdCNBCO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 21:02:14 -0400
Received: by mail-pg0-f66.google.com with SMTP id g2so16146799pge.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 18:02:13 -0700 (PDT)
In-Reply-To: <20170313234050.GA82263@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-13 at 16:40 -0700, Alexei Starovoitov wrote:

> that's not how it works. It's a job of submitter to prove
> that additional code doesn't cause regressions especially
> when there are legitimate concerns.

This test was moved out of the mlx4_en_prepare_rx_desc() section into
the XDP_TX code path.


        if (ring->page_cache.index > 0) {
                /* XDP uses a single page per frame */
                if (!frags->page) {
                        ring->page_cache.index--;
                        frags->page = ring->page_cache.buf[ring->page_cache.index].page;
                        frags->dma  = ring->page_cache.buf[ring->page_cache.index].dma;
                }
                frags->page_offset = XDP_PACKET_HEADROOM;
                rx_desc->data[0].addr = cpu_to_be64(frags->dma +
                                                    XDP_PACKET_HEADROOM);
                return 0;
        }

Can you check again your claim, because I see no additional cost
for XDP_TX.

In fact I removed from the other paths (which are equally important I
believe) a test that had no use, so everybody should be happy.
