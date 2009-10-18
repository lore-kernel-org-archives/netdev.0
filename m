From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH/RFC] make unregister_netdev() delete more than 4 interfaces
 per second
Date: Sun, 18 Oct 2009 19:51:56 +0200
Message-ID: <4ADB55BC.5020107@gmail.com>
References: <20091017221857.GG1925@kvack.org> <4ADA98EE.9040509@gmail.com> <20091018161356.GA23395@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33729 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754724AbZJRRv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 13:51:59 -0400
In-Reply-To: <20091018161356.GA23395@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise a =E9crit :
> On Sun, Oct 18, 2009 at 06:26:22AM +0200, Eric Dumazet wrote:
>> Unfortunatly this slow down fast path by an order of magnitude.
>>
>> atomic_dec() is pretty cheap (and eventually could use a per_cpu thi=
ng,
>> now we have a new and sexy per_cpu allocator), but atomic_dec_and_te=
st()
>> is not that cheap and more important forbids a per_cpu conversion.
>=20
> dev_put() is not a fast path by any means.  atomic_dec_and_test() cos=
ts=20
> the same as atomic_dec() on any modern CPU -- the cost is in the cach=
eline=20
> bouncing and serialisation both require.  The case of the device coun=
t=20
> becoming 0 is quite rare -- any device with a route on it will never =
hit=20
> a reference count of 0.

You forgot af_packet sendmsg() users, and heavy routers where route cac=
he
is stressed or disabled. I know several of them, they even added mmap T=
X=20
support to get better performance. They will be disapointed by your pat=
ch.

atomic_dec_and_test() is definitly more expensive, because of strong ba=
rrier
semantics and added test after the decrement.
refcnt being close to zero or not has not impact, even on 2 years old c=
pus.

Machines hardly had to dismantle a netdevice in a normal lifetime, so m=
aybe
we were lazy with this insane msleep(250). This came from old linux tim=
es,
when cpus were soooo slow and programers soooo lazy :)

The msleep(250) should be tuned first. Then if this is really necessary
to dismantle 100.000 netdevices per second, we might have to think a bi=
t more.

Just try msleep(1 or 2), it should work quite well.
