From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Wed, 21 Oct 2009 18:09:44 +0200
Message-ID: <4ADF3248.6060304@gmail.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35058 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800AbZJUQJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 12:09:45 -0400
In-Reply-To: <4ADF2B57.4030708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Octavian Purdila a =E9crit :
>> On Sunday 18 October 2009 21:21:44 you wrote:
>>>> The msleep(250) should be tuned first. Then if this is really nece=
ssary
>>>> to dismantle 100.000 netdevices per second, we might have to think=
 a bit
>>>> more.=20
>>>> Just try msleep(1 or 2), it should work quite well.
>>> My goal is tearing down 100,000 interfaces in a few seconds, which =
really
>>>  is  necessary.  Right now we're running about 40,000 interfaces on=
 a not
>>>  yet saturated 10Gbps link.  Going to dual 10Gbps links means pushi=
ng more
>>>  than 100,000 subscriber interfaces, and it looks like a modern dua=
l socket
>>>  system can handle that.
>>>
>> I would also like to see this patch in, we are running into scalabil=
ity issues=20
>> with creating/deleting lots of interfaces as well.
>=20
> Ben patch only address interface deletion, and one part of the proble=
m,
> maybe the more visible one for the current kernel.
>=20
> Adding lots of interfaces only needs several threads to run concurent=
ly.
>=20
> Before applying/examining his patch I suggest identifying all dev_put=
() spots than
> can be deleted and replaced by something more scalable. I began this =
job
> but others can help me.
>=20
> RTNL and rcu grace periods are going to hurt anyway, so you probably =
need
> to use many tasks to be able to delete lots of interfaces in parallel=
=2E
>=20
> netdev_run_todo() should also use a better algorithm to allow paralle=
lism.
>=20
> Following patch doesnt slow down dev_put() users and real scalability
> problems will surface and might be addressed.
>=20

Here are typical timings (on current kernel, but on following example
netdev_wait_allrefs() doesnt wait at all, because my netdevice has no r=
efs)

# time ip link add link eth3 address 00:1E:0B:8F:D0:D6 mv161 type macvl=
an

real    0m0.001s
user    0m0.000s
sys     0m0.001s
# time ip link set mv161 up

real    0m0.001s
user    0m0.000s
sys     0m0.001s
# time ip link set mv161 down

real    0m0.021s
user    0m0.000s
sys     0m0.001s
# time ip link del mv161

real    0m0.022s
user    0m0.000s
sys     0m0.001s

# time ip link add link eth3 address 00:1E:0B:8F:D0:D6 mv161 type macvl=
an

real    0m0.001s
user    0m0.001s
sys     0m0.001s
# time ip link set mv161 up

real    0m0.001s
user    0m0.000s
sys     0m0.001s
# time ip link del mv161

real    0m0.036s
user    0m0.000s
sys     0m0.001s

22 ms (or 36 ms) delay are also problematic if you want to dismantle 1.=
000.000 netdevices at once.
