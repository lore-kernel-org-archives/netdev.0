From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [GIT] Networking
Date: Thu, 02 May 2013 11:06:42 +0200
Message-ID: <87d2t9bvj1.fsf@nemi.mork.no>
References: <CA+55aFxoP1vybnqdDwGmd-m0j=x=KDm7GHV6J1i8wGOaU0=5qw@mail.gmail.com>
	<20130502.024552.1513488878160820332.davem@davemloft.net>
	<20130502070256.GA29502@macbook.localnet>
	<20130502.041625.412316202038784117.davem@davemloft.net>
	<20130502083619.GA22010@macbook.localnet>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	hayeswang@realtek.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130502083619.GA22010@macbook.localnet> (Patrick McHardy's
	message of "Thu, 2 May 2013 10:36:49 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Patrick McHardy <kaber@trash.net> writes:
> On Thu, May 02, 2013 at 04:16:25AM -0400, David Miller wrote:
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Thu, 2 May 2013 09:03:37 +0200
>>=20
>> > I'll also have a look at this.
>>=20
>> By the mere existence of /sys/devices/${DEV_PATH}/net/${netdev_name}/fla=
gs
>> we have to preserve the bit layout.
>>=20
>> So Linus was right.
>>=20
>> So network manager is probably reading that flags sysfs file and
>> interpreting it.
>
> Right, that seems plausible.=20
>
>> I'll fix the layout to how it was before.
>
> I also found one spot in net/core/dev.c which was using an int for the
> features. Patch attached.

And a couple more attached.

I am also wondering about the consequences of the
ETHTOOL_DEV_FEATURE_WORDS calculation in ethtool.c.  Adding the new
netdev features will make it go from 1 to 2:

#define ETHTOOL_DEV_FEATURE_WORDS	((NETDEV_FEATURE_COUNT + 31) / 32)


But this constant seems to be part of the userspace API AFAICS, so it
cannot just change like that:

static int ethtool_set_features(struct net_device *dev, void __user *userad=
dr)
{
	struct ethtool_sfeatures cmd;
	struct ethtool_set_features_block features[ETHTOOL_DEV_FEATURE_WORDS];
	netdev_features_t wanted =3D 0, valid =3D 0;
	int i, ret =3D 0;

	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
		return -EFAULT;
	useraddr +=3D sizeof(cmd);

	if (cmd.size !=3D ETHTOOL_DEV_FEATURE_WORDS)
		return -EINVAL;

..


Is this correctly analyzed?  If so, then I have no clue how to fix
that...



Bj=C3=B8rn



--=-=-=
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: inline;
 filename=0001-net-vlan-ethtool-netdev_features_t-is-more-than-32-b.patch
Content-Transfer-Encoding: quoted-printable

>From d957cf339bf625869c39d852ac6733ef597ecef9 Mon Sep 17 00:00:00 2001
From: =3D?UTF-8?q?Bj=3DC3=3DB8rn=3D20Mork?=3D <bjorn@mork.no>
Date: Thu, 2 May 2013 10:37:05 +0200
Subject: [PATCH] net: vlan,ethtool: netdev_features_t is more than 32 bit
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 net/8021q/vlan_dev.c |    2 +-
 net/core/ethtool.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 8af5085..3a8c8fd 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -628,7 +628,7 @@ static netdev_features_t vlan_dev_fix_features(struct n=
et_device *dev,
 	netdev_features_t features)
 {
 	struct net_device *real_dev =3D vlan_dev_priv(dev)->real_dev;
-	u32 old_features =3D features;
+	netdev_features_t old_features =3D features;
=20
 	features &=3D real_dev->vlan_features;
 	features |=3D NETIF_F_RXCSUM;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 5a934ef..22efdaa 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1421,7 +1421,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	void __user *useraddr =3D ifr->ifr_data;
 	u32 ethcmd;
 	int rc;
-	u32 old_features;
+	netdev_features_t old_features;
=20
 	if (!dev || !netif_device_present(dev))
 		return -ENODEV;
--=20
1.7.10.4


--=-=-=--
