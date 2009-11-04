From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including
 destination address in the hash key
Date: Wed, 04 Nov 2009 22:30:27 +0100
Message-ID: <4AF1F273.5020207@gmail.com>
References: <4AF1EC18.9090106@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57663 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758190AbZKDVa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:30:27 -0500
In-Reply-To: <4AF1EC18.9090106@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lucian Adrian Grijincu a =E9crit :
> Hi,
>=20
> Before you look at the patch attached: I know it's not the prettiest =
of patches sent here. It's a work-in-progress and is ugly and incomplet=
e (for example IPv6 is not properly updated to benefit this patch and m=
ay even be as buggy as hell right now).
> I'm sending it here to ask for an opinion on the approach.
>=20
> The current approach uses one single hash to lookup UDP sockets.
> The key to the hash is calculated based on the port only.
> This works well if there aren't many sockets bound to the same port, =
but becomes a linear linked list search for a setup with many UPD packe=
ts bound to the same port, which does not scale much.
>=20
> In this patch the hashtable lookup key takes into consideration the a=
ddress the socket is bound to too.
> This will lead to better distribution for setup where there are many =
UDP sockets bound to the same port but different IP addresses.
>=20
> There's a subtle bug lurking here: because some sockets may be bound =
to INADDR_ANY when checking whether a given UPD port is already taken o=
ne must search two buckets:
> * one with the key computed from the port and for the IP address of t=
he socket
> * one with the key computed from the port and INADDR_ANY
>=20
> Now if the address by which we must do the lookup is INADDR_ANY there=
's another problem: we can't just search it's own bucket and the bucket=
 for INADDR_ANY (the same bucket twice) like above because there might =
be a socket bound to a specific address and the port we're trying to bi=
nd to.
>=20
> In this case we could search the whole hash (which would take forever=
) or use another hash that is computed based on the port only (which th=
is patch does).
>=20
> There are other things to look after: when modifying the hashes we mu=
st take spin_locks or spin_lock_bhs. Because we now have two hashtables=
 and one hashtable might be searched twice locks must be taken in the p=
roper order.
>=20
> I ran the attached UDP tester: it's a program that binds to a lot of =
UDP sockets and if run as a sender it sends lots of datagrams to the re=
ceiver which will just count the number of packets recevied.
>=20
>=20
>=20
> =3D=3D Performance stats =3D=3D
> I ran this on a 2.6.31 with and without the patch on two powerpc sing=
le core processors connected directly by 100Mbps ethernet.
>=20
> * nsocks      =3D number of IPv4 bound sockets
> * ndgrams     =3D number of datagrams sent by each socket
> * payloadlen  =3D the lenght of the UPD message sent
> * send_time   =3D how many second did the sending operation take?
> * recv_dgrams =3D how many datagrams were successfully received?
>=20
>=20
> 1. nsocks=3D512 ndgrams=3D2000 payloadlen=3D1
> - without patch:
> 	* send_time   =3D 27s to 31s
> 	* recv_dgrams =3D 550 to 850
> - with patch:
> 	* send_time   =3D 35s to 36s
> 	* recv_dgrams =3D 507000 to 516000
>=20
> 2. nsocks=3D512 ndgrams=3D4000 payloadlen=3D1
> - without patch:
> 	* send_time   =3D 53s to 60s
> 	* recv_dgrams =3D 650 to 1100
> - with patch:
> 	* send_time   =3D ~70s
> 	* recv_dgrams =3D 1010000 to 1034000
>=20
> 3. nsocks=3D512 ndgrams=3D4000 payloadlen=3D1000
> - without patch:
> 	* send_time   =3D ~74s
> 	* recv_dgrams =3D 650
> - with patch:
> 	* send_time   =3D ~88s
> 	* recv_dgrams =3D 995000
>=20
> 4. nsocks=3D256 ndgrams=3D2000 payloadlen=3D1
> - without patch:
> 	* send_time   =3D 13s
> 	* recv_dgrams =3D 370 to 720
> - with patch:
> 	* send_time   =3D 17s
> 	* recv_dgrams =3D 267000
>=20
>=20
> As you can see this has a hit on total send time, but the number of r=
eceived packets increases by two orders of magnitude.
>=20
> I'd like hear your opinion about this approach.
> If you'd like to test this, I'll be happy to port it to net-next and =
provide the patch.
>=20
>=20

I knew someone would do this kind of patch one day, I tried it one year=
 ago :)

=46irst of all, you are mixing several things in this patch.

Dont do this, its not possible for us to correctly review such complex =
patch.

Then, your patch is not based on net-next-2.6, and you really need to w=
ork on this tree.

Then, if you had worked on net-next-2.6, you whould have noticed UDP ha=
sh tables
are now dynamically sized at boot.
An admin can even force a 65536 slots hash table for heavy duty UDP ser=
vers.

Then, last point : Say I have a machine with 65000 udp sockets bound to=
 a different port,
and a 65536 slots hash table, (sane values in fact, in order to have be=
st performances),
then your two phase lookup will be slower than the one-phase current lo=
okup (two cache misses
instead of one)

So your patch seems to solve a pathological case (where many udp socket=
s are
bounded to a particular port, but on many different IPs), and slow down=
 99%
of other uses.

Thanks
