From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: remove all rt cache entries on UNREGISTER event
Date: Wed, 29 Sep 2010 10:35:49 +0200
Message-ID: <1285749349.2615.27.camel@edumazet-laptop>
References: <4CA208C9.1020800@6wind.com>
	 <1285691629.3154.80.camel@edumazet-laptop>  <4CA21BC6.5070300@6wind.com>
	 <1285692969.3154.86.camel@edumazet-laptop>  <4CA2EF9C.9040909@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43603 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178Ab0I2Ifz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 04:35:55 -0400
Received: by fxm14 with SMTP id 14so295589fxm.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 01:35:54 -0700 (PDT)
In-Reply-To: <4CA2EF9C.9040909@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 29 septembre 2010 =C3=A0 09:49 +0200, Nicolas Dichtel a =C3=
=A9crit :
> Eric Dumazet wrote:
> > Le mardi 28 septembre 2010 =C3=A0 18:45 +0200, Nicolas Dichtel a =C3=
=A9crit :
> >> Eric Dumazet wrote:
> >>> Le mardi 28 septembre 2010 =C3=A0 17:24 +0200, Nicolas Dichtel a =
=C3=A9crit :
> >>>> Hi,
> >>>>
> >>>> I face a problem when I try to remove an interface,=20
> >>>> netdev_wait_allrefs() complains about refcount.
> >>>>
> >>>> Here is a trivial scenario to reproduce the problem:
> >>>> # ip tunnel add mode ipip remote 10.16.0.164 local 10.16.0.72 de=
v eth0
> >>>> # ./a.out tunl1
> >>>> # ip tunnel del tunl1
> >>>>
> >>>> Note: a.out binary create an IPv4 raw socket, attach it to tunl1=
=20
> >>>> (SO_BINDTODEVICE), set it as multicast (IP_MULTICAST_LOOP), set =
the=20
> >>>> multicast interface to tunl1 (IP_MULTICAST_IF), build the IP hea=
der=20
> >>>> (IP_HDRINCL) and then send a single packet (192.168.6.1 -> 224.0=
=2E0.18).
> >>>>
> >>>> Note2: when a.out is executed, tunl1 has no ip address and is do=
wn.
> >>>>
> >>> CC Octavian Purdila, the patch author.
> >>>
> >>> I am just wondering why this route is created in the first place.
> The route is created because no function will check interface status =
(up=20
> and running or down). Just at the end, the packet will be enqueued in=
=20
> the noop qdisc.
>=20

In your case maybe, but I think there is another point where we can cal=
l
dev_hold() while device is in dismantle phase.


> >> At first, I asked myself the same question, but it seems that this=
 is=20
> >> allowed to send a packet through this kind of socket, even if inte=
rface=20
> >> is down. Packet will be destroyed by the noop qdisk.
> >> But I agree that it is strange to perform route lookup and everyth=
ing to=20
> >>    destroy the packet at the end ...
> >> Maybe raw_sendmsg() can delete it directly ;-) ... or maybe=20
> >> ip_route_output_flow().
> >>
> >> Any suggestions welcome.
> >>
> >=20
> > Hmm...
> >=20
> > One way to track this kind of problem would be to add a WARN_ON() i=
n
> > dev_hold()
> >=20
> > -> Check that when a reference on dev is taken, we are in a known s=
tate.
> >=20
> > Something like this ?
> dev_hold() is done when interface is down, but before unregistering=20
> process start.

Not on my machine. I can see the backtrace sometimes.

There is a race somewhere (maybe several), and your patch only reduce
the window of this race.

I am working on it.


