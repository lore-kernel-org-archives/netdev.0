From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Mon, 15 Dec 2008 15:39:20 -0800 (PST)
Message-ID: <20081215.153920.105386030.davem@davemloft.net>
References: <20081213013420.GA13549@gondor.apana.org.au>
	<E1LBJPd-0003YU-Ap@gondolin.me.apana.org.au>
	<20081215232942.GD6759@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	johnpol@2ka.mipt.ru, bhutchings@solarflare.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54594
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752078AbYLOXjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 18:39:19 -0500
In-Reply-To: <20081215232942.GD6759@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Mon, 15 Dec 2008 15:29:42 -0800

> On Sat, Dec 13, 2008 at 12:35:21PM +1100, Herbert Xu wrote:
> > +static int napi_gro_complete(struct sk_buff *skb)
> > +{
> > +	struct packet_type *ptype;
> > +	__be16 type = skb->protocol;
> > +	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
> > +	int err = -ENOENT;
> > +
> > +	if (!skb_shinfo(skb)->frag_list)
> > +		goto out;
> > +
> > +	rcu_read_lock();
> > +	list_for_each_entry_rcu(ptype, head, list) {
> > +		if (ptype->type != type || ptype->dev || !ptype->gro_complete)
> > +			continue;
> > +
> > +		err = ptype->gro_complete(skb);
> > +		break;
> > +	}
> > +	rcu_read_unlock();
> > +
> > +	if (err) {
> > +		WARN_ON(&ptype->list == head);
> 
> Presumably ptype_base[] is a static array rather than a dynamically
> allocated array that is resized under RCU protection, right?  Otherwise,
> you could get in trouble if the above raced with the resize operation due
> to the fact that you are outside of the RCU read-side critical section.

Yes, and we've been using RCU this way for this table for quite
some time.  From net/core/dev.c:

#define PTYPE_HASH_SIZE	(16)
#define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)

static DEFINE_SPINLOCK(ptype_lock);
static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
static struct list_head ptype_all __read_mostly;	/* Taps */
