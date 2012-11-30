From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 09/17] atm: Add release_cb() callback to vcc
Date: Fri, 30 Nov 2012 00:35:28 +0000
Message-ID: <1354235736-26833-10-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37538 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755292Ab2K3Agn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:43 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Woodhouse <David.Woodhouse@intel.com>

The immediate use case for this is that it will allow us to ensure that=
 a
pppoatm queue is woken after it has to drop a packet due to the sock be=
ing
locked.

Note that 'release_cb' is called when the socket is *unlocked*. This is
not to be confused with vcc_release() =E2=80=94 which probably ought to=
 be called
vcc_close().

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
Acked-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 include/linux/atmdev.h |  1 +
 net/atm/common.c       | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 72db2af..c1da539 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -99,6 +99,7 @@ struct atm_vcc {
 	struct atm_dev	*dev;		/* device back pointer */
 	struct atm_qos	qos;		/* QOS */
 	struct atm_sap	sap;		/* SAP */
+	void (*release_cb)(struct atm_vcc *vcc); /* release_sock callback */
 	void (*push)(struct atm_vcc *vcc,struct sk_buff *skb);
 	void (*pop)(struct atm_vcc *vcc,struct sk_buff *skb); /* optional */
 	int (*push_oam)(struct atm_vcc *vcc,void *cell);
diff --git a/net/atm/common.c b/net/atm/common.c
index 2421664..806fc0a 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -126,10 +126,19 @@ static void vcc_write_space(struct sock *sk)
 	rcu_read_unlock();
 }
=20
+static void vcc_release_cb(struct sock *sk)
+{
+	struct atm_vcc *vcc =3D atm_sk(sk);
+
+	if (vcc->release_cb)
+		vcc->release_cb(vcc);
+}
+
 static struct proto vcc_proto =3D {
 	.name	  =3D "VCC",
 	.owner	  =3D THIS_MODULE,
 	.obj_size =3D sizeof(struct atm_vcc),
+	.release_cb =3D vcc_release_cb,
 };
=20
 int vcc_create(struct net *net, struct socket *sock, int protocol, int=
 family)
@@ -158,6 +167,7 @@ int vcc_create(struct net *net, struct socket *sock=
, int protocol, int family)
 	vcc->pop =3D NULL;
 	vcc->owner =3D NULL;
 	vcc->push_oam =3D NULL;
+	vcc->release_cb =3D NULL;
 	vcc->vpi =3D vcc->vci =3D 0; /* no VCI/VPI yet */
 	vcc->atm_options =3D vcc->aal_options =3D 0;
 	sk->sk_destruct =3D vcc_sock_destruct;
--=20
1.8.0
