From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] ipv6: use a random ifid for headerless devices
Date: Mon, 14 Dec 2015 22:30:44 +0100
Message-ID: <566F3504.6050908@stressinduktion.org>
References: <1448884508-5235-1-git-send-email-bjorn@mork.no>
 <1448968942.3320842.454553905.2C5FBADD@webmail.messagingengine.com>
 <87vb8fjpou.fsf@nemi.mork.no>
 <1449225712.287884.457895729.21AD000E@webmail.messagingengine.com>
 <87d1ukk9ce.fsf@nemi.mork.no> <5666DEAD.6010202@stressinduktion.org>
 <87d1ugzs3f.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:41404 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932339AbbLNVas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 16:30:48 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 744ED20BB6
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 16:30:47 -0500 (EST)
In-Reply-To: <87d1ugzs3f.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 08.12.2015 19:57, Bj=C3=B8rn Mork wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>> On 05.12.2015 20:02, Bj=C3=B8rn Mork wrote:
>>> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>>>> On Thu, Dec 3, 2015, at 20:29, Bj=C3=B8rn Mork wrote:
>>>>
>>>>> After looking more at addrconf, I started wondering if we couldn'=
t abuse
>>>>> ipv6_generate_stable_address() for this purpose?  We could add a =
new
>>>>> addr_gen_mode which would trigger automatic generation of a secre=
t if
>>>>> stable_secret is uninitialized.  This would be good enough to ens=
ure
>>>>> stability until the interface is destroyed.  And it would still a=
llow
>>>>> the adminstrator to select IN6_ADDR_GEN_MODE_STABLE_PRIVACY by en=
tering
>>>>> a new secret.
>>>>
>>>> I am fine with your proposal but I would really like to see it onl=
y
>>>> happen on the per-interface stable_secret instance.
>>>
>>> Do you think something like the patch below will be OK?
>>
>> I wouldn't call it IN6_ADDR_GEN_MODE_AUTO, this doesn't say anything=
=2E
>> But the idea is already good.
>=20
> No, I didn't like that name either.  I just couldn't come up with
> anything descriptive, short and non-redundant. "random", "generated",
> "stable" are even worse.  And that's about where my imagination ended=
=2E
> We need a child here :)

Sorry for answering so late...

What do you think about simply using IN6_ADDR_GEN_MODE_RANDOM?

>>> Or would it be better to drop the additional mode and just generate=
 a
>>> random secret if the mode is IN6_ADDR_GEN_MODE_STABLE_PRIVACY and t=
he
>>> secrets are missing?  Or would that be changing the userspace ABI? =
 This
>>> is not clear to me...
>>
>> I would not like to do that somehow. The problem is that the stable
>> secrets get written by user space probably during boot-up, but we do=
n't
>> know when. That's why I would also not set the ->initialized flag, s=
o
>> user can overwrite it to the final secret later on. We block it othe=
rwise.
>=20
> I am not sure I follow...  There is nothing preventing userspace from
> initializing the secret before or after generation of the random secr=
et.

I actually missed that. Shortly before sending the patch I decided to
allow to reinitialize the stable_secret. Before I had a check in there
to not being able to rewrite the stable_secret after it became
initialized. So we are good here. Sorry for the confusion.

> Writing to /proc/sys/net/ipv6/conf/<iface>/stable_secret will update =
the
> secret and set the mode to IN6_ADDR_GEN_MODE_STABLE_PRIVACY as before=
,
> even if we have generated a random secret first.  I have verified tha=
t
> this part works as expected.

Thanks!

> I guess we should check &net->ipv6.devconf_dflt->stable_secret too
> before choosing the default mode.  IN6_ADDR_GEN_MODE_STABLE_PRIVACY i=
s a
> more approproate default if a default secret is set.  IMHO, this shou=
ld
> really be the case without the proposed change too, but it isn't. The
> current behaviour confuses me: Setting 'default' changes all existing
> interfaces, but does not change the default for new interfaces. Is th=
at
> right?

Nope, that is a good point. I think we should do that unconditionally.
If we have a stable secret set, which we can use, we always should use
this address generation mode. Can you send the addition of this as a
separate patch so we can propose it for stable? Otherwise I can do that=
,
too.

>> My proposal would be to use the stable privacy generator in case the
>> device does not have a device address for EUI-48 generation with a
>> secret which we simply generate on the stack. Let's factor out the p=
art
>> of the generator which depends on the inet6_dev and cnf bits for tha=
t.
>=20
> Not sure I get this part either.  The point was to have stable addres=
ses
> for the lifetime of the netdev.  We can generate the secret on the
> stack, but we will still need to stash it somewhere.  That could of
> course be to a new field.  But I don't see the point since there is n=
o
> way you can combine this mode with IN6_ADDR_GEN_MODE_STABLE_PRIVACY.
> Only one mode can be active at, and that mode can then own the secret=
=2E

Ok, your argument makes sense.

> As long as we can manage to introduce this without changing any exist=
ing
> behaviour, of course.

Besides the naming I think your patch looks fine.

Thank you,
Hannes
