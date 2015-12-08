From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] ipv6: use a random ifid for headerless devices
Date: Tue, 08 Dec 2015 19:57:08 +0100
Message-ID: <87d1ugzs3f.fsf@nemi.mork.no>
References: <1448884508-5235-1-git-send-email-bjorn@mork.no>
	<1448968942.3320842.454553905.2C5FBADD@webmail.messagingengine.com>
	<87vb8fjpou.fsf@nemi.mork.no>
	<1449225712.287884.457895729.21AD000E@webmail.messagingengine.com>
	<87d1ukk9ce.fsf@nemi.mork.no> <5666DEAD.6010202@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?utf-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34754 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818AbbLHS5Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 13:57:16 -0500
In-Reply-To: <5666DEAD.6010202@stressinduktion.org> (Hannes Frederic Sowa's
	message of "Tue, 8 Dec 2015 14:44:13 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
> On 05.12.2015 20:02, Bj=C3=B8rn Mork wrote:
>> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>>> On Thu, Dec 3, 2015, at 20:29, Bj=C3=B8rn Mork wrote:
>>>
>>>> After looking more at addrconf, I started wondering if we couldn't=
 abuse
>>>> ipv6_generate_stable_address() for this purpose?  We could add a n=
ew
>>>> addr_gen_mode which would trigger automatic generation of a secret=
 if
>>>> stable_secret is uninitialized.  This would be good enough to ensu=
re
>>>> stability until the interface is destroyed.  And it would still al=
low
>>>> the adminstrator to select IN6_ADDR_GEN_MODE_STABLE_PRIVACY by ent=
ering
>>>> a new secret.
>>>
>>> I am fine with your proposal but I would really like to see it only
>>> happen on the per-interface stable_secret instance.
>>=20
>> Do you think something like the patch below will be OK?
>
> I wouldn't call it IN6_ADDR_GEN_MODE_AUTO, this doesn't say anything.
> But the idea is already good.

No, I didn't like that name either.  I just couldn't come up with
anything descriptive, short and non-redundant. "random", "generated",
"stable" are even worse.  And that's about where my imagination ended.
We need a child here :)

>> Or would it be better to drop the additional mode and just generate =
a
>> random secret if the mode is IN6_ADDR_GEN_MODE_STABLE_PRIVACY and th=
e
>> secrets are missing?  Or would that be changing the userspace ABI?  =
This
>> is not clear to me...
>
> I would not like to do that somehow. The problem is that the stable
> secrets get written by user space probably during boot-up, but we don=
't
> know when. That's why I would also not set the ->initialized flag, so
> user can overwrite it to the final secret later on. We block it other=
wise.

I am not sure I follow...  There is nothing preventing userspace from
initializing the secret before or after generation of the random secret=
=2E
Writing to /proc/sys/net/ipv6/conf/<iface>/stable_secret will update th=
e
secret and set the mode to IN6_ADDR_GEN_MODE_STABLE_PRIVACY as before,
even if we have generated a random secret first.  I have verified that
this part works as expected.

I guess we should check &net->ipv6.devconf_dflt->stable_secret too
before choosing the default mode.  IN6_ADDR_GEN_MODE_STABLE_PRIVACY is =
a
more approproate default if a default secret is set.  IMHO, this should
really be the case without the proposed change too, but it isn't. The
current behaviour confuses me: Setting 'default' changes all existing
interfaces, but does not change the default for new interfaces. Is that
right?

> My proposal would be to use the stable privacy generator in case the
> device does not have a device address for EUI-48 generation with a
> secret which we simply generate on the stack. Let's factor out the pa=
rt
> of the generator which depends on the inet6_dev and cnf bits for that=
=2E

Not sure I get this part either.  The point was to have stable addresse=
s
for the lifetime of the netdev.  We can generate the secret on the
stack, but we will still need to stash it somewhere.  That could of
course be to a new field.  But I don't see the point since there is no
way you can combine this mode with IN6_ADDR_GEN_MODE_STABLE_PRIVACY.
Only one mode can be active at, and that mode can then own the secret.

As long as we can manage to introduce this without changing any existin=
g
behaviour, of course.



Bj=C3=B8rn
