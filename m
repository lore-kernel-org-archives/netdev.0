From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net] tuntap: properly align skb->head before building skb
Date: Thu, 26 Oct 2017 07:11:41 -0700
Message-ID: <CANn89iKoQ2rFryuuXeo11DkSRvZPQvhiWhLJvthAnXU2R=gcKA@mail.gmail.com>
References: <1509020155-3830-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Wei Wei <dotweiba@gmail.com>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Mark Rutland <mark.rutland@arm.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509020155-3830-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 26, 2017 at 5:15 AM, Jason Wang <jasowang@redhat.com> wrote:
> An unaligned alloc_frag->offset caused by previous allocation will
> result an unaligned skb->head. This will lead unaligned
> skb_shared_info and then unaligned dataref which requires to be
> aligned for accessing on some architecture. Fix this by aligning
> alloc_frag->offset before the frag refilling.
>
> Fixes: 0bbd7dad34f8 ("tun: make tun_build_skb() thread safe")
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Cc: Wei Wei <dotweiba@gmail.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Reported-by: Wei Wei <dotweiba@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> - The patch is needed for -stable.
> - Wei, can you try this patch to see if it solves your issue?
> ---
>  drivers/net/tun.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index b9973fb..60e44f2 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1286,6 +1286,7 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
>         buflen += SKB_DATA_ALIGN(len + pad);
>         rcu_read_unlock();
>
> +       alloc_frag->offset = ALIGN((u64)alloc_frag->offset, TUN_RX_PAD);

You have to align to one cache line (SMP_CACHE_BYTES), or SKB_DATA_ALIGN(1)

Then eventually use skb_reserve() for NET_IP_ALIGN, but I guess it is
already done.
