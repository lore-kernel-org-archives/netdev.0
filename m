From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Mon, 09 May 2011 08:37:16 +0200
Message-ID: <1304923036.3207.105.camel@edumazet-laptop>
References: <1304793749.3207.26.camel@edumazet-laptop>
	 <1304838742.3207.45.camel@edumazet-laptop>
	 <F57561A93EFF5E88729A8D53@nimrod.local>
	 <7B76F9D75FD26D716624004B@nimrod.local>
	 <20110508125028.GK2641@linux.vnet.ibm.com>
	 <B2891EFD056565BBD4DBCE16@nimrod.local>
	 <20110508134425.GL2641@linux.vnet.ibm.com>
	 <C449131127D58077CB25C9D8@Ximines.local>
	 <20110508144749.GR2641@linux.vnet.ibm.com>
	 <AB9DE9E04289CF29CA79CC67@Ximines.local>
	 <20110508154854.GT2641@linux.vnet.ibm.com>
	 <1304888447.3207.66.camel@edumazet-laptop>
	 <BA03B09F0474B30660A091FD@nimrod.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Ben Greear <greearb@candelatech.com>
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56803 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671Ab1EIGhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 02:37:20 -0400
Received: by wya21 with SMTP id 21so3625578wya.19
        for <netdev@vger.kernel.org>; Sun, 08 May 2011 23:37:19 -0700 (PDT)
In-Reply-To: <BA03B09F0474B30660A091FD@nimrod.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 mai 2011 =C3=A0 06:37 +0100, Alex Bligh a =C3=A9crit :
>=20
> --On 8 May 2011 23:00:47 +0200 Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>=20
> > We can probably speed things, but we should consider the following =
user
> > actions :
>=20
> How about
>=20
> > ip link add link eth0 vlan103 type vlan id 103
> > ip link del vlan103
>=20
> Removes and unlinks structures, including making name available, send=
ing
> out netlink messages, but doesn't free things

Most of the cleanup work has to be done with RTNL being held, and this
might because of transaction atomicity requirement.

In your test you dismantle idle devices. Now think a bit when you have
both trafic in and out, sockets with destinations still pointing to the
device, in flight arp requests, all this using RCU of course.

When you dismantle one device (or several in case of a module unload),
this can have implications on other devices (see veth cas for an obviou=
s
example : this automatically removes the peer device), but also on
routes, neighbours, cached routes, various protocol cleanups, ... and s=
o
on. Few people even on netdev understand the whole picture.

Given that 99.99% machines setup netdevice at boot time only, and hardl=
y
consider dismantles, we netdev guys were pragmatic and safe. Two or
three synchronize_rcu() were considered as a non issue.

It seems there is interest to improve things now.

One way is to allow more batching and delegation, and I am working on
that right now, using a kthread, so that we dont block the requester fo=
r
the whole device dismantle.

This kthread might use call_rcu() driven state machine, but that is a
detail of implementation, since only kthread would be impacted.

I am pretty busy at work these days, so dont expect patches before some
time :)



