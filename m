From: Brian Haley <brian.haley@hp.com>
Subject: Re: IPv6 autoconf/accept_ra default values - revisited
Date: Wed, 17 Feb 2010 11:54:56 -0500
Message-ID: <4B7C1F60.4080701@hp.com>
References: <> <1237945752-14362-1-git-send-email-brian.haley@hp.com> <49C99315.6070504@hp.com> <alpine.LNX.2.00.0903250526050.6682@firda.kolla.no> <49CA4D86.4070403@hp.com> <alpine.LNX.2.01.1001200020280.9283@firda.kolla.no> <4B57359D.8090205@hp.com> <alpine.LNX.2.01.1002162206090.2396@halbrend.uninett.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: =?UTF-8?B?S29sYmrDuHJuIEJhcm1lbg==?= <linux@kolla.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:41959 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab0BQQzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 11:55:00 -0500
In-Reply-To: <alpine.LNX.2.01.1002162206090.2396@halbrend.uninett.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kolla,

Kolbj=C3=B8rn Barmen wrote:
>> For a test, can you turno-off accept_ra/accept_ra_defrtr/accept_ra_p=
info
>=20
> What are they, documented anywhere?

Documentation/networking/ip-sysctl.txt

>> and see if you can get the behavior you want?
>=20
> I must admit that I havent tried using those yet, but still
> I somehow managed to get what I want like this:
>=20
> ~ # cat /etc/modprobe.d/ipv6.conf
> options ipv6 disable_ipv6=3D1 autoconf=3D0
> ~ # cat /etc/sysctl.d/ipv6.conf
> net.ipv6.conf.default.autoconf=3D0
> net.ipv6.conf.default.accept_ra=3D0
> net.ipv6.conf.default.disable_ipv6 =3D 0
> net.ipv6.conf.all.autoconf=3D0
> net.ipv6.conf.all.accept_ra=3D0
> net.ipv6.conf.lo.disable_ipv6=3D0
>=20
> I'm still not convinced it really works, but it looks good so far.

Ok, so when the IPv6 module is loaded, it won't configure any addresses=
=2E
Then you enable IPv6 on future interfaces that are added, and enable it
on lo.  So after this you just have an address on lo and your bridges,
right?

>>> So, could "autoconf" also please turn off accept_ra?
>>> Or, if you like, add another parameter for it :P
>> There are other things in the RA that are useful, like MTU, turning-=
off
>> accept_ra would miss that
>=20
> So what is one supposed to do when one wants fully statically configu=
red
> IPv6 addresses and routes? Or is that not supposed to be possible?

This sequence worked for me on a single interface:

# sysctl net.ipv6.conf.eth0.disable_ipv6=3D1
# sysctl net.ipv6.conf.eth0.accept_ra_defrtr=3D0
# sysctl net.ipv6.conf.eth0.accept_ra_pinfo=3D0
# sysctl net.ipv6.conf.eth0.disable_ipv6=3D0

Interface now has just link-local and you can add addresses and routes
as necessary.

So it looks possible to modify your conf file like this:

net.ipv6.conf.all.accept_ra_defrtr=3D0
net.ipv6.conf.all.accept_ra_pinfo=3D0

>> I think maybe ignoring the prefix info options when autoconf=3D0 mig=
ht be
>> what you want.  I guess we could do another module parameter if we h=
ad
>> to.
>=20
> Yes - all I want is ignore prefix and router announcements, they are =
not
> to be trusted.

By router announcements do you mean you don't want to make the sender t=
he
default router?

>>> And the entire "all" vs. "default" still confuses me.
>>>
>>> * "default" is supposed to cover _all future_ interfaces?
>>> * "all" is supposed to cover _all existing_ interfaces, and change =
them?
>>>   If not, then what is its function?
>> Yes, "default" covers future interfaces, but "all" behavior depends =
on
>> the option - "all->forwarding" and "all->disable_ipv6" will reset
>> interfaces and "all->proxy_ndp" affects all interfaces.  Other than
>> that, the "all" variables seem not to be used.  Making it more like =
the
>> IPv4 code sooner than later might be a good thing, maybe others have
>> thoughts on that?
>=20
> I'd say yes, and the sooner the better.
> (I've noticed the Debian has "Full IPv6 support" in their feature lis=
t for
> next release this summer, it would be nice to have something ready fo=
r that.)

Well, I'll see what I can do...

>>> And lastly - all this would be a non-issue if the defaults values w=
ere so
>>> that all autoconf/accept_ra were 0 - it's _so_ easy to turn on, but
>>> incredibly complicated to turn off. The harder it is to make sense =
out of
>>> things like this, the harder it is to have people start with IPv6.
>> I don't think that default is going to change since it would effecti=
vely
>> disable IPv6 for 99.9% of users, my grandmother would wonder why not=
hing works
>> any more and not know how to fix it :)  In other words, people not d=
oing
>> autoconfiguration are in the minority, and might need to change all =
these
>> default settings, but we should make it easier to use.
>=20
> Right, here it comes, the "most users" argument.
> Sorry, but I just want to rant a little over this ;)
>=20
> Your grandmother will be pretty fed up anyways since some random wifi
> stumbler with 6to4 accidently turned on, jumps on her weakly configur=
ed
> access point, announcing routes so that her computer now routes all
> traffic through the stumblers laptop, which works fine till the stumb=
ler
> vanishes, leaving your grandmother's computer with lots of stalled TC=
P
> sessions and a broken default gateway. Not to mention all the timeout=
s she
> will have to wait for as her computer attempts to contact all the ipv=
6
> addresses it resolves before finally, maybe, trying ipv4 instead.

Yes, I've seen this too when someone configures their laptop to be an
IPv6 router at home, and then comes into the office.  We then track the=
m
down and "educate" them :)  The only solution to this is SeND I believe=
,
and that's not widely deployed at all.

> I have worked with ipv6 in "production" long enough to know that the
> overly optimistic view on how things are supposed to work is one of t=
he
> big obstacles for deployment of IPv6, it's just too fragile...
>=20
> 6to4 accidently activated on a machine on the LAN? Boom!
> Loop between LANs as resault of accident plugging on switch? Boom!
> Multihomed machine accidently forwards between interfaces? Boom!
>=20
> And what do you do when suddenly you have heaploads of machiens with
> nonworking IPv6 configurations? DHCPv6 to the rescue? Or not? :)

DHCPv6 is going to be widely used from what I know, as enterprises
typically use DHCPv4 today, they don't want the end-user to be
administering this stuff at all.

-Brian
