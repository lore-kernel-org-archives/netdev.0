From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: Crashes in xfrm_lookup
Date: Fri, 09 Apr 2010 11:47:12 +0300
Message-ID: <4BBEE990.6080807@iki.fi>
References: <20100409080907.GA2029@gondor.apana.org.au> <4BBEE144.8070600@iki.fi> <20100409082239.GA2194@gondor.apana.org.au> <4BBEE5B9.2060509@iki.fi> <20100409083934.GA2353@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: broonie@opensource.wolfsonmicro.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:56916 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897Ab0DIIrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 04:47:14 -0400
Received: by ewy20 with SMTP id 20so1252314ewy.1
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 01:47:13 -0700 (PDT)
In-Reply-To: <20100409083934.GA2353@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Apr 09, 2010 at 11:30:49AM +0300, Timo Ter=E4s wrote:
>> It has been array all along. The only difference was that only
>> the first element was used if SUB_POLICY was not defined.
>=20
> It was an array but prior to your patch it only had a single
> element when SUB_POLICY is not defined.  Your patch made it
> contain XFRM_POLICY_TYPE_MAX elements unconditionally.

No. Prior it had one element unconditionally. My patch made
it have zero or one element. The non-SUB_POLICY case crashed
because xfrm_pols_put(xxx, 0) unconditionally calls
xfrm_policy_put on unused pointer.

>> I still think xfrm_pols_put should do always what the function
>> name says it's doing.
>>
>> If we want to further optimize non-SUB_POLICY stuff, we should
>> probably make XFRM_POLICY_TYPE_MAX =3D 1 and arrange rest of code
>> so that the compiler can optimize things properly.
>=20
> Anyway, the fact is prior to your patch SUB_POLICY had a minimal
> impact on people who don't like it (like me), and now its effect
> is being forced on everyone.

No. The effect is because the policies are now cached in bundles,
and lookup function should not anymore drop references to policies
which are kept in cache.

>> But the fact is, that in the new code we need to do conditional
>> xfrm_policy_put depending on if we had per-socket or global policy
>> which we matched. Thus we either end up with "if (x)" or the
>> inline functions for loop's implicit test. Or do you have better
>> ideas how to avoid that?
>=20
> Which particular piece of code are you referring to?

__xfrm_lookup(). In the end it uses: "xfrm_pols_put(pols, drop_pols)"
to free up policies that are looked up with xfrm_sk_policy_lookup().
The only major code path there is, if per-socket policy has no
transformations (which is common case, ike daemons do this so they
can talk IKE without transformations).

If we have cached bundle, the policies are referenced to from the
bundle and we do not need to reference, or release them in the
lookup function.

It is a bit icky. But it's the only way to do it, since no one
wanted to cache per-socket bundles in the flow cache.
