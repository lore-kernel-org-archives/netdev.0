From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 3 Jan 2008 18:13:57 -0500
Message-ID: <200801031813.57621.paul.moore@hp.com>
References: <200801031115.34886.paul.moore@hp.com> <200801031620.06603.paul.moore@hp.com> <20080103.150518.05131300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:36642 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263AbYACXOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 18:14:03 -0500
In-Reply-To: <20080103.150518.05131300.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 January 2008 6:05:18 pm David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Thu, 3 Jan 2008 16:20:06 -0500
>
> > On Thursday 03 January 2008 4:13:12 pm Jarek Poplawski wrote:
> > > On Thu, Jan 03, 2008 at 11:15:34AM -0500, Paul Moore wrote:
> > > ...
> > >
> > > > While I'm at it, is there some reason for this #define in
> > > > __skb_clone()?
> > > >
> > > >  #define C(x) n->x = skb->x
> > > >
> > > > ... it seems kinda silly to me and I tend to think the code
> > > > would be better without it.
> > >
> > > IMHO, if there are a lot of this, it's definitely more readable:
> > > easier to check which values are simply copied and which need
> > > something more. But, as usual, it's probably a question of taste,
> > > and of course without it it would definitely look classier...
> >
> > For me personally, I would argue the readability bit.
>
> I definitely think the C() thing is more readable.
>
> Less typing, less reading...

Well, you're the boss :)  I just put the C() macro back in, but I kept 
the reordering that was suggested to help reduce cacheline bounces 
since that still makes sense to me.  The function now looks like this:

static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff 
*skb)
{
#define C(x) n->x = skb->x

	n->next = n->prev = NULL;
	n->sk = NULL;
	__copy_skb_header(n, skb);

	C(len);
	C(data_len);
	C(mac_len);
	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
	n->cloned = 1;
	n->nohdr = 0;
	n->destructor = NULL;
	C(iif);
	C(tail);
	C(end);
	C(head);
	C(data);
	C(truesize);
	atomic_set(&n->users, 1);

	atomic_inc(&(skb_shinfo(skb)->dataref));
	skb->cloned = 1;

	return n;
#undef C
}

-- 
paul moore
linux security @ hp
