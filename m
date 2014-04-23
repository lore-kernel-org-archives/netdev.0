From: David Gibson <dgibson@redhat.com>
Subject: Re: RFC: rtnetlink problems with Cisco enic and VFs
Date: Wed, 23 Apr 2014 14:15:51 +1000
Message-ID: <20140423141551.e969a8a45bd494e468d56b09@redhat.com>
References: <20140423092606.c73425b64d127b8f94469fcb@redhat.com>
	<20140422170438.00006b45@unknown>
	<20140423111203.3e8cf3a9a12acb1d95b3635a@redhat.com>
	<20140422.211642.1908374698598409144.davem@davemloft.net>
	<6CE81A2095B0024BBC77007BD04E553823E87A41@xmb-aln-x02.cisco.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__23_Apr_2014_14_15_51_+1000__/CJA7oH9r_T+U/N"
Cc: David Miller <davem@davemloft.net>,
	"gregory.v.rose@intel.com" <gregory.v.rose@intel.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sujith Sankar (ssujith)" <ssujith@cisco.com>,
	"govindarajulu90@gmail.com" <govindarajulu90@gmail.com>,
	"Neel Patel (neepatel)" <neepatel@cisco.com>,
	"nistrive@cisco.com" <nistrive@cisco.com>
To: "Christian Benvenuti (benve)" <benve@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37622 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746AbaDWEQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 00:16:16 -0400
In-Reply-To: <6CE81A2095B0024BBC77007BD04E553823E87A41@xmb-aln-x02.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__23_Apr_2014_14_15_51_+1000__/CJA7oH9r_T+U/N
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 23 Apr 2014 02:33:06 +0000
"Christian Benvenuti (benve)" <benve@cisco.com> wrote:

> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of David Miller
> > Sent: Tuesday, April 22, 2014 6:17 PM
> > To: dgibson@redhat.com
> > Cc: gregory.v.rose@intel.com; ben@decadent.org.uk;
> > netdev@vger.kernel.org; Christian Benvenuti (benve); Sujith Sankar
> > (ssujith); govindarajulu90@gmail.com; Neel Patel (neepatel);
> > nistrive@cisco.com
> > Subject: Re: RFC: rtnetlink problems with Cisco enic and VFs
> >=20
> > From: David Gibson <dgibson@redhat.com>
> > Date: Wed, 23 Apr 2014 11:12:03 +1000
> >=20
> > > And therein lies the problem.  I don't even know what the
> > > IFLA_VF_PORTS info is for, but presumably something uses it.  If they
> > > stop receiving it, they can be expected to break horribly.
>=20
> In the case of Enic, libvirt uses IFLA_VF_PORTS in the context of the por=
t profile
> (see virtualport section and 802.1Qbh in the libvirt network xml document=
ation).
>=20
> As Miller said, libvirt and iproute2 are the two known users (with libvir=
t being the main one)
> but you never know what else may be using it.

Ah, yes, I see it in libvirt.

I don't think it's used in iproute2 though, at least not in the master
branch.

$ git remote show origin
* remote origin
  Fetch URL:
git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
Push  URL:
git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
HEAD branch: master Remote branches: iproute-3.5.1     tracked
    master            tracked
    net-next          tracked
    net-next-3.11     tracked
    net-next-for-3.13 tracked
  Local branch configured for 'git pull':
    master merges with remote master
  Local ref configured for 'git push':
    master pushes to master (up to date)
$ git rev-parse HEAD
ce3436ca05ee2a9f4bf4c5b10eb25638865772cb
$ git grep IFLA_VF_PORTS
include/linux/if_link.h:	IFLA_VF_PORTS,
include/linux/if_link.h: *		[IFLA_VF_PORTS]

Those are declaration and comment only, no actual uses.

> > We did the same thing to VFINFO list.
>=20
> I guess you refer to Bugzilla 889319.
>=20
> > All the users I could find already set the mask unconditionally for all=
 device
> > dumps.
> >=20
> > It's absolutely, positively, the only reasonable fix for this problem.
>=20
> The fix based on IFLA_EXT_MASK seems reasonable to me
> (IFLA_EXT_MASK is in use in libvirt >=3D 1.0.3 and iproute2 >=3D3.4.0 bas=
ed on a quick check).

Ok.  And conveniently for me it looks like the EXT_MASK fix is also
backported into the RHEL libvirt.

Alright, I'll whip up a patch series that makes the IFLA_VF_PORTS
information conditional on the RTEXT_FILTER_VF flag.

--=20
David Gibson <dgibson@redhat.com>

--Signature=_Wed__23_Apr_2014_14_15_51_+1000__/CJA7oH9r_T+U/N
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTVz53AAoJEGw4ysog2bOSZDkP/24w7IpvJykoX1mobUtU9dmf
M4w1O8AupsDUfIC+a5HzwpANleQAJnnFNRHCOQ2UiGKIROtV/y3w30A8XalUKDdn
6Wo0ikjIwNHdID5oHZESs5ZQnFy77QdtKERJSreSd9LB8MlrVUd4uGFLcTjtoIDd
8zdSh/20ieUdFf01C6j4hSN7A/z6tkaNkaVQW97BDyalO3X/Ez6QxJhJ6vsgYBCH
ZPx5QPYSQRiI0QgCYEHH6k/HBIvocKHX/XtQN2lJk75La3PJuVhBmPIId6rjbZdD
fqtumsgW0vDXBPuJ89uwlQ3UbRPqQfyKL82VOk2vf2aZbN6uEA3qFROp8mK/L4YV
b0kziHUWhGci8mBVQS4SkJdy+uCG8lKCliPBLlXGiFbnuQjNvll8HZX/m4y2DZg8
q6loDj6YhqA3/KLRDE80SKWbP6OPDZ0uUgyASTbbtqROP4NMqBt18Ba+9IlLbnbk
86ojlbLs8jaLoEpBJIdxTkv9tbP5VADmOog0R5ZjJsHSI97ZF7KDYEr9cJ+soNlm
M1z3ZoWXWwfJYKvn7HJ1SDQhJpbOCLkNXYl3l1RP6JPZg0UGtxASZmiQVPIno0Em
QExWlw1JkSrLhy+QIcIEag7L2dj/UNLuljxtKkJnAF/4cef8biYsUPHddJxPNSr4
eKQIe/S1tNvwX10hhs9M
=Jw2u
-----END PGP SIGNATURE-----

--Signature=_Wed__23_Apr_2014_14_15_51_+1000__/CJA7oH9r_T+U/N--
