From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/9] mlx4: order-0 allocations and page
 recycling
Date: Wed, 08 Feb 2017 07:52:36 -0800
Message-ID: <1486569156.7793.79.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170207030240.31357-1-edumazet@google.com>
         <3b996d14-0471-1fa3-e686-15cf48db4c19@gmail.com>
         <029a2e2e-eb06-e452-e00e-56dc9c4f3a47@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35299 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932276AbdBHQZd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:25:33 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so11990357pfa.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 08:25:27 -0800 (PST)
In-Reply-To: <029a2e2e-eb06-e452-e00e-56dc9c4f3a47@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-08 at 11:02 +0200, Tariq Toukan wrote:
> 
> On 07/02/2017 5:50 PM, Tariq Toukan wrote:
> > Hi Eric,
> >
> > Thanks for your series.
> >
> > On 07/02/2017 5:02 AM, Eric Dumazet wrote:
> >> As mentioned half a year ago, we better switch mlx4 driver to order-0
> >> allocations and page recycling.
> >>
> >> This reduces vulnerability surface thanks to better skb->truesize 
> >> tracking
> >> and provides better performance in most cases.
> > The series makes significant change in the RX data-path, that requires 
> > deeper checks, in addition to code review.
> > We applied your series and started running both our functional and 
> > performance regression.
> > We will have results by tomorrow morning, and will analyze them during 
> > the day. I'll update about that.
> We hit a kernel panic when running traffic after configuring a large MTU 
> (9000).
> I will take deeper look into this soon and will keep you updated.

Hmm... I saw a typo for XDP, but not for the non XDP path...

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 8f16ec8dfadd0f95646c498c14d53f7266a0..e572e175edfe0f7392b9833b5b3f867fd6db 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -132,7 +132,7 @@ static int mlx4_en_prepare_rx_desc(const struct mlx4_en_priv *priv,
                                        (index << priv->log_rx_info);
 
        if (ring->page_cache.index > 0) {
-               if (frags[0].page) {
+               if (!frags[0].page) {
                        ring->page_cache.index--;
                        frags[0].page = ring->page_cache.buf[ring->page_cache.index].page;
                        frags[0].dma  = ring->page_cache.buf[ring->page_cache.index].dma;
