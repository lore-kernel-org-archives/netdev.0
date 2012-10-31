From: Michael Richardson <mcr@sandelman.ca>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Wed, 31 Oct 2012 18:42:08 -0400
Message-ID: <21992.1351723328@obiwan.sandelman.ca>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com> <3246.1351717319@obiwan.sandelman.ca> <CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Ani Sinha <ani@aristanetworks.com>,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: netdev@vger.kernel.org, tcpdump-workers@lists.tcpdump.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tuna.sandelman.ca ([209.87.252.184]:41250 "EHLO
	tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759020Ab2JaWuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 18:50:25 -0400
In-Reply-To: <CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Transfer-Encoding: quoted-printable


>>>>> "Ani" =3D=3D Ani Sinha <ani@aristanetworks.com> writes:
    Ani> cc'ing netdev.

    >> Do you think that the existance of this behaviour could be exposed in
    >> sysctl, /proc/net or /sys equivalent (we still don't have /sys/net..=
.)?
    >> As a read only file that had a 0/1 in it?

    Ani> yes, we definitely need a run time check. Whether this could be in=
 the
    Ani> form of a socket option or a /proc entry I don't know.


unsigned int netdev_8021q_inskb =3D 1;

...
	{
		.ctl_name	=3D NET_CORE_8021q_INSKB,
		.procname	=3D "netdev_8021q_inskb",
		.data		=3D &netdev_8021q_inskb,
		.maxlen		=3D sizeof(int),
		.mode		=3D 0444,
		.proc_handler	=3D proc_dointvec
	},

would seem to do it to me.
Then pcap can fopen("/proc/sys/net/core/netdev_8021q_inskb") and if it
finds it, and it is >0, then do the cmsg thing.

    >> It sounds like it's impossible to capture all traffic now, and do vl=
an
    >> filtering later on?

    Ani> pcap files that already have the tags reinsrted should work with
    Ani> current filter code. However for live traffic, one has to get the =
tags
    Ani> from CMSG() and then reinsert it back to the packet for the current
    Ani> filter to work. This is slow.

I think that this better vlan handling will be much faster, and make
things much more consistent between systems with and without hardware
offload, so it's great news.

However, a number of people use Linux machines to do traffic captures of va=
rious
kinds using interfaces dedicated to that purpose.

It would be nice if there was a way to get the packet "whole", such as
by having a second PACKET_CAPTURE point, which was before the adjustment
of the vlan.  (obviously, if you had hardware, you'd want to turn that
off)
Many would like this capture point to actually eat all packets for the
interfaces it was defined for, as people doing captures never want those
packets going up the stack.=20

=2D-=20
]       He who is tired of Weird Al is tired of life!           |  firewall=
s  [
]   Michael Richardson, Sandelman Software Works, Ottawa, ON    |net archit=
ect[
] mcr@sandelman.ottawa.on.ca http://www.sandelman.ottawa.on.ca/ |device dri=
ver[
   Kyoto Plus: watch the video <http://www.youtube.com/watch?v=3Dkzx1ycLXQS=
E>
	               then sign the petition.=20

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQCVAwUAUJGpQIqHRg3pndX9AQKExwQAh4lkX9BeSxvMOkgvg4sh+KAKtLPLs3I4
NA/gkxsRZFJVsoccll6Klo0456TglvsU4d2yR20K91sYHUJmQiDeS9HSrJei3G0a
X0a4wjL0OKOMhluIYJuar4lmvBe148dbcKHPoxnEIk/aSSkEnYAsaxyYYsEUrncz
AL9W6AVjZGY=
=sWcm
-----END PGP SIGNATURE-----
--=-=-=--
