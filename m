From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 14470] New: freez in TCP stack
Date: Fri, 27 Nov 2009 07:17:06 +0100
Message-ID: <4B0F6EE2.7000301@gmail.com>
References: <4AE92F4D.6070101@gmail.com>	<20091029.010009.175904855.davem@davemloft.net>	<alpine.DEB.2.00.0911262352050.24189@melkinpaasi.cs.helsinki.fi> <20091126.153745.115170133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, akpm@linux-foundation.org,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kolo@albatani.cz, bugzilla-daemon@bugzilla.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53496 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbZK0GRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 01:17:19 -0500
In-Reply-To: <20091126.153745.115170133.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :

> I must be getting old and senile, but I specifically remembered that
> we prevented a socket from ever being bound again once it has been
> bound one time specifically so we didn't have to deal with issues
> like this.
>=20
> I really don't think it's valid for NFS to reuse the socket structure
> like this over and over again.  And that's why only NFS can reproduce
> this, the interfaces provided userland can't actually go through this
> sequence after a socket goes down one time all the way to close.
>=20
> Do we really want to audit each and every odd member of the socket
> structure from the generic portion all the way down to INET and
> TCP specifics to figure out what needs to get zero'd out?

An audit is always welcomed, we might find bugs :)

>=20
> So much relies upon the one-time full zero out during sock allocation=
=2E
>=20
> Let's fix NFS instead.

bugzilla reference : http://bugzilla.kernel.org/show_bug.cgi?id=3D14580

Trond said :
  NFS MUST reuse the same port because on most servers, the replay cach=
e is keyed
  to the port number. In other words, when we replay an RPC call, the s=
erver will
  only recognise it as a replay if it originates from the same port.
  See http://www.connectathon.org/talks96/werme1.html


Please note the socket stays bound to a given local port.

We want to connect() it to a possible other target, that's all.

In NFS case 'other target' is in fact the same target, but this
is a special case of a more general one.

Hmm... if an application wants to keep a local port for itself (not
allowing another one to get this (ephemeral ?) port during the=20
close()/socket()/bind() window), this is the only way.
TCP state machine allows this IMHO.

google for "tcp AF_UNSPEC connect" to find many references and man page=
s
for this stuff.

http://kerneltrap.org/Linux/Connect_Specification_versus_Man_Page

How other Unixes / OS handle this ?
How many applications use this trick ?


