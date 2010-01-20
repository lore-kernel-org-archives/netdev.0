From: Brian Haley <brian.haley@hp.com>
Subject: Re: IPv6 autoconf/accept_ra default values - revisited
Date: Wed, 20 Jan 2010 11:55:57 -0500
Message-ID: <4B57359D.8090205@hp.com>
References: <> <1237945752-14362-1-git-send-email-brian.haley@hp.com> <49C99315.6070504@hp.com> <alpine.LNX.2.00.0903250526050.6682@firda.kolla.no> <49CA4D86.4070403@hp.com> <alpine.LNX.2.01.1001200020280.9283@firda.kolla.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Kolbj=F8rn_Barmen?= <linux@kolla.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:16278 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800Ab0ATQ4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 11:56:01 -0500
In-Reply-To: <alpine.LNX.2.01.1001200020280.9283@firda.kolla.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kolbjorn,

Kolbj=F8rn Barmen wrote:
> Cheers, remember me? :)
>=20
> Regarding the autoconf parameter for the ipv6 module, was it not the
> intention that it should cover accept_ra as well?

It wasn't my intention, but I see how there's a bit of a mess here.

> I ask since I have used this paramater in the belief that it also did
> cover accept_ra, however on a couple of systems that are using bridge
> interface, I noticed that they "fall off" ipv6-wise, unless I explisi=
tly
> ping them.
>=20
> So I finally got around to find out what was going on, and to my surp=
rise
> I see that they both have autoconfigured routes on eth0 (using link l=
ocal)
> that they want to use instead of what I have statically configured fo=
r br0.

So I re-read RFCs 4861 and 4862 to see what the recommendation was here=
, and
found this paragraph which I think explains what the Linux kernel is do=
ing:

[RFC 4861, Section 6.3.4]

      Note: Implementations can choose to process the on-link aspects o=
f
      the prefixes separately from the stateless address
      autoconfiguration aspects of the prefixes by, e.g., passing a cop=
y
      of each valid Router Advertisement message to both an "on-link"
      and an "addrconf" function.  Each function can then operate
      independently on the prefixes that have the appropriate flag set.

I'm guessing whoever wrote this code followed this suggestion for a rea=
son.

=46or a test, can you turn-off accept_ra/accept_ra_defrtr/accept_ra_pin=
fo
and see if you can get the behavior you want?

> So, could "autoconf" also please turn off accept_ra?
> Or, if you like, add another parameter for it :P

There are other things in the RA that are useful, like MTU, turning-off
accept_ra would miss that, I think maybe ignoring the prefix info optio=
ns
when autoconf=3D0 might be what you want.  I guess we could do another
module parameter if we had to.

> I tried using disable_ipv6 in all kinds of tricky ways to get what I =
want,
> but it's close to impossble, with interfaces coming and going in the
> bridge I always end up with autoconfigured addresses where I dont wan=
t
> them, strange routing issues etc. I cannot just add entries in sysctl=
=2Econf
> for bridge interfaces, since the bridge interfaces (and others for th=
at
> matter) are not there when sysctl is run on bootup.

If you set "default.disable_ipv6=3D1" that should be inherited when a n=
ew
interface is configured.

> And the entire "all" vs. "default" still confuses me.
>=20
> * "default" is supposed to cover _all future_ interfaces?
> * "all" is supposed to cover _all existing_ interfaces, and change th=
em?
>   If not, then what is its function?

Yes, "default" covers future interfaces, but "all" behavior depends on
the option - "all->forwarding" and "all->disable_ipv6" will reset inter=
faces
and "all->proxy_ndp" affects all interfaces.  Other than that, the "all=
"
variables seem not to be used.  Making it more like the IPv4 code soone=
r
than later might be a good thing, maybe others have thoughts on that?

> And lastly - all this would be a non-issue if the defaults values wer=
e so
> that all autoconf/accept_ra were 0 - it's _so_ easy to turn on, but
> incredibly complicated to turn off. The harder it is to make sense ou=
t of
> things like this, the harder it is to have people start with IPv6.

I don't think that default is going to change since it would effectivel=
y
disable IPv6 for 99.9% of users, my grandmother would wonder why nothin=
g works
any more and not know how to fix it :)  In other words, people not doin=
g
autoconfiguration are in the minority, and might need to change all the=
se
default settings, but we should make it easier to use.

Hope that helps.

-Brian
