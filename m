From: =?UTF-8?Q?Kolbj=C3=B8rn_Barmen?= <linux@kolla.no>
Subject: Re: IPv6 autoconf/accept_ra default values - revisited
Date: Tue, 16 Feb 2010 22:58:13 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1002162206090.2396@halbrend.uninett.no>
References: <> <1237945752-14362-1-git-send-email-brian.haley@hp.com> <49C99315.6070504@hp.com> <alpine.LNX.2.00.0903250526050.6682@firda.kolla.no> <49CA4D86.4070403@hp.com> <alpine.LNX.2.01.1001200020280.9283@firda.kolla.no> <4B57359D.8090205@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Kolbj=C3=B8rn_Barmen?= <linux@kolla.no>,
	Vlad Yasevich <vladislav.yasevich@hp.com>, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ufisa.uninett.no ([158.38.152.126]:54877 "EHLO ufisa.uninett.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933369Ab0BPV7l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 16:59:41 -0500
In-Reply-To: <4B57359D.8090205@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jan 2010, Brian Haley wrote:

> Hi Kolbjorn,

Hello, thanks for answering, and I'm sorry that I havent replied earlie=
r.

> Kolbj=C3=B8rn Barmen wrote:
> > Cheers, remember me? :)
> >=20
> > Regarding the autoconf parameter for the ipv6 module, was it not th=
e
> > intention that it should cover accept_ra as well?
>=20
> It wasn't my intention, but I see how there's a bit of a mess here.
>=20
> > I ask since I have used this paramater in the belief that it also d=
id
> > cover accept_ra, however on a couple of systems that are using brid=
ge
> > interface, I noticed that they "fall off" ipv6-wise, unless I
> > explisitly ping them.
> >=20
> > So I finally got around to find out what was going on, and to my
> > surprise I see that they both have autoconfigured routes on eth0
> > (using link local) that they want to use instead of what I have
> > statically configured for br0.
>=20
> So I re-read RFCs 4861 and 4862 to see what the recommendation was he=
re,
> and found this paragraph which I think explains what the Linux kernel=
 is
> doing:
>=20
> [RFC 4861, Section 6.3.4]
>=20
>       Note: Implementations can choose to process the on-link aspects=
 of
>       the prefixes separately from the stateless address
>       autoconfiguration aspects of the prefixes by, e.g., passing a c=
opy
>       of each valid Router Advertisement message to both an "on-link"
>       and an "addrconf" function.  Each function can then operate
>       independently on the prefixes that have the appropriate flag se=
t.
>=20
> I'm guessing whoever wrote this code followed this suggestion for a
> reason.
>=20
> For a test, can you turno-off accept_ra/accept_ra_defrtr/accept_ra_pi=
nfo

What are they, documented anywhere?

> and see if you can get the behavior you want?

I must admit that I havent tried using those yet, but still
I somehow managed to get what I want like this:

~ # cat /etc/modprobe.d/ipv6.conf
options ipv6 disable_ipv6=3D1 autoconf=3D0
~ # cat /etc/sysctl.d/ipv6.conf
net.ipv6.conf.default.autoconf=3D0
net.ipv6.conf.default.accept_ra=3D0
net.ipv6.conf.default.disable_ipv6 =3D 0
net.ipv6.conf.all.autoconf=3D0
net.ipv6.conf.all.accept_ra=3D0
net.ipv6.conf.lo.disable_ipv6=3D0

I'm still not convinced it really works, but it looks good so far.

> > So, could "autoconf" also please turn off accept_ra?
> > Or, if you like, add another parameter for it :P
>=20
> There are other things in the RA that are useful, like MTU, turning-o=
ff
> accept_ra would miss that

So what is one supposed to do when one wants fully statically configure=
d
IPv6 addresses and routes? Or is that not supposed to be possible?

> I think maybe ignoring the prefix info options when autoconf=3D0 migh=
t be
> what you want.  I guess we could do another module parameter if we ha=
d
> to.

Yes - all I want is ignore prefix and router announcements, they are no=
t
to be trusted.

> > I tried using disable_ipv6 in all kinds of tricky ways to get what =
I want,
> > but it's close to impossble, with interfaces coming and going in th=
e
> > bridge I always end up with autoconfigured addresses where I dont w=
ant
> > them, strange routing issues etc. I cannot just add entries in sysc=
tl.conf
> > for bridge interfaces, since the bridge interfaces (and others for =
that
> > matter) are not there when sysctl is run on bootup.
>=20
> If you set "default.disable_ipv6=3D1" that should be inherited when a=
 new
> interface is configured.

Right.

> > And the entire "all" vs. "default" still confuses me.
> >=20
> > * "default" is supposed to cover _all future_ interfaces?
> > * "all" is supposed to cover _all existing_ interfaces, and change =
them?
> >   If not, then what is its function?
>=20
> Yes, "default" covers future interfaces, but "all" behavior depends o=
n
> the option - "all->forwarding" and "all->disable_ipv6" will reset
> interfaces and "all->proxy_ndp" affects all interfaces.  Other than
> that, the "all" variables seem not to be used.  Making it more like t=
he
> IPv4 code sooner than later might be a good thing, maybe others have
> thoughts on that?

I'd say yes, and the sooner the better.
(I've noticed the Debian has "Full IPv6 support" in their feature list =
for
next release this summer, it would be nice to have something ready for =
that.)

> > And lastly - all this would be a non-issue if the defaults values w=
ere so
> > that all autoconf/accept_ra were 0 - it's _so_ easy to turn on, but
> > incredibly complicated to turn off. The harder it is to make sense =
out of
> > things like this, the harder it is to have people start with IPv6.
>=20
> I don't think that default is going to change since it would effectiv=
ely
> disable IPv6 for 99.9% of users, my grandmother would wonder why noth=
ing works
> any more and not know how to fix it :)  In other words, people not do=
ing
> autoconfiguration are in the minority, and might need to change all t=
hese
> default settings, but we should make it easier to use.

Right, here it comes, the "most users" argument.
Sorry, but I just want to rant a little over this ;)

Your grandmother will be pretty fed up anyways since some random wifi
stumbler with 6to4 accidently turned on, jumps on her weakly configured
access point, announcing routes so that her computer now routes all
traffic through the stumblers laptop, which works fine till the stumble=
r
vanishes, leaving your grandmother's computer with lots of stalled TCP
sessions and a broken default gateway. Not to mention all the timeouts =
she
will have to wait for as her computer attempts to contact all the ipv6
addresses it resolves before finally, maybe, trying ipv4 instead.

I have worked with ipv6 in "production" long enough to know that the
overly optimistic view on how things are supposed to work is one of the
big obstacles for deployment of IPv6, it's just too fragile...

6to4 accidently activated on a machine on the LAN? Boom!
Loop between LANs as resault of accident plugging on switch? Boom!
Multihomed machine accidently forwards between interfaces? Boom!

And what do you do when suddenly you have heaploads of machiens with
nonworking IPv6 configurations? DHCPv6 to the rescue? Or not? :)

Not to mention all the IPv6 related bugs that exist in network gear
like controllers and gateways/bridges (wifi, VPN, whatever).
Ooops, I guess I just did. :)


Cheers!

-- kolla
