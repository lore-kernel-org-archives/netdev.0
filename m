From: Thomas Dreibholz <dreibh@iem.uni-due.de>
Subject: Re: [PATCH] net: SCTP remote/local Denial of Service vulnerability description and fix
Date: Thu, 16 Sep 2010 12:43:06 +0200
Message-ID: <201009161243.10710.dreibh@iem.uni-due.de>
References: <201009151001.59860.dreibh@iem.uni-due.de> <4C90D1E8.7000404@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Martin Becke <martin.becke@uni-due.de>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.uni-due.de ([132.252.185.19]:60416 "EHLO
	mailout.uni-due.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148Ab0IPKnT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 06:43:19 -0400
In-Reply-To: <4C90D1E8.7000404@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mittwoch 15 September 2010, Vlad Yasevich wrote:
> On 09/15/2010 04:01 AM, Thomas Dreibholz wrote:
> > sctp_outq_flush() in net/sctp/outqueue.c may call sctp_packet_reset=
() on
> > a packet structure which has already been filled with chunks.
> > sctp_packet_reset() will not take care of the chunks in its list an=
d
> > only reset the packet length. After that, the SCTP code assumes the
> > packet to be re-initialized and adds further chunks to the structur=
e.
> > The length will be wrong. When actually trying to transmit the pack=
et,
> > the packet sk_buff structure may be exceeded within
> > sctp_packet_transmit(), resulting in skb_over_panic() =3D> denial o=
f
> > service.
> >=20
> > Such a DoS can be triggered by a malicious remote SCTP instance, as
> > follows: - The remote endpoint has to use two paths (i.e. 2 IP
> > addresses); easy to achieve using an IPv4 address and an IPv6 addre=
ss ->
> > path A and B. - The remote user has to trigger the transmission of =
a
> > HEARTBEAT_ACK on path A. This is trivial, by sending a HEARTBEAT ch=
unk.
> > sctp_outq_flush() will call sctp_packet_config() for the packet on =
path
> > A. The HEARTBEAT_ACK will be added to this packet.
> > - The remote user has to trigger a DATA chunk retransmission on pat=
h B.
> > This is trivial, since it only has to send appropriate SACK chunks.
> > sctp_outq_flush() notices that the retransmission is on a different=
 path
> > and calls sctp_packet_config() for the packet on path B. The DATA c=
hunk
> > to be retransmitted is added to this packet.
> > - The local instance has to send another DATA chunk on path A. This
> > depends on the application, but should be easy to trigger from a re=
mote
> > instance. sctp_outq_flush() notices that the path has changed again=
, and
> > calls sctp_packet_config() for the packet on path A. This resets th=
e
> > size of the HEARTBEAT_ACK chunk, but the chunk remains in the packe=
t. If
> > size(HEARTBEAT_ACK) + size(DATA) > MTU - overhead, the next call to
> > sctp_packet_transmit() causes the kernel panic =3D> DoS.
> > In a similar way, the problem can also be triggered by a local user=
,
> > having only the permission to establish SCTP associations. Of cours=
e,
> > the problem can also occur during normal network operation, just by=
 a
> > retransmission at the wrong time.
> >=20
> > The patch below against 2.6.36-rc4 (git repository) fixes
> > sctp_outq_flush() by ensuring that the packet on each path is
> > initialized only once. Furthermore, a BUG_ON() statement ensures th=
at
> > further problems by calling
> > sctp_packet_reset() on packets with chunks are detected directly.
>=20
> Actually I have a much easier solution.  When calling packet_config, =
we
> should not be resetting the packet contents.
>=20
> Packet contents need to be reset when a new packet is created or when=
 the
> packet has been sent.  We explicitly reset it after sending in
> sctp_packet_transmit.  We also reset it in sctp_packet_init().  So, c=
ode
> such as:
> 	sctp_packet_init()
> 	sctp_packet_config()
>=20
> already guarantees that at config time we have a clear packet.
>=20
> So, simply removing a reset call from sctp_packet_config() solves thi=
s

Great! It works fine.

I hope this bugfix will go into the main tree soon, in order to get the=
=20
distribution kernels fixed.


Best regards
--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
 Dr. Thomas Dreibholz

 University of Duisburg-Essen,                   Room ES210
 Inst. for Experimental Mathematics              Ellernstra=DFe 29
 Computer Networking Technology Group            D-45326 Essen/Germany
-----------------------------------------------------------------------
 E-Mail:     dreibh@iem.uni-due.de
 Homepage:   http://www.iem.uni-due.de/~dreibh
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
