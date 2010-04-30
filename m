From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: [RFC] BPF program access to transport header
Date: Fri, 30 Apr 2010 20:39:17 +0100
Message-ID: <20100430193916.GZ19334@cel.leo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="f8lmXUvqnCdFQPaI"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:47251 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756873Ab0D3TjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 15:39:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--f8lmXUvqnCdFQPaI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Via the SKF_NET_OFF extension area, a BPF program has nice easy access
to the network header, wherever it might happen to be in the packet.
This makes it simpler to write filters on e.g. IPv4 headers, knowing
that fields will always be at simple offsets relative to SKF_NET_OFF.
Using the data at WORD[SKF_AD_PROTO] it's easy also to find out what
network protocol this is.

I would like to provide similar for the transport header. Without doing
so, it is very hard to parse e.g. UDP or TCP headers that may be
contained within IPv6 protocol, because of the linked-list way IPv6
headers chain on to each other. BPF doesn't provide a while() loop or
any kind of backward jump, meaning the filter program has to be
loop-unrolled a static number of times. This quickly leads to very large
programs.

I forsee a number of issues with trying to provide this:

 * How to provide the protocol number (e.g. 6 for TCP, 1 for ICMP) to
   the BPF program

 * How to obtain the transport offset - AIUI, the skf_transport_offset()
   won't actually be set yet by the time the filter program runs.

 * What to do if the underlying protocol doesn't support a transport
   layer above it - e.g. ARP.

Ideally, this would make it easy to filter, say, TCP destination port
80, by doing the following:

  LD WORD[SKF_AD_PROTO]
  JEQ ETHERTYPE_IPV4, 1, fail
  JEQ ETHERTYPE_IPv6, 0, fail

  LD WORD[SKF_AD_TRANSPROTO]
  JEQ IPPROTO_TCP, 0, fail

  LD WORD[SKF_TRANS_OFF+0]
  JEQ 80, 0, fail

  LD len
  RET A

fail:
  RET 0

In this short simple BPF program we've avoided all the issues involved
with trying to parse IPv6 headers.

Can we make this work?

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--f8lmXUvqnCdFQPaI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFL2zHkvLS2TC8cBo0RAoO3AJ97Amlvld6joJ9UDteYfGZ51DuY1wCdH7MX
RhYRcxSpb91Ysdoo6ZZvOf8=
=R/Xi
-----END PGP SIGNATURE-----

--f8lmXUvqnCdFQPaI--
