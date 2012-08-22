From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to
 stalled CPU task )
Date: Wed, 22 Aug 2012 15:05:57 +0200
Message-ID: <1345640757.5158.1321.camel@edumazet-glaptop>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
	 <1345634026.5158.1084.camel@edumazet-glaptop>
	 <CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63657 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932427Ab2HVNGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 09:06:02 -0400
Received: by bkwj10 with SMTP id j10so308212bkw.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 06:06:01 -0700 (PDT)
In-Reply-To: <CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 14:17 +0200, Sylvain Munaut wrote:
> Hi,
> 
> > Could be the infamous slave_dev_queue_mapping striking again.
> >
> > Could you please try :
> >
> > diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> > index 346b1eb..df731a0 100644
> > --- a/net/core/netpoll.c
> > +++ b/net/core/netpoll.c
> > @@ -335,8 +335,11 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
> >         /* don't get messages out of order, and no recursion */
> >         if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
> >                 struct netdev_queue *txq;
> > +               int queue_index = skb_get_queue_mapping(skb);
> >
> > -               txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> > +               if (queue_index >= dev->real_num_tx_queues)
> > +                       queue_index = 0;
> > +               txq = netdev_get_tx_queue(dev, queue_index);
> >
> >                 /* try until next clock tick */
> >                 for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
> 
> 
> Well, it doesn't solve the problem :(
> 
> It does have an effect though. Now even on the machine with the
> broadcom card, it just freeze the machine ...
> On the machine with intel card, it actually does get a couple of
> netconsole packet out and then freeze as well.
> 

my patch was incomplete, sorry :

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 346b1eb..ddc453b 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -335,8 +335,13 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 	/* don't get messages out of order, and no recursion */
 	if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
 		struct netdev_queue *txq;
+		int queue_index = skb_get_queue_mapping(skb);
 
-		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+		if (queue_index >= dev->real_num_tx_queues) {
+			queue_index = 0;
+			skb_set_queue_mapping(skb, 0);
+		}
+		txq = netdev_get_tx_queue(dev, queue_index);
 
 		/* try until next clock tick */
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
