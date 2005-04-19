From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] skbuff: remove old NET_CALLER macro
Date: Tue, 19 Apr 2005 18:04:43 +1000
Message-ID: <E1DNnit-0001Qz-00@gondolin.me.apana.org.au>
References: <20050419174458.0ae804f3@localhost.localdomain>
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org (Stephen Hemminger)
In-Reply-To: <20050419174458.0ae804f3@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:
> --- ck-2.6.11/net/core/skbuff.c 2005-04-19 17:07:13.000000000 +1000
> +++ net-2.6.11/net/core/skbuff.c        2005-04-19 17:31:38.000000000 +1000
> @@ -275,9 +275,10 @@ void kfree_skbmem(struct sk_buff *skb)
> 
> void __kfree_skb(struct sk_buff *skb)
> {
> -       if (skb->list) {
> +       if (unlikely(skb->list)) {
>                printk(KERN_WARNING "Warning: kfree_skb passed an skb still "
> -                      "on a list (from %p).\n", NET_CALLER(skb));
> +                      "on a list (from %p).\n", 
> +                       __builtin_return_address(0));
>                BUG();

Why not turn this if block into a BUG_ON? The return address will be
printed by BUG anyway.
 
> @@ -285,10 +286,11 @@ void __kfree_skb(struct sk_buff *skb)
> #ifdef CONFIG_XFRM
>        secpath_put(skb->sp);
> #endif
> -       if(skb->destructor) {
> +       if (unlikely(skb->destructor)) {

Are you sure that this is the less common case?

>                if (in_irq())
>                        printk(KERN_WARNING "Warning: kfree_skb on "
> -                                           "hard IRQ %p\n", NET_CALLER(skb));
> +                                           "hard IRQ %p\n",
> +                       __builtin_return_address(0));

Similarly, This can be turned into a WARN_ON.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
