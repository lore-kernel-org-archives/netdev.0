From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.12+
Date: Mon, 01 Dec 2014 17:41:23 +0100
Message-ID: <1769392.YOU9Lj6NQS@h2o.as.studentenwerk.mhn.de>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <2335530.7OPnEQXbmV@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:41694 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752850AbaLAQl1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2014 11:41:27 -0500
In-Reply-To: <2335530.7OPnEQXbmV@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 1. Dezember 2014, 14:17:28 schrieb Wolfgang Walter:
> Am Samstag, 29. November 2014, 12:44:07 schrieb Thomas Jarosch:
> > Hello,
> >=20
> > we're in the process of updating production level machines
> > from kernel 3.4.101 to kernel 3.14.25. On one mail server
> > we noticed that emails destined for an IPSec tunnel sometimes
> > get stuck in the mail queue with TCP timeouts.
> >=20
> > To make a long story short: When the VPN connection is initially
> > set up or re-newed, the path MTU for the xfrm tunnel is undetermine=
d.
> >=20
> > As soon as a TCP client starts to send large packets,
> > it triggers path MTU detection. Some middlebox on the
> > way to the final server has a lower MTU and sends back
> > an "ICMP fragmentation needed" packet as normal.
> >=20
> > With the old kernel, the packet size for the TCP connection inside
> > the xfrm tunnel gets adjusted and all is fine. With kernel v3.12+,
> > the connection stalls completely. Same thing with kernel v3.18-rc6.
>=20
> We see something similar with real nic (RTL8139). In our case only th=
e first
> tcp-connection which triggers PMTU stalls. Later tcp-connections then=
 work
> fine.
>=20
> I will revert that patch and see if that fixes the problem.


Reverting the commit fixes the problem here, too.


>=20
> > We wrote a small tool to mimic postfix's TCP behavior (see attached=
 file).
> > In the end it's a normal TCP client sending large packets.
> > The server side is just "socat - tcp4-listen:667".
> >=20
> > If you run "socket_client" a second time, the path MTU
> > for the xfrm tunnel is already known and packets flow normal, too.
> >=20
> >=20
> > The "evil" commit in question is this one:
> > -------------------------------------------------------------------=
--
> > commit 8f26fb1c1ed81c33f5d87c5936f4d9d1b4118918
> > Author: Eric Dumazet <edumazet@google.com>
> > Date:   Tue Oct 15 12:24:54 2013 -0700
> >=20
> >     tcp: remove the sk_can_gso() check from tcp_set_skb_tso_segs()
> >    =20
> >     sk_can_gso() should only be used as a hint in tcp_sendmsg() to =
build
> >     GSO
> >=20
> > packets in the first place. (As a performance hint)
> >=20
> >     Once we have GSO packets in write queue, we can not decide they=
 are no
> >     longer GSO only because flow now uses a route which doesn't han=
dle
> >     TSO/GSO.
> >    =20
> >     Core networking stack handles the case very well for us, all we=
 need
> >     is keeping track of packet counts in MSS terms, regardless of
> >     segmentation done later (in GSO or hardware)
> >    =20
> >     Right now, if  tcp_fragment() splits a GSO packet in two parts,
> >     @left and @right, and route changed through a non GSO device,
> >     both @left and @right have pcount set to 1, which is wrong,
> >     and leads to incorrect packet_count tracking.
> >    =20
> >     This problem was added in commit d5ac99a648 ("[TCP]: skb pcount=
 with
> >     MTU
> >=20
> > discovery")
> >=20
> >     Signed-off-by: Eric Dumazet <edumazet@google.com>
> >     Signed-off-by: Neal Cardwell <ncardwell@google.com>
> >     Signed-off-by: Yuchung Cheng <ycheng@google.com>
> >     Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >=20
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index 8fad1c1..d46f214 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -989,8 +989,7 @@ static void tcp_set_skb_tso_segs(const struct s=
ock
> > *sk,
> > struct sk_buff *skb, /* Make sure we own this skb before messing
> > gso_size/gso_segs */ WARN_ON_ONCE(skb_cloned(skb));
> >=20
> > -       if (skb->len <=3D mss_now || !sk_can_gso(sk) ||
> > -           skb->ip_summed =3D=3D CHECKSUM_NONE) {
> > +       if (skb->len <=3D mss_now || skb->ip_summed =3D=3D CHECKSUM=
_NONE) {
> >=20
> >                 /* Avoid the costly divide in the normal
> >                =20
> >                  * non-TSO case.
> >                  */
> >=20
> > -------------------------------------------------------------------=
--
> >=20
> > When I revert it, even kernel v3.18-rc6 starts working.
> > But I doubt this is the root problem, may be just hiding another is=
sue.
> >=20
> > --- Sample output of socket_client using vanilla v3.12 kernel ---
> > [1417258063 SEND result: 4096, strerror: Success]
> > tcp max seg: res: 0, max_seg: 1370
> > [1417258063 SEND result: 4096, strerror: Success]
> > tcp max seg: res: 0, max_seg: 1370
> > [1417258063 SEND result: 4096, strerror: Success]
> > tcp max seg: res: 0, max_seg: 1370
> > [1417258063 SEND result: 4096, strerror: Success]
> > tcp max seg: res: 0, max_seg: 1370
> > [1417258063 SEND result: 4096, strerror: Success]
> > tcp max seg: res: 0, max_seg: 1338
> > [1417258063 SEND result: 4096, strerror: Success]
> > tcp max seg: res: 0, max_seg: 1338
> > *STUCK*
> > --------------------------------------------------------
> >=20
> > The "machine" is running on KVM and using "virtio_net" as NIC drive=
r.
> > I've played with the ethtool offload settings:
> >=20
> > *** eth1 defaults ***
> > Offload parameters for eth1:
> > rx-checksumming: on
> > tx-checksumming: on
> > scatter-gather: on
> > tcp-segmentation-offload: on
> > udp-fragmentation-offload: on
> > generic-segmentation-offload: on
> > generic-receive-offload: on
> > large-receive-offload: off
> >=20
> > *** eth1 working (no stalls) using vanilla kernel ***
> > Offload parameters for eth1:
> > rx-checksumming: on
> > tx-checksumming: off  <-- the magic switch
> > scatter-gather: off
> > tcp-segmentation-offload: off
> > udp-fragmentation-offload: off
> > generic-segmentation-offload: off
> > generic-receive-offload: off
> > large-receive-offload: off
> >=20
> > When I turn "tx-checksumming" back on, it fails again.
> > Though that is probably also just a side effect.
> >=20
> > I can provide tcpdumps if needed but they are no real help
> > since you can just see the kernel stops sending TCP packets.
> > (and the outgoing TCP packets are encrypted in ESP packets)
> >=20
> >=20
> > Any vague idea what might be the root cause?
> >=20
> > I also tried reverting commit 4d53eff48b5f03ce67f4f301d6acca1d2145c=
b7a
> > ("xfrm: Don't queue retransmitted packets if the original is still =
on the
> > host") but that didn't change the situation. In fact it wasn't even
> > triggered.
> >=20
> > Please CC: comments. Thanks.
> >=20
> > Best regards,
> > Thomas
>=20
> Regards,

Regards,
--=20
Wolfgang Walter
Studentenwerk M=C3=BCnchen
Anstalt des =C3=B6ffentlichen Rechts
