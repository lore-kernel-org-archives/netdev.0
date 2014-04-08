From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Tue, 08 Apr 2014 10:14:12 -0700
Message-ID: <1396977252.5212.12.camel@joe-AO722>
References: <<20140407075347.GA26461@gondor.apana.org.au>
	 <E1WX4P2-0006wA-9Q@gondolin.me.apana.org.au>
	 <20140408095523.2d4e14bd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0064.hostedemail.com ([216.40.44.64]:35493 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757245AbaDHROS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 13:14:18 -0400
In-Reply-To: <20140408095523.2d4e14bd@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-08 at 09:55 -0700, Stephen Hemminger wrote:
> On Mon, 07 Apr 2014 15:55:36 +0800
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > +static void macvlan_broadcast_enqueue(struct macvlan_port *port,
> > +				      struct sk_buff *skb)
> > +{
> > +	int err = -ENOMEM;
> > +
> > +	skb = skb_clone(skb, GFP_ATOMIC);
> > +	if (unlikely(!skb))
> > +		goto err;
> > +
> > +	spin_lock(&port->bc_queue.lock);
> > +	if (skb_queue_len(&port->bc_queue) < skb->dev->tx_queue_len) {
> > +		__skb_queue_tail(&port->bc_queue, skb);
> > +		err = 0;
> > +	}
> > +	spin_unlock(&port->bc_queue.lock);
> > +
> > +	if (unlikely(err)) {
> > +err:
> > +		atomic_long_inc(&skb->dev->rx_dropped);
> > +		return;
> > +	}
> > +
> 
> unlikely() with goto is redundant and unnecessary.
> 
> IMHO jumping into a block is bad code style
> 
> Why not just move err: to the end as in:
> 
> 
> 	skb = skb_clone(skb, GFP_ATOMIC);
> 	if (unlikely(!skb))
> 		goto err;
> 
> 	spin_lock(&port->bc_queue.lock);
> 	if (skb_queue_len(&port->bc_queue) < skb->dev->tx_queue_len) {
> 		__skb_queue_tail(&port->bc_queue, skb);
> 		err = 0;
> 	}
> 	spin_unlock(&port->bc_queue.lock);
> 
> 	if (err)
> 		goto err;
> 
> 	schedule_work(&port->bc_work);
> 	return;
> err:
> 
> 	atomic_long_inc(&skb->dev->rx_dropped);
> }

Perhaps the spin_unlock should be duplicated instead
and the "int err" removed.

static void macvlan_broadcast_enqueue(struct macvlan_port *port,
				      struct sk_buff *skb)
{
	skb = skb_clone(skb, GFP_ATOMIC);
	if (!skb)
		goto err;

	spin_lock(&port->bc_queue.lock);
	if (skb_queue_len(&port->bc_queue) >= skb->dev->tx_queue_len)
		goto err_unlock;

	__skb_queue_tail(&port->bc_queue, skb);
	spin_unlock(&port->bc_queue.lock);
	schedule_work(&port->bc_work);

	return;

err_unlock:
	spin_unlock(&port->bc_queue.lock);
err:
	atomic_long_inc(&skb->dev->rx_dropped);
}
