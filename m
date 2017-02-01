From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] loopback: clear pfmemalloc on outgoing skb's
Date: Wed, 01 Feb 2017 15:57:07 -0800
Message-ID: <1485993427.6360.170.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485983078-2372-1-git-send-email-jbacik@fb.com>
         <1485992285.6360.168.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        "David S . Miller" <davem@davemloft.net>
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34526 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750737AbdBAX5J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 18:57:09 -0500
Received: by mail-pf0-f196.google.com with SMTP id y143so9181pfb.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 15:57:09 -0800 (PST)
In-Reply-To: <1485992285.6360.168.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-01 at 15:38 -0800, Eric Dumazet wrote:
> On Wed, 2017-02-01 at 16:04 -0500, Josef Bacik wrote:
> > I was seeing random disconnects while testing NBD over loopback.  This turned
> > out to be because NBD sets pfmemalloc on it's socket, however the receiving side
> > is a user space application so does not have pfmemalloc set on its socket.  This
> > means that sk_filter_trim_cap will simply drop this packet, under the assumption
> > that the other side will simply retransmit.  Well we do retransmit, and then the
> > packet is just dropped again for the same reason.  To keep this from happening
> > simply clear skb->pfmemalloc on transmit so that we don't drop the packet on the
> > receive side.
> > 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> > ---
> >  drivers/net/loopback.c | 7 +++++++
> >  1 file changed, 7 insertions(+)
> > 
> > diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> > index 1e05b7c..13c9126 100644
> > --- a/drivers/net/loopback.c
> > +++ b/drivers/net/loopback.c
> > @@ -81,6 +81,13 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
> >  	 */
> >  	skb_dst_force(skb);
> >  
> > +	/* If our transmitter was a pfmemalloc socket we need to clear
> > +	 * pfmemalloc here, otherwise the receiving socket may not be
> > +	 * pfmemalloc, and if this is a tcp packet then it'll get dropped and
> > +	 * all traffic will halt.
> > +	 */
> > +	skb->pfmemalloc = false;
> > +
> 
> I am not sure this is a proper fix.
> 
> Presumably if the socket was able to store packets in its write queue,
> fact that it sends it to loopback or an Ethernet link should not matter.
> 
> Only in RX path the pfmemalloc thing is really important.
> 
> So I would rather not set skb->pfmemalloc for skbs allocated for the
> write queue, and more exactly the fast clone.
> 
> This would actually speed up the stack a bit.
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 734c71468b013838516cfe8c744dcd0e797a6e2b..f91b81340dc5be80e0c26f9835d9192f35b75ad7 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -271,7 +271,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
>                 atomic_set(&fclones->fclone_ref, 1);
>  
>                 fclones->skb2.fclone = SKB_FCLONE_CLONE;
> -               fclones->skb2.pfmemalloc = pfmemalloc;
> +               fclones->skb2.pfmemalloc = 0;


It turns out this part was not needed in current kernel, because
__copy_skb_header() will copy pfmemalloc, since it is included in the
headers_start/headers_end section of skb.

So this patch is not solving your issue.
