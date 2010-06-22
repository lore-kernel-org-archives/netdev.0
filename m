From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: can multi app capture on same NIC?(use packet_mmap)
Date: Tue, 22 Jun 2010 19:31:41 +0100
Message-ID: <20100622183141.GQ11110@cel.leo>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24985FE8F8@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KCGU/3tJP9FZjbY4"
To: Jon Zhou <Jon.Zhou@jdsu.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:60953 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752592Ab0FVSbn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 14:31:43 -0400
Content-Disposition: inline
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24985FE8F8@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--KCGU/3tJP9FZjbY4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 22, 2010 at 02:40:13AM -0700, Jon Zhou wrote:
> I'd like to know multi-app can work with packet_mmap (or traditional AF_P=
ACKET system call)?
> i.e.
> app1 & app2 capture on the same NIC
>=20
> will both of them receive the same packet?=20
>=20
> Or this situation will happen?
>=20
> 1.app1 start to receive a packet#1
> 2.app1 complete receiving, then set the packet_status->TP_STATUS_KERNEL
> 3.how about app2 at this time? Will it see packet_status=3DKERNEL, then p=
acket#1 got lost?

Sure; each PF_PACKET socket gets its own memory buffer.

> I tried to find the relevant code in af_packet.c, seems it doesn't guaran=
tee multi-app capture on same NIC?
> Can someone help to point it out?

That's because af_packet.c doesn't need to care. All the relevant code
is found in net/core/dev.c

PF_PACKET sockets get installed into the ptype_all list:

  void dev_add_pack(struct packet_type *pt)
  {
          int hash;

          spin_lock_bh(&ptype_lock);
          if (pt->type =3D=3D htons(ETH_P_ALL))
                  list_add_rcu(&pt->list, &ptype_all);
  ...

Thereafter, every packet that's received is delivered, individually, to
every handler in that list:

  int netif_receive_skb(struct sk_buff *skb)
  {
  ...
          list_for_each_entry_rcu(ptype, &ptype_all, list) {
                  if (ptype->dev =3D=3D null_or_orig || ptype->dev =3D=3D s=
kb->dev ||
                      ptype->dev =3D=3D orig_dev) {
                          if (pt_prev)
                                  ret =3D deliver_skb(skb, pt_prev, orig_de=
v);
  ...

Finally, in net/packet/af_packet.c, each PF_PACKET socket gets a copy of
this skb anyway; look for the call to skb_copy_bits() in the function
tpacket_rcv()

Hope that helps,

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--KCGU/3tJP9FZjbY4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMIQGNvLS2TC8cBo0RAmJ8AKCOMaqoK3PWeK4+bM6cxeAZ+/TndACgmkg3
DSWorF5BTBtlc3IuoHEGGTk=
=K42W
-----END PGP SIGNATURE-----

--KCGU/3tJP9FZjbY4--
