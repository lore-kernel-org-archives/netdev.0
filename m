From: Christian Grothoff <grothoff@in.tum.de>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity
 protection
Date: Thu, 12 Dec 2013 16:07:17 +0100
Message-ID: <52A9D125.9080701@in.tum.de>
References: <52A75EF8.3010308@in.tum.de>  <20131211.150137.368953964178408437.davem@davemloft.net>  <52A8C8B4.4060109@in.tum.de>  <20131211122637.75b09074@nehalam.linuxnetplumber.net>  <87bo0nulkt.fsf@tassilo.jf.intel.com> <52A8ECF5.3070604@in.tum.de>  <20131212012317.GL21717@two.firstfloor.org>  <52A98DBF.4090702@appelbaum.net> <52A9A17F.6050505@in.tum.de> <1386858864.19078.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="XDVgLui63pB1r5PJnR4qTVro9M5kMHppb"
Cc: Jacob Appelbaum <jacob@appelbaum.net>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, knock@gnunet.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out1.informatik.tu-muenchen.de ([131.159.0.8]:37698 "EHLO
	smtp1.informatik.tu-muenchen.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751867Ab3LLPHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 10:07:22 -0500
In-Reply-To: <1386858864.19078.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XDVgLui63pB1r5PJnR4qTVro9M5kMHppb
Content-Type: multipart/mixed;
 boundary="------------070701060207060505070005"

This is a multi-part message in MIME format.
--------------070701060207060505070005
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/12/2013 03:34 PM, Eric Dumazet wrote:
> On Thu, 2013-12-12 at 12:43 +0100, Christian Grothoff wrote:
>> On 12/12/2013 11:19 AM, Jacob Appelbaum wrote:
>>> I think that generally, I would prefer if the code didn't use MD5 but=

>>> otherwise, I don't see any real risk of adding an exploitable hole. I=
t
>>> seems silly to disable it by default though - ideally, I'd like a sys=
ctl
>>> to ensure that Tor could use this without making the user recompile
>>> their kernel. That is more of a pain than running a userspace helper,=
 I
>>> think.
>>>
>>> All the best,
>>> Jacob
>>
>> Given that the output is truncated to 32 bits and that performance (SY=
N
>> flood) is also a concern, AND that the original TCP SQN generation is
>> also MD5-based (and we want to look the same), what disadvantage do yo=
u
>> see over MD5?  Given the truncation to 32 bits, I don't think a strong=
er
>> hash would do anything for us.
>>
>> As for it being disabled by default, we did this with respect to
>> kernel submission guidelines which we understood said that features
>> should _initially_ always be submitted with disabled-by-default
>> (presumably so that until they have stabilized, nobody is harmed
>> unless they explicitly activate the code).
>>
>> I don't see the point in having a sysctl, as applications have to
>> explicitly request it anyway.
>=20
> Wait a minute.
>=20
> Your implementation looks like another TCP MD5 thing, but with a single=

> secret. Check at git history to discover how many bugs we had to fix.
> Ask yourself how wrong was TCP MD5 being implemented in the kernel.
>=20
> Very soon you'll need to support different secrets. You do not want all=

> clients share a common secret, do you ? How can a server change its
> secret without disrupting clients ?

By doing another setsockopt() on the listen socket, which doesn't affect
existing connections.

> How having a constant initial sequence number can even be valid?

(1) technically, a constant ISN is 'valid', it is just not a good idea
    for various reasons which I suspect we don't need to discuss here.
(2) however, our ISNs are not necessarily constant, as
    (a) clients/servers may change the secret (see above), for example
        SilentKnock suggested using one-time secrets; our implementation
        does not preclude this;
    (b) alternatively, the scheme optionally includes TCP payload in
        what is being hashed; assuming a sane TCP protocol is used
	where the payload is reasonably random, this will result in
	a reasonably random ISN

Still, your concern that ISNs may not be sufficiently random for certain
applications using a global secret and no payload protection is valid.
There is an easy fix if TCP timestamps are available (throw the
timestamp into the MD5 hash operation), but we did not implement this
(yet). However, this might be a good idea.

> What about TCP timestamps being not available at all?

We're currently not using TCP timestamps; if we assumed that they were
always available, we would be able to better address your ISN issue
above, even for applications that use no payload protection and do not
change the secret.  That should be a minor modification to the existing
patch, but I read your point as you not wanting to use timestamps.

> How typical servers can be behind a load balancer?
> Or am I missing something?

I already agreed earlier that setups using a DNAT that changes SQNs for
load balancing won't work with this (and this is now documented on the
website).  Note that the patch requires the server to explicitly enable
this option, so in setups where it fundamentally doesn't work, the
simple answer is to not use it and the patch will do no harm.

Also, I'm not aware of any Tor bridges or GNUnet peers behind a load
balancer. The only SSH servers that are behind a load balancer that I'm
aware of are for HPC systems, and those have stronger protections from
Internet visibility than what Knock would possibly offer.  So the
use-cases I had in mind are not affected by the DNAT limitation.

> With various proposals (like TCP minion), maybe its time to be able to
> implement part of TCP stack in user land (Keep the mux inside the
> kernel, and forward raw incoming packets to user land where all the
> crazy things can be done without kernel patching.)

Sounds much like the GNU Hurd to me, which is a nice design. Still, I'm
not sure this (relatively tiny) patch really warrants moving TCP into
user land.

> To me your idea is very close from TCP fast open. The only difference
> would be for the server to not send its cookie in SYNACK ?

I'm not sure I see the relationship to TCP fast open.

> Sorry, you seem to hurry to get this facility, I do not see how it can
> really save the world. If it does, you definitely should get feedback
> from TCP community at IETF.

I'm already having fun with IETF and pTLDs right now, one war at a time
;-).  I also figured it might be easier to have a reasonable working
reference implementation first and then standardize.  After all, with my
recent draft some people at IETF suggested I should get 1,000,000+ users
first and then ask again.

Happy hacking!

-Christian


--------------070701060207060505070005
Content-Type: application/pgp-keys;
 name="0x48426C7E.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="0x48426C7E.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.15 (GNU/Linux)

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
jucFjcM5vkqacr0BXp6VBJkNFxqnZW8YN+R/dmbk/uOeiETBArXx1osyWVQXFU/R
eLFixDx3dsdiKXPn96c4qUf+dWiFp5EudWS0f74Rxs0EI8X/NHDMvvPMe8Qh/AZR
93F3XZTjtiLYYg0RgaYufUlDCJr1VLh78KLU9GwrhE9LOHac32nJUHxN20Cn/bQn
Q2hyaXN0aWFuIEdyb3Rob2ZmIDxncm90aG9mZkBpbi50dW0uZGU+iGIEExECACIF
AlIxk6cCGwMGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEL9gcItIQmx+vb0A
n1MmoZCJS6g0yt3zYyGfJHsAKq5HAJ44c8HytmeP5dZWXUN2FDTuVmrWaLQrQ2hy
aXN0aWFuIEdyb3Rob2ZmIDxncm90aG9mZkBuZXQuaW4udHVtLmRlPohiBBMRAgAi
BQJSMZPOAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRC/YHCLSEJsfjsc
AJ9Pr+YACJEhAYpA6vuVRvxcow0lFgCgoqN6CY7GF6eGRW/UsoApFOae8Em0JENo
cmlzdGlhbiBHcm90aG9mZiA8Z3JvdGhvZmZAdHVtLmRlPohiBBMRAgAiBQJSMZPg
AhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRC/YHCLSEJsfmpHAKC1yUDl
iBcIb0feo+gKQfWrzHmYYgCeIWQ+4jhr6UddrDR0GbaIewayoc25BA0ERYbybxAQ
AOAcuyco8qdniS2SuCP+Yar9bnu1ZDo2ccawMMLlA7BRTZzml8Uv4cy3XXnEjuSk
5HreFZsb9phJuYpSn7rb4lWs38VSTNy7dDc0Q5pxAI1ViFJP/hANV5LzdGPRqEzH
Ggi/fX41X3eERiWK+nHOfIF1oxfgof2Ef9pEY3/L+pxHKV+c+xqOYzJiIIKbEgQ/
meZwHh6KgG90aVx7diJt9ajOIGAQb9BCu2gjLmbyD0CbOpF05VWp/T20Y3e9Io/W
7JD9aJGXPo0sAhOOf2z2GmY2nx2Yoy+UYLpGEbTjjRHLChD6ioMmw0w4iEDWB9TN
9aW5K1MrVwdo2VLj2knF06HKZIv8ZOahaZe6P7pUApcG2NxHnaWqH91mPdICSUea
mhaB8sZ/ByXOOvQsTH12lXCMPVVdDw49chFHSJrKdY210uO55OobVodx62TvzZTE
Ub06cjtaC3EIf+8G/mde8O5PapGVYHVlUoDbDdR8TEmaBxHjHhPRBFzapWPHxdxz
wb/kN+m1826o+8hZ/yCCDNGvXZHKmXpEv2xgLkYH7j55JUeIc3BFhbjsb4JW1A+K
sNu8sBT/a9JvYzIAdd7uUWtGrOWnB2i+IHNRxGHI3bBgI2ueq6ZR1e4T6m56+sdj
zCMJC930YTNeysGidA9du0HWis5XNI4rZYhP6MsBiUmrAAMGD/sFT/8vmkvorHoX
iKL3Kz/LJWsSEheApwHPq4HpqauMO58CKPKUSm5OwgD7i6ofi62qmORIZ5CVPSC/
CJCWEAGBJo7XZvZb2iDwl+mRdd+XQD3WUL5saamvgrFHWby07YvBO+x9BEWHMSNS
LNzbhptEDI9cI4cccX848CYxLMwHspgQ2MoCxJWAFwOy25Qmg+B8NB6E0jqR9nkE
05uqZAdja/rs+0zmvJ9KxC9I/+fVwnY1w8dSleh6s6ktT1nR5IVX0BtUmj5n5zaX
Djrqf2dnlf1GbibsuXTad95wXHQo6eha+hg2mEJdMbn1kIT1lEkwxLnm27JKgv9F
xCp09KmikC7BT+zqtJY5E9V4n648J3VknnqoXWuM0QGYLsKzSXPHjqBotpy4ZS0Y
bVs9kNp0KgFBPg6N9pxgCPPB8lw85EOnbnfDn+E6tBZkF8Nnv+pVxXxhb9Zhk1GE
VpzQU8HnXBNl7A+i1vvJdnjP4TEr9F0X/F3YB4dS1vX7bhxC6DK1Z18232vbowQl
rIg2vzyH/9uQ+odHntcAA1Hi+txMkaJ5UzYWxyBjIIt6rz2uFnA2/JskhtAYvp2E
ix8LspT8wDhdW4nRBGw75omwHo5rHLNaWymvNGhNKje+DSwNwDC9dSC3p7xkHUPm
VOYQeGsWdeMp1UNRvWeicaQ7HOuJYIhJBBgRAgAJBQJFhvJvAhsMAAoJEL9gcItI
Qmx+zJwAn3MrafB4VpPGwsPWugS1oylK3cfJAJ9bSPkWd91LUq4ARWVVq5jaQopD
GQ=3D=3D
=3Domeg
-----END PGP PUBLIC KEY BLOCK-----

--------------070701060207060505070005--

--XDVgLui63pB1r5PJnR4qTVro9M5kMHppb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlKp0SUACgkQv2Bwi0hCbH5cYgCffIdvuZs5eF0Wxw+uKcwlGp2e
ZFsAnjFGYKXNrohLAJKP49uIAKM/qRFh
=voSg
-----END PGP SIGNATURE-----

--XDVgLui63pB1r5PJnR4qTVro9M5kMHppb--
