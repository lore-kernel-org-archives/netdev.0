From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Wed, 17 Mar 2010 17:56:38 +0200
Message-ID: <4BA0FBB6.10208@iki.fi>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100317130704.GA2601@gondor.apana.org.au> <4BA0E435.6090801@iki.fi> <20100317145850.GA4257@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:15180 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711Ab0CQP4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 11:56:54 -0400
Received: by ey-out-2122.google.com with SMTP id d26so87072eyd.19
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 08:56:53 -0700 (PDT)
In-Reply-To: <20100317145850.GA4257@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Mar 17, 2010 at 04:16:21PM +0200, Timo Ter=E4s wrote:
>> The problem is if I have multipoint gre1 and policy that says
>> "encrypt all gre in transport mode".
>>
>> Thus for each public address, I get one bundle. But the
>> xfrm_lookup() is called for each packet because ipgre_tunnel_xmit()
>> calls ip_route_output_key() on per-packet basis.
>>
>> For my use-case it makes a huge difference.
>=20
> But if your traffic switches between those tunnels on each packet,
> we're back to square one, right?

Not to my understanding. Why would it change?

>> Then we cannot maintain policy use time. But if it's not a
>> requirement, we could drop the policy from cache.
>=20
> I don't see why we can't maintain the policy use time if we did
> this, all you need is a back-pointer from the top xfrm_dst.

Sure.

>> Also. With this and your recent flowi patch, I'm seeing pmtu
>> issues. Seems like xfrm_bundle_ok uses the original dst which
>> resulted in the creation of the bundle. Somehow that dst
>> does not get updated with pmtu... but the new dst used in
>> next xfrm_lookup for same target does have proper mtu.
>> I'm debugging right now why this is happening. Any ideas?
>=20
> The dynamic MTU is always maintained in a normal dst object in
> the IPv4 routing cache.  Each xfrm_dst points to such a dst
> through xdst->route.
>=20
> If you were looking at the xfrm_dst's own MTU then that may well
> cause problems.

I figured the root cause. The original dst gets expired
rt_genid goes old. But xfrm_dst does not notice that so it
won't create a new bundle. xfrm_bundle_ok calls dst_check,
but dst->obsolete =3D 0, and ipv4_dst_check is a no-op anyway.

Somehow the rtable object should be able to tell back to
xfrm that the dst is not good anymore. Any ideas?

- Timo


