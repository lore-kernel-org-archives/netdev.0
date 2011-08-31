From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH 7/7] bnx2x: expose HW RX VLAN stripping toggle
Date: Wed, 31 Aug 2011 18:07:53 +0300
Message-ID: <201108311807.53767.vladz@broadcom.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
 <201108311501.39936.vladz@broadcom.com> <20110831155324.7554d035@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1216 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756064Ab1HaPIi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 11:08:38 -0400
In-Reply-To: <20110831155324.7554d035@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 31 August 2011 16:53:24 Michal Schmidt wrote:
> On Wed, 31 Aug 2011 15:01:39 +0300 Vlad Zolotarov wrote:
> > On Tuesday 30 August 2011 22:30:11 Michal Schmidt wrote:
> > > > and then also in fp->flags.  Are the
> > > > fp->flags strictly mirroring hardware state (as in: there is no
> > > > way the states can differ in any point in time where the flags =
are
> > > > tested)?
> > >=20
> > > Yes. This is the purpose of the second mirroring of the flag.
> >=20
> > Michal,
> > although the above is true i'd say it's a bit of an overkill:
> > RX VLAN stripping is configured in a function level, so keeping it =
in
> > a per queue level is not needed.
> >=20
> > The problem u were trying to resolve (and u resolved it) was to
> > separate the RX_VLAN_ENABLED flag semantics into two: requested
> > feature and HW configured feature in order to further check the
> > second in the fast path, while setting the first one in the
> > set_features(). Then the second lag is updated according to the fir=
st
> > one during the loading of the function (bnx2x_nic_load()).
> >=20
> > Therefore it would be enough to just add those two flags in the
> > function (bp) level keeping the rest of your patch as it is. This
> > would also cancel the need for a patch 6.
>=20
> Alright, I will remove the per-fp flag and move it to bp.
>=20
> I will also apply the cheat suggested by Micha=C5=82, so that:
>  - dev->features & NETIF_F_HW_VLAN_RX is the requested state
>  - bp->flags & RX_VLAN_STRIP_FLAG is the HW configured state
> =3D> Only one new bp flag needed, not two.
>=20
> BTW, Micha=C5=82's cheat should apply to TPA_ENABLE_FLAG as well - it=
 only
> mirrors NETIF_F_LRO. But for TPA the HW configured state is really
> per-queue (fp->disable_tpa). I will remove TPA_ENABLE_FLAG unless you
> object to Micha=C5=82's "cheat".

I agree the TPA_ENABLE_FLAG may and should be removed.
However I didn=E2=80=99t like the idea of relying on the current implem=
entation=20
of the calling function (__netdev_update_features()). If u want to chan=
ge=20
the implementation the way we rely on the dev->features in the=20
ndo_set_features() flow, which is a semantics change, u'd rather change=
=20
the __netdev_update_features() so that it sets the dev->features before=
=20
ndo_set_features() call and restores it in case of a failure. Something=
 like this:

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0a7f619..a5f6d3e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -943,8 +943,7 @@ struct net_device_ops {
                                                 struct net_device *sla=
ve_dev);
        u32                     (*ndo_fix_features)(struct net_device *=
dev,
                                                    u32 features);
-       int                     (*ndo_set_features)(struct net_device *=
dev,
-                                                   u32 features);
+       int                     (*ndo_set_features)(struct net_device *=
dev);
 };
=20
 /*
diff --git a/net/core/dev.c b/net/core/dev.c
index b2e262e..474e539 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5321,7 +5321,7 @@ static u32 netdev_fix_features(struct net_device =
*dev, u32 features)
=20
 int __netdev_update_features(struct net_device *dev)
 {
-       u32 features;
+       u32 features, old_features;
        int err =3D 0;
=20
        ASSERT_RTNL();
@@ -5340,19 +5340,23 @@ int __netdev_update_features(struct net_device =
*dev)
        netdev_dbg(dev, "Features changed: 0x%08x -> 0x%08x\n",
                dev->features, features);
=20
+       /* Remember the original features and set the new ones */
+       old_features =3D dev->features;
+       dev->features =3D features;
+
        if (dev->netdev_ops->ndo_set_features)
-               err =3D dev->netdev_ops->ndo_set_features(dev, features=
);
+               err =3D dev->netdev_ops->ndo_set_features(dev);
=20
        if (unlikely(err < 0)) {
+               /* Restore the original features */
+               dev->features =3D old_features;
+
                netdev_err(dev,
                        "set_features() failed (%d); wanted 0x%08x, lef=
t 0x%08x\n",
                        err, features, dev->features);
                return -1;
        }
=20
-       if (!err)
-               dev->features =3D features;
-
        return 1;
 }

However, this would involve updating all other L2 drivers that implemen=
t ndo_set_features().

Pls., comment.

thanks,
vlad

>=20
> Thanks,
> Michal
