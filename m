From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 15/21] orinoco: delay FID allocation after firmware initialization
Date: Fri, 07 Apr 2006 04:10:49 -0400
Message-ID: <20060407081049.16107.42123.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

This is needed to identify the card before possible allocation problems,
so that the user at least can report the firmware version that fails.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco.c |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoc=
o.c
index 80cf6fb..d4c13ff 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -1345,15 +1345,11 @@ int __orinoco_down(struct net_device *de
 	return 0;
 }
=20
-int orinoco_reinit_firmware(struct net_device *dev)
+static int orinoco_allocate_fid(struct net_device *dev)
 {
 	struct orinoco_private *priv =3D netdev_priv(dev);
 	struct hermes *hw =3D &priv->hw;
 	int err;
-
-	err =3D hermes_init(hw);
-	if (err)
-		return err;
=20
 	err =3D hermes_allocate(hw, priv->nicbuf_size, &priv->txfid);
 	if (err =3D=3D -EIO && priv->nicbuf_size > TX_NICBUF_SIZE_BUG) {
@@ -1372,7 +1368,20 @@ int orinoco_reinit_firmware(struct net_d
=20
 	return err;
 }
+
+int orinoco_reinit_firmware(struct net_device *dev)
+{
+	struct orinoco_private *priv =3D netdev_priv(dev);
+	struct hermes *hw =3D &priv->hw;
+	int err;
=20
+	err =3D hermes_init(hw);
+	if (!err)
+		err =3D orinoco_allocate_fid(dev);
+
+	return err;
+}
+
 static int __orinoco_hw_set_bitrate(struct orinoco_private *priv)
 {
 	hermes_t *hw =3D &priv->hw;
@@ -2224,7 +2233,7 @@ static int orinoco_init(struct net_devic
 	priv->nicbuf_size =3D IEEE80211_FRAME_LEN + ETH_HLEN;
=20
 	/* Initialize the firmware */
-	err =3D orinoco_reinit_firmware(dev);
+	err =3D hermes_init(hw);
 	if (err !=3D 0) {
 		printk(KERN_ERR "%s: failed to initialize firmware (err =3D %d)\n",
 		       dev->name, err);
@@ -2281,6 +2290,13 @@ static int orinoco_init(struct net_devic
 	priv->nick[len] =3D '\0';
=20
 	printk(KERN_DEBUG "%s: Station name \"%s\"\n", dev->name, priv->nick);
+
+	err =3D orinoco_allocate_fid(dev);
+	if (err) {
+		printk(KERN_ERR "%s: failed to allocate NIC buffer!\n",
+		       dev->name);
+		goto out;
+	}
=20
 	/* Get allowed channels */
 	err =3D hermes_read_wordrec(hw, USER_BAP, HERMES_RID_CHANNELLIST,



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
