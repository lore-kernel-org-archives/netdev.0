From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] WAN: Remove no longer needed pvc_desc in FR code.
Date: Tue, 01 Jul 2008 14:42:07 +0200
Message-ID: <m3bq1hvkrk.fsf@maximus.localdomain>
References: <m3d4ly4ns2.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:39212 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933AbYGAMmO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 08:42:14 -0400
In-Reply-To: <m3d4ly4ns2.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Mon\, 30 Jun 2008 23\:26\:53 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove no longer needed struct pvc_desc in FR code.
Requires "WAN: convert drivers to use built-in netdev_stats" patch.

Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index cb1b415..109bab3 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -135,10 +135,6 @@ typedef struct pvc_device_struct {
 	}state;
 }pvc_device;
=20
-struct pvc_desc {
-	pvc_device *pvc;
-};
-
 struct frad_state {
 	fr_proto settings;
 	pvc_device *first_pvc;
@@ -178,10 +174,6 @@ static inline struct frad_state* state(hdlc_device=
 *hdlc)
 	return(struct frad_state *)(hdlc->state);
 }
=20
-static inline struct pvc_desc* pvcdev_to_desc(struct net_device *dev)
-{
-	return dev->priv;
-}
=20
 static inline pvc_device* find_pvc(hdlc_device *hdlc, u16 dlci)
 {
@@ -351,7 +343,7 @@ static int fr_hard_header(struct sk_buff **skb_p, u=
16 dlci)
=20
 static int pvc_open(struct net_device *dev)
 {
-	pvc_device *pvc =3D pvcdev_to_desc(dev)->pvc;
+	pvc_device *pvc =3D dev->priv;
=20
 	if ((pvc->frad->flags & IFF_UP) =3D=3D 0)
 		return -EIO;  /* Frad must be UP in order to activate PVC */
@@ -371,7 +363,7 @@ static int pvc_open(struct net_device *dev)
=20
 static int pvc_close(struct net_device *dev)
 {
-	pvc_device *pvc =3D pvcdev_to_desc(dev)->pvc;
+	pvc_device *pvc =3D dev->priv;
=20
 	if (--pvc->open_count =3D=3D 0) {
 		hdlc_device *hdlc =3D dev_to_hdlc(pvc->frad);
@@ -390,7 +382,7 @@ static int pvc_close(struct net_device *dev)
=20
 static int pvc_ioctl(struct net_device *dev, struct ifreq *ifr, int cm=
d)
 {
-	pvc_device *pvc =3D pvcdev_to_desc(dev)->pvc;
+	pvc_device *pvc =3D dev->priv;
 	fr_proto_pvc_info info;
=20
 	if (ifr->ifr_settings.type =3D=3D IF_GET_PROTO) {
@@ -418,7 +410,7 @@ static int pvc_ioctl(struct net_device *dev, struct=
 ifreq *ifr, int cmd)
=20
 static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	pvc_device *pvc =3D pvcdev_to_desc(dev)->pvc;
+	pvc_device *pvc =3D dev->priv;
=20
 	if (pvc->state.active) {
 		if (dev->type =3D=3D ARPHRD_ETHER) {
@@ -1079,7 +1071,7 @@ static void pvc_setup(struct net_device *dev)
 static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int =
type)
 {
 	hdlc_device *hdlc =3D dev_to_hdlc(frad);
-	pvc_device *pvc =3D NULL;
+	pvc_device *pvc;
 	struct net_device *dev;
 	int result, used;
=20
@@ -1095,10 +1087,9 @@ static int fr_add_pvc(struct net_device *frad, u=
nsigned int dlci, int type)
 	used =3D pvc_is_used(pvc);
=20
 	if (type =3D=3D ARPHRD_ETHER)
-		dev =3D alloc_netdev(sizeof(struct pvc_desc), "pvceth%d",
-				   ether_setup);
+		dev =3D alloc_netdev(0, "pvceth%d", ether_setup);
 	else
-		dev =3D alloc_netdev(sizeof(struct pvc_desc), "pvc%d", pvc_setup);
+		dev =3D alloc_netdev(0, "pvc%d", pvc_setup);
=20
 	if (!dev) {
 		printk(KERN_WARNING "%s: Memory squeeze on fr_pvc()\n",
@@ -1120,7 +1111,7 @@ static int fr_add_pvc(struct net_device *frad, un=
signed int dlci, int type)
 	dev->change_mtu =3D pvc_change_mtu;
 	dev->mtu =3D HDLC_MAX_MTU;
 	dev->tx_queue_len =3D 0;
-	pvcdev_to_desc(dev)->pvc =3D pvc;
+	dev->priv =3D pvc;
=20
 	result =3D dev_alloc_name(dev, dev->name);
 	if (result < 0) {
