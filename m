From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Sat, 20 Mar 2010 18:26:00 +0200
Message-ID: <4BA4F718.3020700@iki.fi>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100319072053.GA22913@gondor.apana.org.au> <4BA32C41.2020000@iki.fi> <20100319082909.GA23363@gondor.apana.org.au> <4BA337E6.4010508@iki.fi> <20100319084717.GA23567@gondor.apana.org.au> <4BA33FF5.8010104@iki.fi> <20100319093210.GA23895@gondor.apana.org.au> <4BA349A8.9050105@iki.fi> <20100320151751.GB2950@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:42452 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612Ab0CTQ0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 12:26:03 -0400
Received: by ewy8 with SMTP id 8so272049ewy.28
        for <netdev@vger.kernel.org>; Sat, 20 Mar 2010 09:26:00 -0700 (PDT)
In-Reply-To: <20100320151751.GB2950@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Mar 19, 2010 at 11:53:44AM +0200, Timo Ter=E4s wrote:
>> But now, thinking more, it would probably make more sense to
>> just cache xfrm_dst's and keep ref to the policy on them. So
>> in general I agree with your recommendation. The only immediate
>> problem I can think now is that the resolved would need to
>> atomically check if xfrm_dst is valid, if not, resolve new one.
>> But creating new xfrm_dst involves taking locks and can sleep
>> so it cannot be inside the main resolver.
>=20
> OK this brings out my favourite topic :)
>=20
> The reason we have to sleep is to resolve the template.  So if
> we had queueing for pending xfrm_dst objects, we wouldn't have
> to sleep at all when creating the top-level xfrm_dst.
>=20
> Packets using that xfrm_dst can wait in the queue until it is
> fully resolved.  Now obviously this code doesn't exist so this
> is all just a wet dream.

Right. That sounds useful.

> Setting my favourite topic aside, I have to come to the conclusion
> that your patch still doesn't fully resolve the problem you set out
> to fix.
>=20
> The crux of the issue is the linked list of all bundles in a
> policy and the obvious problems stemming from walking a linked
> list that is unbounded.
>=20
> The reason I think it doesn't fully resolve this is because of
> the flow cache.  Being a per-cpu cache, when you create the xfrm
> dst the first time around, you'll at most put it in one CPU's
> cache.
>=20
> The next CPU that comes along will still have to walk that same
> bundle linked list.  So we're back to square one.

Not exactly, each CPU does one slow lookup after which it
finds it fast. But yes, it's not perfect solution. Especially,
if cpu happens to get switched between the initial lookup and
the update.

> Now Dave, my impression is that we picked the per-cpu design
> because it was the best data structure we had back in 2002,
> right?
>=20
> If so I'd like us to think about the possibility of switching
> over to a different design, in particular, an RCU-based hash
> table, similar to the one I just used for bridge multicasting.
>=20
> This would eliminate the need for walking the bundle list apart
> from the case when we're destroying the policy, which can be
> done in process context.

Right. This would speed the bundle lookup in all cases.

Except... we can have override policy on per-socket basis.
We should include the per-socket override in the flow lookups
so that those sockets get also boost from the cache. Though
usual use case is to disable all policies (so e.g. IKE can
be talked without policies applying).

> Actually I just realised that the other way we can fix this is
> to make xfrm_dst objects per-cpu just like IPv4 routes.  That
> is, when you fail to find an xfrm_dst object in the per-cpu
> cache, you dont' bother calling xfrm_find_bundle but just make
> a new bundle.
>=20
> This is probably much easier than replacing the whole flow cache.
> Can any one think of any problems with duplicate xfrm_dst objects?

Sounds like a very good idea. If we instantiate new xfrm_dst,
all that it shares with others is xfrm_state and xfrm_policy
(inner objects will be unique). Since that's what happens anyway
I don't see any problem with this.

So should go ahead and:
1. modify flow cache to be more generic (have virtual put and get
   for each object; and remove the atomic_t pointer)
2. modify flow cache to have slow and fast resolvers so we can
   copy with the current sleeping requirement
3. cache bundles instead of policies for outgoing stuff
4. kill find_bundle and just instantiate new ones if we get cache
   miss
5. put all bundles to global hlist (since only place that walks
   through them is gc, and stale bundle can be dst_free'd right
   away); use genid's for policy to flush old bundles
6. dst_free and unlink bundle immediately if it's found to be stale

- Timo

