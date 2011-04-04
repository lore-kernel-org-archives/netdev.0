From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH RESEND] net: convert xen-netfront to
	hw_features
Date: Mon, 4 Apr 2011 13:29:19 +0100
Message-ID: <1301920159.23887.96.camel@zakaz.uk.xensource.com>
References: <20110331110136.03A1A13A6A@rere.qmqm.pl>
	<20110401.205455.70198735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <20110401.205455.70198735.davem@davemloft.net>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Sat, 2011-04-02 at 04:54 +0100, David Miller wrote:
> From: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> Date: Thu, 31 Mar 2011 13:01:35 +0200 (CEST)
>=20
> > Not tested in any way. The original code for offload setting seems br=
oken
> > as it resets the features on every netback reconnect.
> >=20
> > This will set GSO_ROBUST at device creation time (earlier than connec=
t time).
> >=20
> > RX checksum offload is forced on - so advertise as it is.
> >=20
> > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
>=20
> Applied.

Thanks, but unfortunately the patch results in the features all being
disabled by default, since they are not set in the initial dev->features
and the initial dev->wanted_features is based on features & hw_features.
The ndo_fix_features hook only clears features and doesn't add new
features (nor should it AFAICT).

Features cannot be negotiated with the backend until xennet_connect().
The carrier is not enabled until the end of that function, therefore I
think it is safe to start with a full set of features in dev->features
and rely on the call to netdev_update_features() in xennet_connect() to
clear those which turn out to be unavailable.

The following works for me, I guess the alternative is for
xennet_connect() to expand dev->features based on what it detects? Or is
there a mechanism for a driver to inform the core that a new hardware
feature has become available (I doubt that really happens on physical
h/w so I guess not).

Ian.

8<-----------------

>From 0b56469abe56efae415b4603ef508ce9aec0e4c1 Mon Sep 17 00:00:00 2001
From: Ian Campbell <ian.campbell@citrix.com>
Date: Mon, 4 Apr 2011 10:58:50 +0100
Subject: [PATCH] xen: netfront: assume all hw features are available unti=
l backend connection setup

We need to assume that all features will be available when registering th=
e
netdev otherwise they are ommitted from the initial set of
dev->wanted_features. When we connect to the backed we reduce the set as
necessary due to the call to netdev_update_features() in xennet_connect()=
.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: mirq-linux@rere.qmqm.pl
Cc: netdev@vger.kernel.org <netdev@vger.kernel.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: konrad.wilk@oracle.com
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: xen-devel@lists.xensource.com
---
 drivers/net/xen-netfront.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 0cfe4cc..db9a763 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1251,6 +1251,14 @@ static struct net_device * __devinit xennet_create=
_dev(struct xenbus_device *dev
 				  NETIF_F_GSO_ROBUST;
 	netdev->hw_features	=3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
=20
+	/*
+         * Assume that all hw features are available for now. This set
+         * will be adjusted by the call to netdev_update_features() in
+         * xennet_connect() which is the earliest point where we can
+         * negotiate with the backend regarding supported features.
+         */
+	netdev->features |=3D netdev->hw_features;
+
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
 	SET_NETDEV_DEV(netdev, &dev->dev);
=20
--=20
1.7.2.5
