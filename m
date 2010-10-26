From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 10:09:51 -0700
Message-ID: <AANLkTinGKJgYM6mzVvR00KANh869z1T_2CD1Vv57Xrqx@mail.gmail.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
 <20101025213841.635b9a15@nehalam> <AANLkTinGpt=EQX3aXRaj5mEUMDNpyEapbs4VyOwgtN55@mail.gmail.com>
 <4CC708CE.4040404@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:49775 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932360Ab0JZRKP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:10:15 -0400
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o9QHAE8B016240
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:10:14 -0700
Received: from yxj4 (yxj4.prod.google.com [10.190.3.68])
	by kpbe15.cbf.corp.google.com with ESMTP id o9QHADWT001738
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:10:13 -0700
Received: by yxj4 with SMTP id 4so638925yxj.12
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:10:13 -0700 (PDT)
In-Reply-To: <4CC708CE.4040404@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 9:58 AM, Brian Haley <brian.haley@hp.com> wrote=
:
> > That won't help the case I am trying to fix, which is the case wher=
e
> > the new link has a global prefix different than the old link. Marki=
ng
> > the addresses as tentative will simply make them pass DAD and come
> > back as soon as link comes back. But since they don't match the pre=
fix
> > that is assigned to the new link, they are unusable, because packet=
s
> > can't be routed back to them.
>
> The old addresses will become deprecated, and eventually get removed,=
 but
> it will take 2 hours.

Yes, but they become deprecated only after the preferred lifetime is
expires. Until that happens, the kernel considers them fair game and
will use them for outgoing connections, without knowing that they
won't work. So the user just sees connection timeouts and thinks that
IPv6 is slow.

> http://marc.info/?l=3Dlinux-netdev&m=3D128415231909522&w=3D2
>
> But the first response pointed out that I didn't test this with just =
a
> simple link flap, in which case all the IPv6 addresses are deleted,
> and all sessions using them die. =A0Not good. =A0This changes the cur=
rent
> behavior, and isn't what happens with IPv4 either.

Actually, I just tested this and it works fine. I opened a telnet
session to ipv6.google.com port 80, and while the TCP connection was
open I reassociated with the same wifi link. During the flap, the
patch removed and then readded the same global IPv6 address. While it
was doing it, I typed GET / HTTP/1.0\n\n in the telnet window. When
the address came back, the response came back fine. The connection was
not reset.

> Having these addresses restart DAD is probably about as much as we
> can do I think, unless we add a per-device sysctl to remove the addre=
sses
> (which I think has been shot-down before).

As before, just setting them tentative won't help that case I am
trying to fix. They have to be removed.

> Is this a mobile device that is actually changing it's point of attac=
hment?

This is a laptop that is changing SSIDs, plugging into wired/wireless,
etc. At work we have multiple wireless networks with their own IPv6
ranges. The typical case is that I am connected to the corp network,
then I associate with the guest network... and IPv6 is broken, because
the kernel wants to use my old address and gateway, which don't work.

I'm also doing lab testing of IPv6-capable home routers, each of which
has its own wireless network. As you can imagine, after a couple of
switches, I end up with three IPv6 addresses and between three sets of
default gateways, only one of which works.
