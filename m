From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: segfault after VLAN change
Date: Wed, 02 Jul 2014 01:33:48 -0700
Message-ID: <1404290028.23797.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <42408b4f154d434d9838b83ae2dc15db@BL2PR03MB545.namprd03.prod.outlook.com>
	 <87simk1bhu.fsf@nemi.mork.no>
	 <1404289423.23797.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	Li RongQing <roy.qing.li@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:47350 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbaGBIdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 04:33:52 -0400
Received: by mail-wi0-f182.google.com with SMTP id bs8so23545wib.3
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 01:33:51 -0700 (PDT)
In-Reply-To: <1404289423.23797.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-07-02 at 01:23 -0700, Eric Dumazet wrote:
> On Wed, 2014-07-02 at 09:11 +0200, Bj=C3=B8rn Mork wrote:
> > Madalin-Cristian Bucur <madalin.bucur@freescale.com> writes:
> >=20
> > > Hello,
> > >
> > > I've discovered that the commit:
> > >
> > >     commit 5a4ae5f6e7d4b2b5a9b8981d513345053e40b6ac
> > >     Author: Li RongQing <roy.qing.li@gmail.com>
> > >     Date:   Mon Apr 21 19:49:08 2014 +0800
> > >
> > >     vlan: unnecessary to check if vlan_pcpu_stats is NULL
> > >
> > >     if allocating memory for vlan_pcpu_stats failed, the device c=
an not be operated
> > >
> > >     Signed-off-by:=20
> > >     Cc: Eric Dumazet <edumazet@google.com>
> > >     Signed-off-by: David S. Miller <davem@davemloft.net>
> > >
> > > is causing a segfault when removing vlan on a e1000 device (repro=
duces with other devices as well).
> > > Re-adding the check or reverting the patch removes the issue (log=
 below).
> >=20
> >=20
> > Yes, that commit should be reverted.
>=20
> Maybe not.
>=20
> >=20
> > The commit message makes it clear that only allocation failures wer=
e
> > considered, while a simple grep reveals that there at least one sit=
e
> > where that field is explicitly NULLed:
> >=20
> > bjorn@nemi:/usr/local/src/git/linux$ git grep vlan_pcpu_stats net/8=
021q/
> > net/8021q/vlan_core.c:  struct vlan_pcpu_stats *rx_stats;
> > net/8021q/vlan_core.c:  rx_stats =3D this_cpu_ptr(vlan_dev_priv(vla=
n_dev)->vlan_pcpu_stats);
> > net/8021q/vlan_dev.c:           struct vlan_pcpu_stats *stats;
> > net/8021q/vlan_dev.c:           stats =3D this_cpu_ptr(vlan->vlan_p=
cpu_stats);
> > net/8021q/vlan_dev.c:           this_cpu_inc(vlan->vlan_pcpu_stats-=
>tx_dropped);
> > net/8021q/vlan_dev.c:   vlan_dev_priv(dev)->vlan_pcpu_stats =3D net=
dev_alloc_pcpu_stats(struct vlan_pcpu_stats);
> > net/8021q/vlan_dev.c:   if (!vlan_dev_priv(dev)->vlan_pcpu_stats)
> > net/8021q/vlan_dev.c:   free_percpu(vlan->vlan_pcpu_stats);
> > net/8021q/vlan_dev.c:   vlan->vlan_pcpu_stats =3D NULL;
> > net/8021q/vlan_dev.c:   struct vlan_pcpu_stats *p;
> > net/8021q/vlan_dev.c:           p =3D per_cpu_ptr(vlan_dev_priv(dev=
)->vlan_pcpu_stats, i);
> >=20
> >=20
> > Without looking further it seems likely that this is done during
> > teardown, making the original NULL check necessary.
>=20
> Then the teardown is not properly done.
>=20
> Sure a 'revert' helps, but the real bug should be fixed.
>=20
> The freeing of the percpu structure should happen from
> dev->destructor(), not from ndo_uninit
>=20

Please try the following patch :

 net/8021q/vlan_dev.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index ad2ac3c00398..dd11f612e03e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -627,8 +627,6 @@ static void vlan_dev_uninit(struct net_device *dev)
 	struct vlan_dev_priv *vlan =3D vlan_dev_priv(dev);
 	int i;
=20
-	free_percpu(vlan->vlan_pcpu_stats);
-	vlan->vlan_pcpu_stats =3D NULL;
 	for (i =3D 0; i < ARRAY_SIZE(vlan->egress_priority_map); i++) {
 		while ((pm =3D vlan->egress_priority_map[i]) !=3D NULL) {
 			vlan->egress_priority_map[i] =3D pm->next;
@@ -785,6 +783,15 @@ static const struct net_device_ops vlan_netdev_ops=
 =3D {
 	.ndo_get_lock_subclass  =3D vlan_dev_get_lock_subclass,
 };
=20
+static void vlan_dev_free(struct net_device *dev)
+{
+	struct vlan_dev_priv *vlan =3D vlan_dev_priv(dev);
+
+	free_percpu(vlan->vlan_pcpu_stats);
+	vlan->vlan_pcpu_stats =3D NULL;
+	free_netdev(dev);
+}
+
 void vlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -794,7 +801,7 @@ void vlan_setup(struct net_device *dev)
 	dev->tx_queue_len	=3D 0;
=20
 	dev->netdev_ops		=3D &vlan_netdev_ops;
-	dev->destructor		=3D free_netdev;
+	dev->destructor		=3D vlan_dev_free;
 	dev->ethtool_ops	=3D &vlan_ethtool_ops;
=20
 	memset(dev->broadcast, 0, ETH_ALEN);
