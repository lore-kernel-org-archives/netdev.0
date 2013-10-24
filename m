From: =?UTF-8?B?RnJhbsOnb2lzIENhY2hlcmV1bA==?= <f.cachereul@alphalink.fr>
Subject: [RFC PATCH net-next] ppp: Allow ppp device connected to an l2tp session
 to change of namespace
Date: Thu, 24 Oct 2013 12:30:37 +0200
Message-ID: <5268F6CD.9070600@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>,
	James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:44611 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754629Ab3JXKaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 06:30:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove NETIF_F_NETNS_LOCAL flag from ppp device in ppp_connect_channel(=
)
if the device is connected to a l2tp session socket.
Restore the flag in ppp_disconnect_channel().

Signed-off-by: Fran=C3=A7ois CACHEREUL <f.cachereul@alphalink.fr>
---
I'm trying to get rid of this flag for ppp device connected to l2tp
session, it's seem to be safe to do it for as l2tp_ppp module hasn't an=
y
reference to the ppp device except to the device name. We can probably
do it for others modules but pppoe and pptp will require more work.

I remove the flag for l2tp in ppp_generic.c because I couldn't find a
place like a callback to do it in l2tp_ppp.c. The best will be to=20
remove the flag for all ppp devices.

=46ran=C3=A7ois

 drivers/net/ppp/ppp_generic.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generi=
c.c
index 72ff14b..7ccf2ae 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -54,6 +54,8 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
=20
+#include <linux/if_pppox.h>
+
 #define PPP_VERSION	"2.4.2"
=20
 /*
@@ -2861,6 +2863,7 @@ ppp_connect_channel(struct channel *pch, int unit=
)
 	struct ppp_net *pn;
 	int ret =3D -ENXIO;
 	int hdrlen;
+	struct sock *sk;
=20
 	pn =3D ppp_pernet(pch->chan_net);
=20
@@ -2883,6 +2886,13 @@ ppp_connect_channel(struct channel *pch, int uni=
t)
 	++ppp->n_channels;
 	pch->ppp =3D ppp;
 	atomic_inc(&ppp->file.refcnt);
+
+	/* allow ppp net device to be moved in another network namespace
+	 * if it's connected to an l2tp session */
+	sk =3D (struct sock *)pch->chan->private;
+	if (sk && sk->sk_protocol =3D=3D PX_PROTO_OL2TP)
+		ppp->dev->features &=3D ~NETIF_F_NETNS_LOCAL;
+
 	ppp_unlock(ppp);
 	ret =3D 0;
=20
@@ -2912,6 +2922,7 @@ ppp_disconnect_channel(struct channel *pch)
 		list_del(&pch->clist);
 		if (--ppp->n_channels =3D=3D 0)
 			wake_up_interruptible(&ppp->file.rwait);
+		ppp->dev->features |=3D NETIF_F_NETNS_LOCAL;
 		ppp_unlock(ppp);
 		if (atomic_dec_and_test(&ppp->file.refcnt))
 			ppp_destroy_interface(ppp);
--=20
1.7.10.4
