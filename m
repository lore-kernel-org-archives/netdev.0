From: Harald Welte <laforge@netfilter.org>
Subject: Re: [Bug 155] Outgoing MLD packets are not traversing netfilter
Date: Thu, 4 Dec 2003 17:09:22 +0530
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20031204113922.GB7680@obroa-skai.de.gnumonks.org>
References: <E1ARpMB-00087s-5m@vishnu.netfilter.org> <20031204092816.GC28403@ruf098.fkie.fgan.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cvVnyQ+4j833TQvp"
Cc: netdev@oss.sgi.com,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Michael Bussmann <bus@mb-net.net>
Content-Disposition: inline
In-Reply-To: <20031204092816.GC28403@ruf098.fkie.fgan.de>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--cvVnyQ+4j833TQvp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 04, 2003 at 10:27:54AM +0100, Michael Bussmann wrote:

> However, I still notice an oddity: MLD packets are not recognised as
> icmpv6 messages.

That's bad.  Are you talking about MLDv1 or MLDv2 packets?

> I set up a simple set of rules that directs both icmpv6 packets and "any"
> packets (just for testing purposes) to the QUEUE target. An application
> program (using libipq) dumps all packets:

Ouch.  We have two issues here:

1) ip6_tables not matching it as icmp6 packet

   This basically means that skb->nh.ipv6h is not initialized, or
   points to skb->raw instead of the ipv6 header.

   I cannot see how this could happen in the mld_sendpack(), since
   itself dereferences skb->nh.ipv6h
  =20
   In the igmp6_send() case, ip6_nd_hdr() initializes skb->nh correct,
   so I also cannot see this happen.

2) ip6_queue copying the linklayer header to userspace

   This means that skb->data does not point at the beginning of the
   ipv6 packet (i.e. skb->data !=3D skb->nh.ip6h), but to the beginning of
   the hardware header (i.e. skb->data =3D=3D skb->head).

   This is because mcast.c writes the full packet including the hardware
   header and _then_ calls NF_HOOK.  All other code (ipv6 or ipv4) is
   building the layer 3 packet, then calling NF_HOOK and later on (via
   ipX_outpur_finish() or dst_output()) adding the hardware header.

> I'm not sure whether this is a bug, but it seems to be inconsistent that
> some icmpv6 packets are dumped with the LL and others are not.

of course it is a bug.

So the fundamental question (with regard to the ipv6 gods) is:  Is it
really necessarry that the ipv6 mcast code bypasses the destination
cache?

IPv4 multicast just uses the dst_cache, and thus sends the packet using
the normal dst_output() functions.

I have to admit that I'm not as fluent with the code to decide why ipv6
multicast is the only code in ipv4/ipv6 that manually adds the hardware
header and bypasses the normal dst_otput() way?.  Can somebody explain?

> Let me know if you need further information.

As I am currently travelling, I cannot really play with any multicast
networking (just a single notebook machine here, and it is ppc, so no
user-mode-linux).

> Best regards,
> MB

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--cvVnyQ+4j833TQvp
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/zx0AXaXGVTD0i/8RAh0SAKCziMP8L76fLxyvBxxC9XI3d7yFDACfUXuX
O76opGIfnXi5iO1h47XPnH8=
=Sk4I
-----END PGP SIGNATURE-----

--cvVnyQ+4j833TQvp--
