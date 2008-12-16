From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Mon, 15 Dec 2008 16:02:01 -0800
Message-ID: <20081216000201.GG6759@linux.vnet.ibm.com>
References: <20081213013420.GA13549@gondor.apana.org.au> <E1LBJPd-0003YU-Ap@gondolin.me.apana.org.au> <20081215232942.GD6759@linux.vnet.ibm.com> <20081215.153920.105386030.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	johnpol@2ka.mipt.ru, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:56497 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753565AbYLPACD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 19:02:03 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBG01HmI025901
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 19:01:17 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBG021Ra172800
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 19:02:01 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBG12BZO013134
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 20:02:11 -0500
Content-Disposition: inline
In-Reply-To: <20081215.153920.105386030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 15, 2008 at 03:39:20PM -0800, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Mon, 15 Dec 2008 15:29:42 -0800
> 
> > On Sat, Dec 13, 2008 at 12:35:21PM +1100, Herbert Xu wrote:
> > > +static int napi_gro_complete(struct sk_buff *skb)
> > > +{
> > > +	struct packet_type *ptype;
> > > +	__be16 type = skb->protocol;
> > > +	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
> > > +	int err = -ENOENT;
> > > +
> > > +	if (!skb_shinfo(skb)->frag_list)
> > > +		goto out;
> > > +
> > > +	rcu_read_lock();
> > > +	list_for_each_entry_rcu(ptype, head, list) {
> > > +		if (ptype->type != type || ptype->dev || !ptype->gro_complete)
> > > +			continue;
> > > +
> > > +		err = ptype->gro_complete(skb);
> > > +		break;
> > > +	}
> > > +	rcu_read_unlock();
> > > +
> > > +	if (err) {
> > > +		WARN_ON(&ptype->list == head);
> > 
> > Presumably ptype_base[] is a static array rather than a dynamically
> > allocated array that is resized under RCU protection, right?  Otherwise,
> > you could get in trouble if the above raced with the resize operation due
> > to the fact that you are outside of the RCU read-side critical section.
> 
> Yes, and we've been using RCU this way for this table for quite
> some time.  From net/core/dev.c:
> 
> #define PTYPE_HASH_SIZE	(16)
> #define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)
> 
> static DEFINE_SPINLOCK(ptype_lock);
> static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
> static struct list_head ptype_all __read_mostly;	/* Taps */

Works for me, then!

							Thanx, Paul
