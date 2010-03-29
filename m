From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 13:36:40 +0300
Message-ID: <4BB082B8.9030400@iki.fi>
References: <1269509091-6440-1-git-send-email-timo.teras@iki.fi> <1269509091-6440-2-git-send-email-timo.teras@iki.fi> <20100325.122611.267401605.davem@davemloft.net> <20100329084018.GA22547@gondor.apana.org.au> <4BB06C36.9060105@iki.fi> <20100329090927.GA22899@gondor.apana.org.au> <4BB07BF6.6000505@iki.fi> <20100329102639.GA23414@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:28745 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754887Ab0C2Kgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 06:36:49 -0400
Received: by ey-out-2122.google.com with SMTP id 9so138372eyd.5
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 03:36:46 -0700 (PDT)
In-Reply-To: <20100329102639.GA23414@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Mar 29, 2010 at 01:07:50PM +0300, Timo Ter=E4s wrote:
>>> For the flow cache we didn't need this because the policy code
>>> would flush the cache synchronously so we can always grab a ref
>>> count safely as long as BH is still off.
>> The old code could return policy object that was killed. It
>=20
> Which is fine.  I'd rather have that than this new behaviour
> which adds a lock.  We don't delete policies all the time, so
> optimising for that case and pessimising the normal case is wrong!
>=20
>> The reason for policy GC calling flush was there for two
>> reasons:
>> - purging the stale entries
>> - making sure that refcount of policy won't go to zero after
>>  releasing flow cache's reference (because the flow cache
>>  did only atomic_dec but did not call destructor)
>>
>> Both issues are handled otherwise in the patch. By refreshing
>> stale entries immediately. Or calling virtual destructor when
>> the object gets deleted. Thus the slow flushing is not needed
>> as often now.
>=20
> Let's step back one second.  It's best to not accumulate unrelated
> changes in one patch.  So is there a reason why you must remove
> the synchronous flow cache flushing from the policy destruction
> path? If not please move that into a different patch.

Yes, I'm splitting up the patch to more fine grained pieces.

The synchronous flow cache flushing does not have to be removed,
but I consider it an improvement.

>> We can still drop the locking, as ->dead can be made atomic_t.
>=20
> No it doesn't need to be atomic, reading an int is always atomic.

The only reason why it needs to be atomic is because of
xfrm_policy_kill() which writes '1' and checks if it was zero
previously. Since the idea is to get rid of the policy lock, we
can turn ->dead flag to atomic_t and use atomic_xchg for that.
Otherwise it would be ok to have it as just regular int.

>> Checking ->dead improves cache's speed to react to policy object
>> changes. And the virtual ->get is especially needed for bundles
>> as they can get stale a lot more often.
>=20
> I really see no point to optimising for such an unlikely case
> but as long as you kill the locks I guess I'm not too bothered.

Agreed. But as the lockless check is cheap, why not to have it.
And some system do get policy changes quite a bit. IKE daemon
sometimes is configured to create policies on-demand so this does
have a real use case.

>> Yeah. Just a note that the road map to RCU policies is trivial
>> and fixes some races in locking currently.
>=20
> Please do one change at a time.  Let's just focus on the original
> issue of the bundle linked list for now.

Yes. The way to do that is just a bit long. I've already added
some other stuff and split existing stuff in the patch. It's
currently seven patches. I'm still tracking one reference leak,
but I'll send in the new set soonish.

- Timo

