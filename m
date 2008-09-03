From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Wed, 03 Sep 2008 09:27:47 +0300
Message-ID: <48BE2E63.8000707@iki.fi>
References: <20080903053935.GA8428@gondor.apana.org.au>	<48BE245D.3060905@iki.fi>	<20080903055041.GA8547@gondor.apana.org.au> <20080902.231420.255718595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:21519 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975AbYICG1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 02:27:43 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1334698eyi.37
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2008 23:27:42 -0700 (PDT)
In-Reply-To: <20080902.231420.255718595.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 3 Sep 2008 15:50:41 +1000
>=20
>> On Wed, Sep 03, 2008 at 08:45:01AM +0300, Timo Ter=E4s wrote:
>>>> ipsec: Move state dump list unlinking into GC
>>>>
>>>> This patch moves the unlinking of x->all (for dumping) into the
>>>> GC and changes the lock to xfrm_cfg_mutex.
>>> Shouldn't this also change the locking in all places where
>>> x->all is used?
>> You're right.  I'd forgotten about the larval states for some
>> reason, probably because I just added them to the list :)
>>
>> So let's keep xfrm_state_lock and just move it.
>=20
> How about we un-crap the reference counting?
>=20
> Every list an object lives on is an external reference, and that is
> the rule that is violated by this ->all list handling.
>=20
> And that's why we need to take a single shared lock twice just to get
> rid of an xfrm_state object now.

Well, it's just another list keeping a reference like ->bydst,
->bysrc and ->byspi. The actual amount of external references is
still correct (the walking code calls _hold() when it returns while
keeping an external pointer).

The difference is that node should not be unlinked from ->all until
all other references are gone. For other lists the unlinking can be
done earlier since they are used only for lookups.

Any good other ways to enumerate to list entries while allowing
to keep a temporary "iterator"? The previous method was crap too.

- Timo
