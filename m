From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH V1 3/3] net: warn on napi_alloc_skb being called
 in wrong context
Date: Mon, 9 May 2016 09:33:25 -0700
Message-ID: <CAKgT0UcJyxDvY+r6qsXSCQ4SjE2VH4NPGOrG9F7Ame50cQQpKA@mail.gmail.com>
References: <20160509134352.3573.37044.stgit@firesoul>
	<20160509134439.3573.97841.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37916 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbcEIQd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 12:33:28 -0400
Received: by mail-ig0-f177.google.com with SMTP id m9so96355611ige.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 09:33:28 -0700 (PDT)
In-Reply-To: <20160509134439.3573.97841.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 9, 2016 at 6:44 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> It have always been required to call napi_alloc_skb from NAPI/softirq
> context, which implies running with local_bh_disable'ed.  Thus, this
> code path should already be well tested. But recent SKB bulk changes
> introduced will make this more volatile and bugs more subtle, if this
> is violated.

It hasn't been required to be in the softirq routine, bottom halves
could have been disabled.  I used the NAPI parameter to try and
enforce a strong correlation between the two but I didn't make it a
hard requirement.  It isn't until you try to do the recycling that it
becomes more of a requirement because then it is tied into the bulk
free.

The bulk free routine had a stronger requirement for NAPI because it
needed to have the __kfree_skb_flush routine called to finally free
the skbuffs that were still hanging off the percpu skbuff structure.

> To catch any driver violating this add a loud WARN_ON.
>
> Performance wise, I do worry about adding this runtime check code into
> the hotpath, of this highly optimized function call.  I've
> micro-benchmarked it with both IP-forwarding and local UDP delivery,
> and didn't see any regressions.  It does adds extra code size (icache).
>
> add/remove: 0/0 grow/shrink: 1/0 up/down: 43/0 (43)
> function                                     old     new   delta
> __napi_alloc_skb                             461     504     +43
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  net/core/skbuff.c |    3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index e85f1065b263..99addbf66f2e 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -498,6 +498,9 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
>         struct sk_buff *skb;
>         void *data;
>
> +       /* Catch drivers violating, not having local BH disabled */
> +       WARN_ON(!in_softirq());
> +

I'm pretty sure this still lets you get away with just disabling
bottom halves.  I think what you would want is in_serving_softirq().

>         len += NET_SKB_PAD + NET_IP_ALIGN;
>
>         if (unlikely((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
>
