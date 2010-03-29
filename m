From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 13:07:50 +0300
Message-ID: <4BB07BF6.6000505@iki.fi>
References: <1269509091-6440-1-git-send-email-timo.teras@iki.fi> <1269509091-6440-2-git-send-email-timo.teras@iki.fi> <20100325.122611.267401605.davem@davemloft.net> <20100329084018.GA22547@gondor.apana.org.au> <4BB06C36.9060105@iki.fi> <20100329090927.GA22899@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f222.google.com ([209.85.219.222]:55679 "EHLO
	mail-ew0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754999Ab0C2KH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 06:07:56 -0400
Received: by ewy22 with SMTP id 22so1757746ewy.37
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 03:07:54 -0700 (PDT)
In-Reply-To: <20100329090927.GA22899@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Mar 29, 2010 at 12:00:38PM +0300, Timo Ter=E4s wrote:
>>> Timo, what was the reason for getting rid of the synchronous
>>> flush again?
>> No, just having the flush call is not enough to guarantee
>> liveliness. The flushing happens in delayed work, and the flows
>> might be in use before the flush has been finished or even
>> started.
>>
>> I was also hoping to move the "delayed" deletion part to
>> flow cache core so the code would be shared with policies and
>> bundles.
>>
>> As stated before, we don't really need lock for the 'dead' check.
>> It's only written once, and actually read without lock in some
>> other places too. And all the other places that do take the lock,
>> release it right away making the resulting dead check result
>> "old" anyway.=20
>=20
> No that's not the point.
>=20
> The lock is not there to protect reading ->dead, which is atomic
> anyway.

No it's pretty much for reading ->dead what I can tell. That's
how ->dead is accessed in multiple other places too. That's the
only reason I added the locking in my new code.

But yes, it's pointless. ->dead access is atomic, except where
it's read/written to in xfrm_policy_kill. It's trivially
changeable to atomic_t and I have a patch for this.

> It's there to guarantee that you don't increment the ref count
> on a dead policy.

Previous code did not do any locking before adding a
reference. The lock is not needed for that.

> For the flow cache we didn't need this because the policy code
> would flush the cache synchronously so we can always grab a ref
> count safely as long as BH is still off.

The old code could return policy object that was killed. It
relies solely on the fact that policy gc will flush the flow
cache. Between the time of 'policy killed' and 'policy gc ran'
the old code would return policy object that is marked dead.
The change is an improvement in this regard as the flow cache
objects get refreshed immediately after marking a policy dead.

The reason for policy GC calling flush was there for two
reasons:
- purging the stale entries
- making sure that refcount of policy won't go to zero after
  releasing flow cache's reference (because the flow cache
  did only atomic_dec but did not call destructor)

Both issues are handled otherwise in the patch. By refreshing
stale entries immediately. Or calling virtual destructor when
the object gets deleted. Thus the slow flushing is not needed
as often now.

> So if you leave the flow cache flushing as is, then we should
> still be able to do the it without holding the lock, or checking
> for deadness.

We can still drop the locking, as ->dead can be made atomic_t.

Checking ->dead improves cache's speed to react to policy object
changes. And the virtual ->get is especially needed for bundles
as they can get stale a lot more often.

>> Looks to me that the whole policy locking is not up-to-date
>> anymore. Apparently the only place that actually needs it is
>> the migration code (which just happens to be broke anyway since
>> bundle creation does not take read lock). But it could be
>> relatively easily changed to replace policy with new
>> templates... and the whole policy stuff converted to RCU.
>=20
> I wouldn't be surprised that the migration code is buggy.  But
> that's orthogonal to your patch.

Yeah. Just a note that the road map to RCU policies is trivial
and fixes some races in locking currently.

- Timo

