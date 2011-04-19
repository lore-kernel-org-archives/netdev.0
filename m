From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] net: xen-netback: convert to hw_features
Date: Tue, 19 Apr 2011 14:17:53 +0100
Message-ID: <1303219073.5997.191.camel@zakaz.uk.xensource.com>
References: <20110419115612.C4ACA13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:33679 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755043Ab1DSNRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 09:17:55 -0400
In-Reply-To: <20110419115612.C4ACA13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-19 at 12:56 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

Thanks for beating me to this! However the prototype for
xenvif_fix_features is wrong (needs to take a net_device not a xenvif).

I fixed it with the following, I also moved the !can_sg MTU clamping
into a set_features hook (like we do with netfront). Am I right that
this pattern copes with changes to SG via ethtool etc better? I think
it's more future proof in any case.

NB: I'm having some issues with my test hardware at the moment so this
is reviewed by eye and compile tested only...

I'm also happy for this to be folded into the original with my
"Signed-off-/Acked-by Ian Campbell <ian.campbell@citrix.com>" if that i=
s
preferable.

Cheers,
Ian.
8<-----------------

net: xen-netback: correct prototype of xenvif_fix_features.

Also check MTU vs NETIF_F_SG in ndo_set_features hook to allow for
dynamic modification.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netb=
ack/interface.c
index fe25308..61757bd 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -165,9 +165,9 @@ static int xenvif_change_mtu(struct net_device *dev=
, int mtu)
 	return 0;
 }
=20
-static u32 xenvif_fix_features(struct xenvif *vif, u32 features)
+static u32 xenvif_fix_features(struct net_device *dev, u32 features)
 {
-	struct net_device *dev =3D vif->dev;
+	struct xenvif *vif =3D netdev_priv(dev);
=20
 	if (!vif->can_sg)
 		features &=3D ~NETIF_F_SG;
@@ -179,6 +179,16 @@ static u32 xenvif_fix_features(struct xenvif *vif,=
 u32 features)
 	return features;
 }
=20
+static int xenvif_set_features(struct net_device *dev, u32 features)
+{
+	if (!(features & NETIF_F_SG) && dev->mtu > ETH_DATA_LEN) {
+		netdev_info(dev, "Reducing MTU because no SG offload");
+		dev->mtu =3D ETH_DATA_LEN;
+	}
+
+	return 0;
+}
+
 static const struct xenvif_stat {
 	char name[ETH_GSTRING_LEN];
 	u16 offset;
@@ -237,6 +247,7 @@ static struct net_device_ops xenvif_netdev_ops =3D =
{
 	.ndo_stop	=3D xenvif_close,
 	.ndo_change_mtu	=3D xenvif_change_mtu,
 	.ndo_fix_features =3D xenvif_fix_features,
+	.ndo_set_features =3D xenvif_set_features,
 };
=20
 struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
@@ -329,8 +340,6 @@ int xenvif_connect(struct xenvif *vif, unsigned lon=
g tx_ring_ref,
 	rtnl_lock();
 	if (netif_running(vif->dev))
 		xenvif_up(vif);
-	if (!vif->can_sg && vif->dev->mtu > ETH_DATA_LEN)
-		dev_set_mtu(vif->dev, ETH_DATA_LEN);
 	netdev_update_features(vif->dev);
 	netif_carrier_on(vif->dev);
 	rtnl_unlock();


