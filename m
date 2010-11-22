From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: [PATCH 7/9] AF_UNIX: Documentation on multicast Unix Sockets
Date: Mon, 22 Nov 2010 20:09:31 +0000
Message-ID: <20101122200931.106731cd@chocolatine.cbg.collabora.co.uk>
References: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
	<1290450982-17480-7-git-send-email-alban.crequy@collabora.co.uk>
	<201011222107.41548.remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "=?UTF-8?B?UsOpbWk=?= Denis-Courmont" <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:52308 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755512Ab0KVUL1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 15:11:27 -0500
In-Reply-To: <201011222107.41548.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mon, 22 Nov 2010 21:07:40 +0200,
"R=C3=A9mi Denis-Courmont" <remi@remlab.net> a =C3=A9crit :

> Le lundi 22 novembre 2010 20:36:20 Alban Crequy, vous avez =C3=A9crit=
 :
> > +Multicast Unix sockets
> > +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > +
> > +Multicast group memberships are stored in struct unix_mcast nodes.
> > An Unix +socket can join several multicast groups. Struct
> > unix_mcast nodes are doubly +linked:
> > +- In (struct unix_sock)->mcast_subscriptions
> > +- In (struct unix_sock)->mcast_members
>=20
> I may be stupid, but I found this whole documentation very confusing,
> and so the API it tries to describe. Traditionally:
> - Senders may or not may be part of the group and are not kept track
> of.
> - Receivers join to the group then receive message sent to it.
> - Loopback defines whether a sender receives its own echo if it sends
> to a group that it has joined.
> - If connected to a multicast group, messages from the socket are
> routed to the group (in absence of a contradictoy socket address).
> This has no effect on membership to the multicast group under any
> circumstance.

I keep these traditional properties for multicast on Unix sockets.

> You cannot 'listen' or 'accept' on a multicast group.

Datagram sockets cannot listen() or accept() but seqpacket sockets can.
I would like multicast to work on seqpacket sockets too. In this case,
there is a central daemon who listen(), and accept() returns a new
socket. The central daemon controls the lifetime of the multicast
group and can receive the messages from the peers on the socket
returned by accept() if UNIX_MREQ_SEND_TO_PEER is set.

The accepted socket could join the multicast group (and then receive
messages addressed to the group) with the setsockopt() call, but then
there would be a race that it may not receive the first messages if a
peer connect() and send a message immediately afterwards. connect() can
returns on the peer process before the daemon accept() and runs
setsockopt(). I added the flag UNIX_MREQ_AUTOJOIN (to be set when
creating the multicast group) to prevent that race.

Using connected sockets (seqpacket) is useful for D-Bus because a
central daemon can know when members are connecting and disconnecting
and then emit the D-Bus signal 'NameOwnerChanged'.

> So I am not entirely clear what semantics your patchset is following.
> But it does not seem like "multicast" to me and therefore seems not
> very well documented :-(

I am willing to improve it.

--=20
Alban
