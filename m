From: Andrew Savchenko <bircoph@gmail.com>
Subject: Re: [BUG] Kernel recieves DNS reply, but doesn't deliver it to a
 waiting application
Date: Fri, 23 Nov 2012 11:45:39 +0400
Message-ID: <20121123114539.f2e544b4.bircoph@gmail.com>
References: <20121003232548.eb6b6b22.bircoph@gmail.com>
	<20121013163639.87abca00.bircoph@gmail.com>
	<1350135860.21172.14606.camel@edumazet-glaptop>
	<20121014031119.a60263d6.bircoph@gmail.com>
	<20121021032543.09d1844f.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__23_Nov_2012_11_45_39_+0400_FHVUR_9FbJyaeU76"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:47823 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932907Ab2KWHqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 02:46:10 -0500
Received: by mail-la0-f46.google.com with SMTP id p5so4138825lag.19
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 23:46:08 -0800 (PST)
In-Reply-To: <20121021032543.09d1844f.bircoph@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__23_Nov_2012_11_45_39_+0400_FHVUR_9FbJyaeU76
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On Sun, 21 Oct 2012 03:25:43 +0400 Andrew Savchenko wrote:
> > On Sat, 13 Oct 2012 15:44:20 +0200 Eric Dumazet wrote:
[...]
> > > You should investigate and check where the incoming packet is lost
> > >=20
> > > Tools :
> > >=20
> > > netstat -s
> > >=20
> > > drop_monitor module and dropwatch command
> > >=20
> > > cat /proc/net/udp
> >=20
> > Thank you for you reply; I updated my kernel to 3.4.14, enabled
> > CONFIG_NET_DROP_MONITOR, and installed dropwatch utility.
> >=20
> > I will report back when the bug will struck again.
> > This may take a weak or two, however.
>=20
> This bug is back again on kernel 3.4.14, but this time I was able to
> get debug data and to recover running kernel without reboot.
>=20
> Drowpatch showed that DNS UDP replies are always dropped here:
> 1 drops at __udp_queue_rcv_skb+61 (0xffffffff813bd670)
>=20
> Another observations:
> - only UDP replies are lost, TCP works fine;
> - if network load is dropped dramatically (ip_forward disabled, most
> network daemons are stopped) UDP DNS queries work again; but with
> gradual load increase replies became first slow and than cease at all.
> - CPU load is very low (uptime is below 0.05), so this shouldn't be
> an insufficient computing power issue.
>=20
> I found __udp_queue_rcv_skb function in net/ipv4/udp.c. From the code
> and observations above it follows that this is likely to be a ENOMEM
> condition leading to a packet loss.
[...]
> net.ipv4.udp_mem =3D 100000       150000  200000
>=20
> This solved my issue, at least for a while: DNS queries are working
> fine now.

And this solved problem only temporary: after 40 days of uptime the
same problem struck again with the same observables. I "solved" this
by increasing udp memory again:

net.ipv4.udp_mem =3D 200000  300000  400000

Of course, this solution is only a temporary workaround. Such
behaviour increases my suspicions on some kind of memory leak.

This host is still on 3.4.14, however: can't reboot now due to
workload. Will try 3.7 branch as soon as this will be possible.

Best regards,
Andrew Savchenko

--Signature=_Fri__23_Nov_2012_11_45_39_+0400_FHVUR_9FbJyaeU76
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCvKb0ACgkQ2anJBBcsZw0FLwCg0lBB66DT+GGIrM/BeanlkFgj
qCsAniR58euXez7QDRwHq6gLwNPWASx9
=FzKn
-----END PGP SIGNATURE-----

--Signature=_Fri__23_Nov_2012_11_45_39_+0400_FHVUR_9FbJyaeU76--
