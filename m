From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] xfrm: increment genid before bumping state genids
Date: Wed, 31 Mar 2010 14:01:03 +0300
Message-ID: <4BB32B6F.7060403@iki.fi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-3-git-send-email-timo.teras@iki.fi> <20100331105023.GA12845@gondor.apana.org.au> <4BB32A11.1030708@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:34234 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756787Ab0CaLBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 07:01:08 -0400
Received: by ewy20 with SMTP id 20so1827363ewy.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 04:01:07 -0700 (PDT)
In-Reply-To: <4BB32A11.1030708@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Herbert Xu wrote:
>> On Wed, Mar 31, 2010 at 01:17:03PM +0300, Timo Teras wrote:
>>> __xfrm_state_bump_genids() is used to update the genid of all
>>> matching xfrm_state's, so any bundle using the state would get
>>> refreshed with the newly inserted state.
>>>
>>> However, since __xfrm_state_bump_genids() is called before the
>>> __xfrm_state_insert() which actually bumps the genid counter,
>>> it is possible that the genid was not updated at all (if there
>>> was no state inserts previously).
>>>
>>> This is fixed by moving the genid incrementation to
>>> __xfrm_state_bump_genids() so the older states are guaranteed
>>> to get different genid.
>>>
>>> Signed-off-by: Timo Teras <timo.teras@iki.fi>
>>
>> It would appear that not all xfrm_state_insert calls are preceded
>> by xfrm_state_bump_genids so this patch isn't correct.
>=20
> Yes, I noticed that there's one. But __xfrm_state_insert() is
> called to replace an acquire in that case. Acquires are never
> used in bundle, so this is good.
>=20
> But maybe it'd be more explicit if the genid increment is done
> before each __xfrm_state_insert()?

Actually. Search for xfrm_state_genid in xfrm_state.c. It's only
used in two places: __xfrm_state_bumb_genid() and _insert().

The only case when it needs to get incremented is in the bump
function. If we are adding a state for the first time, there's
no need to bump the genid as it's per-matching state. The actual
work to invalidate states is done in the bump function, so it's
the only place that needs to increment it.

If any other xfrm_state_insert place needs to invalidate old
states it needs an additional bumping call. So the bumping function
is the right place to increment the genid.
