From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] NET: Proper handling of IPv6 header in tun driver when
 TUN_NO_PI is set
Date: Fri, 6 Jun 2008 13:48:33 -0700
Message-ID: <20080606134833.3a5a8dc2@extreme>
References: <4849162D.7000401@nav6.org>
	<48499C32.6070703@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ang Way Chuang <wcang@nav6.org>,
	David Miller <davem@davemloft.net>,
	"Zabele, Stephen (US SSA)" <steve.zabele@baesystems.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Max Krasnyanskiy <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35647 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755101AbYFFUsi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2008 16:48:38 -0400
In-Reply-To: <48499C32.6070703@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 06 Jun 2008 13:21:06 -0700
Max Krasnyanskiy <maxk@qualcomm.com> wrote:

> Acked-by: Max Krasnyansky <maxk@qualcomm.com>
> 
> Dave, can you please add this patch to your tree.
> 
> --
> Steve, this is what I meant by "we do not need extra copy_from_user". We 
> already do copy into the SKB and can parse the header right there.
> 
> Max
> 
> 
> 
> 
> Ang Way Chuang wrote:
> > By default, tun.c running in TUN_TUN_DEV mode will set the protocol of 
> > packet to IPv4 if TUN_NO_PI is set. My program failed to work when I 
> > assumed that the driver will check the first nibble of packet, determine 
> > IP version and set the appropriate protocol.
> > 
> > The test for this change was conducted on 2.6.24.7 kernel. But the diff 
> > is produced using git commit
> > c3b25b32e8bef526cca748e1ba023c6bdd705a99. I couldn't test it on kernel 
> > version greater than 2.6.25 due to out of tree driver failing to 
> > compile. But tun_get_user doesn't change that much between 2.6.24 and 
> > 2.6.26, so it should work, I hope :-D. This patch is trivial because 
> > this problem can also be fixed by not using TUN_NO_PI.
> > 
> > Signed-off-by: Ang Way Chuang <wcang@nav6.org>
> > ---
> > 
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index 0ce07a3..77964bc 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -313,6 +313,21 @@ static __inline__ ssize_t tun_get_user(struct 
> > tun_struct *tun, struct iovec *iv,
> > 
> >         switch (tun->flags & TUN_TYPE_MASK) {
> >         case TUN_TUN_DEV:
> > +               if (tun->flags & TUN_NO_PI) {
> > +                       switch (skb->data[0] & 0xf0) {

Why the magic constants, instead of proper casts and defines.
> > +                       case 0x40:
> > +                               pi.proto = __constant_htons(ETH_P_IP);

Use htons() instead of __constant_htons() it is easier to read,
and the compiler already does the right thing.

> > +                               break;
> > +                       case 0x60:
> > +                               pi.proto = __constant_htons(ETH_P_IPV6);
> > +                               break;
> > +                       default:
> > +                               tun->dev->stats.rx_dropped++;
> > +                               kfree_skb(skb);
> > +                               return -EINVAL;
> > +                       }
> > +               }
> > +
> >                 skb_reset_mac_header(skb);
> >                 skb->protocol = pi.proto;
> >                 skb->dev = tun->dev;
> > 
> > -- 
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
