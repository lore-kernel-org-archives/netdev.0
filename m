From: Bernard Pidoux <bpidoux@free.fr>
Subject: [PATCH] [ROSE] zero length frame filtering in af_rose.c
Date: Sat, 22 Nov 2008 11:08:52 +0100
Message-ID: <200811221108.54242.bpidoux@free.fr>
Reply-To: f6bvp@amsat.org
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ralf DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>
To: Linux Netdev <netdev@vger.kernel.org>,
	Linux Hams <linux-hams@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g19.free.fr ([212.27.42.27]:58533 "EHLO smtp1-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753410AbYKVKLT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 05:11:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since changeset e79ad711a0108475c1b3a03815527e7237020b08 from =A0mainli=
ne.
=46rom: David S. Miller <davem@davemloft.net>
empty packet can be transmitted on connected socket for datagram protoc=
ols.

However, this patch broke a high level application using ROSE network=20
protocole with connected datagram.

Bulletin Board Stations perform bulletins forwarding between BBS statio=
ns by =A0
radio and ROSE network using a forward protocole.
Now, if for some reason, a sending buffer in the application software h=
appens=20
to be empty at a specific moment, ROSE relays an empty packet via unfil=
tred=20
packet socket.
When received, this ROSE packet introduces perturbations of BBS data=20
forwarding protocole, for the application protocole is waiting for some=
thing=20
else than an empty packet.
We agree that a more carefull programming of the application protocole =
would=20
avoid this situation and we are willing to debug it.
But, as an empty frame is no use, and does not have any meaning for ROS=
E=20
protocole, we may consider filtering zero length data both when sending=
 and=20
receiving socket data.

The proposed patch repairs BBS data exchange through ROSE network that =
were=20
broken since 2.6.22.11 kernel.

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
=A0net/rose/af_rose.c | =A0 10 ++++++++++
=A01 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 8a54cff..92af3a6 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1075,6 +1075,10 @@ static int rose_sendmsg(struct kiocb *iocb, stru=
ct=20
socket *sock,
=A0=A0=A0=A0=A0=A0=A0=A0unsigned char *asmptr;
=A0=A0=A0=A0=A0=A0=A0=A0int n, size, qbit =3D 0;
=A0
+=A0=A0=A0=A0=A0=A0=A0/* ROSE empty frame has no meaning : don't send *=
/
+=A0=A0=A0=A0=A0=A0=A0if (len =3D=3D 0)
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return 0;
+
=A0=A0=A0=A0=A0=A0=A0=A0if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR|MSG=
_CMSG_COMPAT))
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return -EINVAL;
=A0
@@ -1268,6 +1272,12 @@ static int rose_recvmsg(struct kiocb *iocb, stru=
ct=20
socket *sock,
=A0=A0=A0=A0=A0=A0=A0=A0skb_reset_transport_header(skb);
=A0=A0=A0=A0=A0=A0=A0=A0copied =A0 =A0 =3D skb->len;
=A0
+=A0=A0=A0=A0=A0=A0=A0/* ROSE empty frame has no meaning : ignore it */
+=A0=A0=A0=A0=A0=A0=A0if (copied =3D=3D 0) {
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0skb_free_datagram(sk, skb=
);
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return copied;
+=A0=A0=A0=A0=A0=A0=A0}
+
=A0=A0=A0=A0=A0=A0=A0=A0if (copied > size) {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0copied =3D size;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0msg->msg_flags |=3D MSG=
_TRUNC;
--=20
1.5.5
