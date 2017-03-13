From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Mon, 13 Mar 2017 10:50:28 -0700
Message-ID: <CANn89iL_C8CMaxmkSvFxBMCjHx49JkEaKGoUPWMRYucrx09LnA@mail.gmail.com>
References: <20170313005848.7076-1-edumazet@google.com> <20170313173432.GA31333@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:33636 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751934AbdCMRua (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 13:50:30 -0400
Received: by mail-it0-f50.google.com with SMTP id w124so7615606itb.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 10:50:29 -0700 (PDT)
In-Reply-To: <20170313173432.GA31333@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 10:34 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Sun, Mar 12, 2017 at 05:58:47PM -0700, Eric Dumazet wrote:
>> @@ -767,10 +814,30 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>>                       case XDP_PASS:
>>                               break;
>>                       case XDP_TX:
>> +                             /* Make sure we have one page ready to replace this one */
>> +                             npage = NULL;
>> +                             if (!ring->page_cache.index) {
>> +                                     npage = mlx4_alloc_page(priv, ring,
>> +                                                             &ndma, numa_mem_id(),
>> +                                                             GFP_ATOMIC | __GFP_MEMALLOC);
>
> did you test this with xdp2 test ?
> under what conditions it allocates ?
> It looks dangerous from security point of view to do allocations here.
> Can it be exploited by an attacker?
> we use xdp for ddos and lb and this is fast path.
> If 1 out of 100s XDP_TX packets hit this allocation we will have serious
> perf regression.
> In general I dont think it's a good idea to penalize x86 in favor of powerpc.
> Can you #ifdef this new code somehow? so we won't have these concerns on x86?

Normal paths would never hit this point really. I wanted to be extra
safe, because who knows, some guys could be tempted to set
ethtool -G ethX  rx 512 tx 8192

Before this patch, if you were able to push enough frames in TX ring,
you would also eventually be forced to allocate memory, or drop frames...

This patch does not penalize x86, quite the contrary.
It brings a (small) improvement on x86, and a huge improvement on powerpc.

Thanks.
