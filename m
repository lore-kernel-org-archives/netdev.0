From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 0/9] mlx4: order-0 allocations and page recycling
Date: Thu, 9 Feb 2017 14:00:03 +0200
Message-ID: <a536bb6d-3596-188e-bc99-548b02f8eb91@gmail.com>
References: <20170207030240.31357-1-edumazet@google.com>
 <3b996d14-0471-1fa3-e686-15cf48db4c19@gmail.com>
 <029a2e2e-eb06-e452-e00e-56dc9c4f3a47@gmail.com>
 <1486569156.7793.79.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
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
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34477 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751795AbdBIMAM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 07:00:12 -0500
Received: by mail-wr0-f195.google.com with SMTP id 89so11689372wrr.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 04:00:06 -0800 (PST)
In-Reply-To: <1486569156.7793.79.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/02/2017 5:52 PM, Eric Dumazet wrote:
> On Wed, 2017-02-08 at 11:02 +0200, Tariq Toukan wrote:
>> On 07/02/2017 5:50 PM, Tariq Toukan wrote:
>>> Hi Eric,
>>>
>>> Thanks for your series.
>>>
>>> On 07/02/2017 5:02 AM, Eric Dumazet wrote:
>>>> As mentioned half a year ago, we better switch mlx4 driver to order-0
>>>> allocations and page recycling.
>>>>
>>>> This reduces vulnerability surface thanks to better skb->truesize
>>>> tracking
>>>> and provides better performance in most cases.
>>> The series makes significant change in the RX data-path, that requires
>>> deeper checks, in addition to code review.
>>> We applied your series and started running both our functional and
>>> performance regression.
>>> We will have results by tomorrow morning, and will analyze them during
>>> the day. I'll update about that.
>> We hit a kernel panic when running traffic after configuring a large MTU
>> (9000).
>> I will take deeper look into this soon and will keep you updated.
> Hmm... I saw a typo for XDP, but not for the non XDP path...
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 8f16ec8dfadd0f95646c498c14d53f7266a0..e572e175edfe0f7392b9833b5b3f867fd6db 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -132,7 +132,7 @@ static int mlx4_en_prepare_rx_desc(const struct mlx4_en_priv *priv,
>                                          (index << priv->log_rx_info);
>   
>          if (ring->page_cache.index > 0) {
> -               if (frags[0].page) {
> +               if (!frags[0].page) {
>                          ring->page_cache.index--;
>                          frags[0].page = ring->page_cache.buf[ring->page_cache.index].page;
>                          frags[0].dma  = ring->page_cache.buf[ring->page_cache.index].dma;
>
>
Yes.

Here it is:
Large MTU enlarges priv->log_rx_info.

1115         priv->log_rx_info = ROUNDUP_LOG2(i * sizeof(struct 
mlx4_en_rx_alloc));

In the free_frag function, only frag->page is cleared (dma and offset 
are not!), leaving non-zero garbage that is read later as a page field.

   90 static void mlx4_en_free_frag(const struct mlx4_en_priv *priv,
   91                               struct mlx4_en_rx_alloc *frag)
   92 {
   93         if (frag->page) {
   94                 dma_unmap_page(priv->ddev, frag->dma,
   95                                PAGE_SIZE, priv->dma_dir);
   96                 put_page(frag->page);
   97         }

Later, on line 82, we stay with a garbage page pointer.

   74 static int mlx4_en_alloc_frags(const struct mlx4_en_priv *priv,
   75                                struct mlx4_en_rx_desc *rx_desc,
   76                                struct mlx4_en_rx_alloc *frags,
   77                                gfp_t gfp)
   78 {
   79         int i;
   80
   81         for (i = 0; i < priv->num_frags; i++, frags++) {
   82                 if (!frags->page && mlx4_alloc_page(priv, frags, gfp))
   83                         return -ENOMEM;
   84                 rx_desc->data[i].addr = cpu_to_be64(frags->dma +
   85 frags->page_offset);
   86         }
   87         return 0;
   88 }

It can be fixed with this:

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c 
b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 6854a19087ed..d97ee69393f0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -94,8 +94,8 @@ static void mlx4_en_free_frag(const struct 
mlx4_en_priv *priv,
                 dma_unmap_page(priv->ddev, frag->dma,
                                PAGE_SIZE, priv->dma_dir);
                 put_page(frag->page);
-               frag->page = NULL;
         }
+       memset(frag, 0, sizeof(*frag));
  }

  static void mlx4_en_init_rx_desc(const struct mlx4_en_priv *priv,


Regards,
Tariq Toukan.
