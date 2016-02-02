From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH 1/2] ethtool: add dynamic flag to ETHTOOL_{GS}RXFH commands
Date: Tue,  2 Feb 2016 15:22:06 -0800
Message-ID: <1454455328-706-2-git-send-email-jacob.e.keller@intel.com>
References: <1454455328-706-1-git-send-email-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jacob Keller <jacob.e.keller@intel.com>, Lendacky@vger.kernel.org,
	Thomas <Thomas.Lendacky@amd.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Kalesh AP <kalesh.purayil@emulex.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Amir Vadai <amirv@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Alexander Duyck <aduyck@mirantis.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52353 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753543AbcBBXWU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 18:22:20 -0500
In-Reply-To: <1454455328-706-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethtool supports a few operations for modifying and controlling
a device's RSS table. Sometimes, changes in other features of the devic=
e
may require (or desire) changes to the RSS table. Currently there is no
method to indicate to the driver whether the current RSS table settings
should be maintained or overridden.

A simple example of this is for when the number of receive queues is
changed, there are two possibilities. First, the number of queues is
decreased. This must result in a reprogramming of the RSS table since i=
t
will no longer match correctly and may attempt to assign traffic to
a queue which is now disabled. In this case drivers have a clear
indication of what to do.

The second case, is when the number of queues has increased. In this
case, the current RSS table may be preserved. However, doing so would
result in the new queues being unused for RSS. But if the driver choose=
s
to destroy the RSS configuration it may result in unwanted behavior as
now the user's configured changes are lost.

This patch attempts to resolve this (and other similar) issues by
indicating a new flag "dynamic" which can be set by the user when
calling the ethtool interface.

This flag indicates to the driver that it may overwrite settings in the
RSS table. If false, it indicates the driver should do what it can to
preserve the RSS table changes requested by the user. That is, for case=
s
where it can preserve the table it must. If the value is set true, it
means the driver may or may not apply the current settings and is free
to change the values as necessary. The current default is set to false,
as this is how most drivers appear to behave today.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Cc: Lendacky, Thomas <Thomas.Lendacky@amd.com>
Cc: Yuval Mintz <yuvalmin@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
Cc: Matt Carlson <mcarlson@broadcom.com>
Cc: Sunil Goutham <sgoutham@cavium.com>
Cc: Hariprasad Shenai <hariprasad@chelsio.com>
Cc: Govindarajulu Varadarajan <_govind@gmx.com>
Cc: Kalesh AP <kalesh.purayil@emulex.com>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Shannon Nelson <shannon.nelson@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Amir Vadai <amirv@mellanox.com>
Cc: Achiad Shochat <achiad@mellanox.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Cc: Alexander Duyck <aduyck@mirantis.com>

---
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c       |  7 ++++--
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  7 ++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c  |  5 +++-
 drivers/net/ethernet/broadcom/tg3.c                |  8 +++++--
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |  7 ++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c |  7 ++++--
 drivers/net/ethernet/cisco/enic/enic_ethtool.c     |  7 ++++--
 drivers/net/ethernet/emulex/benet/be_ethtool.c     |  7 ++++--
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |  8 +++++--
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c   |  7 ++++--
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  7 ++++--
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  6 +++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |  6 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |  7 ++++--
 drivers/net/ethernet/intel/ixgbevf/ethtool.c       |  5 +++-
 drivers/net/ethernet/marvell/mvneta.c              |  8 +++++--
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |  7 ++++--
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  7 ++++--
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  7 ++++--
 drivers/net/ethernet/sfc/ethtool.c                 |  7 ++++--
 include/linux/ethtool.h                            |  4 ++--
 include/uapi/linux/ethtool.h                       |  8 ++++++-
 net/core/ethtool.c                                 | 27 +++++++++++++-=
--------
 23 files changed, 124 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net=
/ethernet/amd/xgbe/xgbe-ethtool.c
index 6040293db9c1..4eecd225db7c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -509,11 +509,14 @@ static u32 xgbe_get_rxfh_indir_size(struct net_de=
vice *netdev)
 }
=20
 static int xgbe_get_rxfh(struct net_device *netdev, u32 *indir, u8 *ke=
y,
-			 u8 *hfunc)
+			 u8 *hfunc, u8 *dynamic)
 {
 	struct xgbe_prv_data *pdata =3D netdev_priv(netdev);
 	unsigned int i;
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (indir) {
 		for (i =3D 0; i < ARRAY_SIZE(pdata->rss_table); i++)
 			indir[i] =3D XGMAC_GET_BITS(pdata->rss_table[i],
@@ -530,7 +533,7 @@ static int xgbe_get_rxfh(struct net_device *netdev,=
 u32 *indir, u8 *key,
 }
=20
 static int xgbe_set_rxfh(struct net_device *netdev, const u32 *indir,
-			 const u8 *key, const u8 hfunc)
+			 const u8 *key, const u8 hfunc, const u8 dynamic)
 {
 	struct xgbe_prv_data *pdata =3D netdev_priv(netdev);
 	struct xgbe_hw_if *hw_if =3D &pdata->hw_if;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/driv=
ers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 820b7e04bb5f..b346ac8d2b49 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -3417,12 +3417,15 @@ static u32 bnx2x_get_rxfh_indir_size(struct net=
_device *dev)
 }
=20
 static int bnx2x_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
-			  u8 *hfunc)
+			  u8 *hfunc, u8 *dynamic)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
 	u8 ind_table[T_ETH_INDIRECTION_TABLE_SIZE] =3D {0};
 	size_t i;
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (hfunc)
 		*hfunc =3D ETH_RSS_HASH_TOP;
 	if (!indir)
@@ -3447,7 +3450,7 @@ static int bnx2x_get_rxfh(struct net_device *dev,=
 u32 *indir, u8 *key,
 }
=20
 static int bnx2x_set_rxfh(struct net_device *dev, const u32 *indir,
-			  const u8 *key, const u8 hfunc)
+			  const u8 *key, const u8 hfunc, const u8 dynamic)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
 	size_t i;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/driver=
s/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 922b898e7a32..7a1d97319e0a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -437,12 +437,15 @@ static u32 bnxt_get_rxfh_key_size(struct net_devi=
ce *dev)
 }
=20
 static int bnxt_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
-			 u8 *hfunc)
+			 u8 *hfunc, u8 *dynamic)
 {
 	struct bnxt *bp =3D netdev_priv(dev);
 	struct bnxt_vnic_info *vnic =3D &bp->vnic_info[0];
 	int i =3D 0;
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (hfunc)
 		*hfunc =3D ETH_RSS_HASH_TOP;
=20
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet=
/broadcom/tg3.c
index 9293675df7ba..460fbadc009d 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12561,11 +12561,15 @@ static u32 tg3_get_rxfh_indir_size(struct net=
_device *dev)
 	return size;
 }
=20
-static int tg3_get_rxfh(struct net_device *dev, u32 *indir, u8 *key, u=
8 *hfunc)
+static int tg3_get_rxfh(struct net_device *dev, u32 *indir, u8 *key, u=
8 *hfunc,
+			u8 *dynamic)
 {
 	struct tg3 *tp =3D netdev_priv(dev);
 	int i;
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (hfunc)
 		*hfunc =3D ETH_RSS_HASH_TOP;
 	if (!indir)
@@ -12578,7 +12582,7 @@ static int tg3_get_rxfh(struct net_device *dev,=
 u32 *indir, u8 *key, u8 *hfunc)
 }
=20
 static int tg3_set_rxfh(struct net_device *dev, const u32 *indir, cons=
t u8 *key,
-			const u8 hfunc)
+			const u8 hfunc, const u8 dynamic)
 {
 	struct tg3 *tp =3D netdev_priv(dev);
 	size_t i;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c b/driv=
ers/net/ethernet/cavium/thunder/nicvf_ethtool.c
index a12b2e38cf61..781e456ae5ba 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
@@ -560,12 +560,15 @@ static u32 nicvf_get_rxfh_indir_size(struct net_d=
evice *dev)
 }
=20
 static int nicvf_get_rxfh(struct net_device *dev, u32 *indir, u8 *hkey=
,
-			  u8 *hfunc)
+			  u8 *hfunc, u8 *dynamic)
 {
 	struct nicvf *nic =3D netdev_priv(dev);
 	struct nicvf_rss_info *rss =3D &nic->rss_info;
 	int idx;
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (indir) {
 		for (idx =3D 0; idx < rss->rss_size; idx++)
 			indir[idx] =3D rss->ind_tbl[idx];
@@ -581,7 +584,7 @@ static int nicvf_get_rxfh(struct net_device *dev, u=
32 *indir, u8 *hkey,
 }
=20
 static int nicvf_set_rxfh(struct net_device *dev, const u32 *indir,
-			  const u8 *hkey, u8 hfunc)
+			  const u8 *hkey, u8 hfunc, const u8 dynamic)
 {
 	struct nicvf *nic =3D netdev_priv(dev);
 	struct nicvf_rss_info *rss =3D &nic->rss_info;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drive=
rs/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 7a0b92b2f73c..b46dbbd6d914 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -989,11 +989,14 @@ static u32 get_rss_table_size(struct net_device *=
dev)
 	return pi->rss_size;
 }
=20
-static int get_rss_table(struct net_device *dev, u32 *p, u8 *key, u8 *=
hfunc)
+static int get_rss_table(struct net_device *dev, u32 *p, u8 *key, u8 *=
hfunc,
+			 u8 *dynamic)
 {
 	const struct port_info *pi =3D netdev_priv(dev);
 	unsigned int n =3D pi->rss_size;
=20
+	if (dynamic)
+		*dynamic =3D false;
 	if (hfunc)
 		*hfunc =3D ETH_RSS_HASH_TOP;
 	if (!p)
@@ -1004,7 +1007,7 @@ static int get_rss_table(struct net_device *dev, =
u32 *p, u8 *key, u8 *hfunc)
 }
=20
 static int set_rss_table(struct net_device *dev, const u32 *p, const u=
8 *key,
-			 const u8 hfunc)
+			 const u8 hfunc, const u8 dynamic)
 {
 	unsigned int i;
 	struct port_info *pi =3D netdev_priv(dev);
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/n=
et/ethernet/cisco/enic/enic_ethtool.c
index f44a39c40642..aba7555d703d 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -471,10 +471,13 @@ static u32 enic_get_rxfh_key_size(struct net_devi=
ce *netdev)
 }
=20
 static int enic_get_rxfh(struct net_device *netdev, u32 *indir, u8 *hk=
ey,
-			 u8 *hfunc)
+			 u8 *hfunc, u8 *dynamic)
 {
 	struct enic *enic =3D netdev_priv(netdev);
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (hkey)
 		memcpy(hkey, enic->rss_key, ENIC_RSS_LEN);
=20
@@ -485,7 +488,7 @@ static int enic_get_rxfh(struct net_device *netdev,=
 u32 *indir, u8 *hkey,
 }
=20
 static int enic_set_rxfh(struct net_device *netdev, const u32 *indir,
-			 const u8 *hkey, const u8 hfunc)
+			 const u8 *hkey, const u8 hfunc, const u8 dynamic)
 {
 	struct enic *enic =3D netdev_priv(netdev);
=20
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/n=
et/ethernet/emulex/benet/be_ethtool.c
index a19ac441336f..49c089ec2a77 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -1200,12 +1200,15 @@ static u32 be_get_rxfh_key_size(struct net_devi=
ce *netdev)
 }
=20
 static int be_get_rxfh(struct net_device *netdev, u32 *indir, u8 *hkey=
,
-		       u8 *hfunc)
+		       u8 *hfunc, u8 *dynamic)
 {
 	struct be_adapter *adapter =3D netdev_priv(netdev);
 	int i;
 	struct rss_info *rss =3D &adapter->rss_info;
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (indir) {
 		for (i =3D 0; i < RSS_INDIR_TABLE_LEN; i++)
 			indir[i] =3D rss->rss_queue[i];
@@ -1221,7 +1224,7 @@ static int be_get_rxfh(struct net_device *netdev,=
 u32 *indir, u8 *hkey,
 }
=20
 static int be_set_rxfh(struct net_device *netdev, const u32 *indir,
-		       const u8 *hkey, const u8 hfunc)
+		       const u8 *hkey, const u8 hfunc, const u8 dynamic)
 {
 	int rc =3D 0, i, j;
 	struct be_adapter *adapter =3D netdev_priv(netdev);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers=
/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3df22840fcd1..6b99cdedd90a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -1194,12 +1194,16 @@ hns_get_rss_indir_size(struct net_device *netde=
v)
 }
=20
 static int
-hns_get_rss(struct net_device *netdev, u32 *indir, u8 *key, u8 *hfunc)
+hns_get_rss(struct net_device *netdev, u32 *indir, u8 *key, u8 *hfunc,
+	    u8 *dynamic)
 {
 	struct hns_nic_priv *priv =3D netdev_priv(netdev);
 	struct hnae_ae_ops *ops;
 	int ret;
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
 			   "RSS feature is not supported on this hardware\n");
@@ -1218,7 +1222,7 @@ hns_get_rss(struct net_device *netdev, u32 *indir=
, u8 *key, u8 *hfunc)
=20
 static int
 hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key=
,
-	    const u8 hfunc)
+	    const u8 hfunc, const u8 dynamic)
 {
 	struct hns_nic_priv *priv =3D netdev_priv(netdev);
 	struct hnae_ae_ops *ops;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers=
/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 6a9f9886cb98..af11c4c1b256 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -1091,7 +1091,7 @@ static u32 fm10k_get_rssrk_size(struct net_device=
 __always_unused *netdev)
 }
=20
 static int fm10k_get_rssh(struct net_device *netdev, u32 *indir, u8 *k=
ey,
-			  u8 *hfunc)
+			  u8 *hfunc, u8 *dynamic)
 {
 	struct fm10k_intfc *interface =3D netdev_priv(netdev);
 	int i, err;
@@ -1099,6 +1099,9 @@ static int fm10k_get_rssh(struct net_device *netd=
ev, u32 *indir, u8 *key,
 	if (hfunc)
 		*hfunc =3D ETH_RSS_HASH_TOP;
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	err =3D fm10k_get_reta(netdev, indir);
 	if (err || !key)
 		return err;
@@ -1110,7 +1113,7 @@ static int fm10k_get_rssh(struct net_device *netd=
ev, u32 *indir, u8 *key,
 }
=20
 static int fm10k_set_rssh(struct net_device *netdev, const u32 *indir,
-			  const u8 *key, const u8 hfunc)
+			  const u8 *key, const u8 hfunc, const u8 dynamic)
 {
 	struct fm10k_intfc *interface =3D netdev_priv(netdev);
 	struct fm10k_hw *hw =3D &interface->hw;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/n=
et/ethernet/intel/i40e/i40e_ethtool.c
index 54d63a61923e..ca00f98c73d1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2630,7 +2630,7 @@ static u32 i40e_get_rxfh_indir_size(struct net_de=
vice *netdev)
 }
=20
 static int i40e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *ke=
y,
-			 u8 *hfunc)
+			 u8 *hfunc, u8 *dynamic)
 {
 	struct i40e_netdev_priv *np =3D netdev_priv(netdev);
 	struct i40e_vsi *vsi =3D np->vsi;
@@ -2638,6 +2638,9 @@ static int i40e_get_rxfh(struct net_device *netde=
v, u32 *indir, u8 *key,
 	int ret;
 	u16 i;
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (hfunc)
 		*hfunc =3D ETH_RSS_HASH_TOP;
=20
@@ -2670,7 +2673,7 @@ static int i40e_get_rxfh(struct net_device *netde=
v, u32 *indir, u8 *key,
  * returns 0 after programming the table.
  **/
 static int i40e_set_rxfh(struct net_device *netdev, const u32 *indir,
-			 const u8 *key, const u8 hfunc)
+			 const u8 *key, const u8 hfunc, const u8 dynamic)
 {
 	struct i40e_netdev_priv *np =3D netdev_priv(netdev);
 	struct i40e_vsi *vsi =3D np->vsi;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drive=
rs/net/ethernet/intel/i40evf/i40evf_ethtool.c
index dd4430aae7fa..2cae1dea7e91 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -643,7 +643,7 @@ static u32 i40evf_get_rxfh_indir_size(struct net_de=
vice *netdev)
  * Reads the indirection table directly from the hardware. Always retu=
rns 0.
  **/
 static int i40evf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *=
key,
-			   u8 *hfunc)
+			   u8 *hfunc, u8 *dynamic)
 {
 	struct i40evf_adapter *adapter =3D netdev_priv(netdev);
 	struct i40e_vsi *vsi =3D &adapter->vsi;
@@ -651,6 +651,8 @@ static int i40evf_get_rxfh(struct net_device *netde=
v, u32 *indir, u8 *key,
 	int ret;
 	u16 i;
=20
+	if (dynamic)
+		*dynamic =3D false;
 	if (hfunc)
 		*hfunc =3D ETH_RSS_HASH_TOP;
 	if (!indir)
@@ -686,7 +688,7 @@ static int i40evf_get_rxfh(struct net_device *netde=
v, u32 *indir, u8 *key,
  * returns 0 after programming the table.
  **/
 static int i40evf_set_rxfh(struct net_device *netdev, const u32 *indir=
,
-			   const u8 *key, const u8 hfunc)
+			   const u8 *key, const u8 hfunc, const u8 dynamic)
 {
 	struct i40evf_adapter *adapter =3D netdev_priv(netdev);
 	struct i40e_vsi *vsi =3D &adapter->vsi;
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net=
/ethernet/intel/igb/igb_ethtool.c
index e4420abb413f..6330860d1488 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -3211,11 +3211,13 @@ static u32 igb_get_rxfh_indir_size(struct net_d=
evice *netdev)
 }
=20
 static int igb_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key=
,
-			u8 *hfunc)
+			u8 *hfunc, u8 *dynamic)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
 	int i;
=20
+	if (dynamic)
+		*dynamic =3D false;
 	if (hfunc)
 		*hfunc =3D ETH_RSS_HASH_TOP;
 	if (!indir)
@@ -3262,7 +3264,7 @@ void igb_write_rss_indir_tbl(struct igb_adapter *=
adapter)
 }
=20
 static int igb_set_rxfh(struct net_device *netdev, const u32 *indir,
-			const u8 *key, const u8 hfunc)
+			const u8 *key, const u8 hfunc, const u8 dynamic)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
 	struct e1000_hw *hw =3D &adapter->hw;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers=
/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 5fae53031462..05409e057c04 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2931,10 +2931,13 @@ static void ixgbe_get_reta(struct ixgbe_adapter=
 *adapter, u32 *indir)
 }
=20
 static int ixgbe_get_rxfh(struct net_device *netdev, u32 *indir, u8 *k=
ey,
-			  u8 *hfunc)
+			  u8 *hfunc, u8 *dynamic)
 {
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (hfunc)
 		*hfunc =3D ETH_RSS_HASH_TOP;
=20
@@ -2948,7 +2951,7 @@ static int ixgbe_get_rxfh(struct net_device *netd=
ev, u32 *indir, u8 *key,
 }
=20
 static int ixgbe_set_rxfh(struct net_device *netdev, const u32 *indir,
-			  const u8 *key, const u8 hfunc)
+			  const u8 *key, const u8 hfunc, const u8 dynamic)
 {
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
 	int i;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net=
/ethernet/intel/ixgbevf/ethtool.c
index c48aef613b0a..fd225c284895 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -825,11 +825,14 @@ static u32 ixgbevf_get_rxfh_key_size(struct net_d=
evice *netdev)
 }
=20
 static int ixgbevf_get_rxfh(struct net_device *netdev, u32 *indir, u8 =
*key,
-			    u8 *hfunc)
+			    u8 *hfunc, u8 *dynamic)
 {
 	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
 	int err =3D 0;
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (hfunc)
 		*hfunc =3D ETH_RSS_HASH_TOP;
=20
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethern=
et/marvell/mvneta.c
index fabc8df40392..8950997b9d2c 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3350,7 +3350,8 @@ static int  mvneta_config_rss(struct mvneta_port =
*pp)
 }
=20
 static int mvneta_ethtool_set_rxfh(struct net_device *dev, const u32 *=
indir,
-				   const u8 *key, const u8 hfunc)
+				   const u8 *key, const u8 hfunc,
+				   const u8 dynamic)
 {
 	struct mvneta_port *pp =3D netdev_priv(dev);
 	/* We require at least one supported parameter to be changed
@@ -3369,10 +3370,13 @@ static int mvneta_ethtool_set_rxfh(struct net_d=
evice *dev, const u32 *indir,
 }
=20
 static int mvneta_ethtool_get_rxfh(struct net_device *dev, u32 *indir,=
 u8 *key,
-				   u8 *hfunc)
+				   u8 *hfunc, u8 *dynamic)
 {
 	struct mvneta_port *pp =3D netdev_priv(dev);
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (hfunc)
 		*hfunc =3D ETH_RSS_HASH_TOP;
=20
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/=
net/ethernet/mellanox/mlx4/en_ethtool.c
index dd84cabb2a51..d99926b17b96 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1118,7 +1118,7 @@ static int mlx4_en_check_rxfh_func(struct net_dev=
ice *dev, u8 hfunc)
 }
=20
 static int mlx4_en_get_rxfh(struct net_device *dev, u32 *ring_index, u=
8 *key,
-			    u8 *hfunc)
+			    u8 *hfunc, u8 *dynamic)
 {
 	struct mlx4_en_priv *priv =3D netdev_priv(dev);
 	struct mlx4_en_rss_map *rss_map =3D &priv->rss_map;
@@ -1126,6 +1126,9 @@ static int mlx4_en_get_rxfh(struct net_device *de=
v, u32 *ring_index, u8 *key,
 	size_t n =3D priv->rx_ring_num;
 	int err =3D 0;
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	rss_rings =3D priv->prof->rss_rings ?: priv->rx_ring_num;
 	rss_rings =3D 1 << ilog2(rss_rings);
=20
@@ -1143,7 +1146,7 @@ static int mlx4_en_get_rxfh(struct net_device *de=
v, u32 *ring_index, u8 *key,
 }
=20
 static int mlx4_en_set_rxfh(struct net_device *dev, const u32 *ring_in=
dex,
-			    const u8 *key, const u8 hfunc)
+			    const u8 *key, const u8 hfunc, const u8 dynamic)
 {
 	struct mlx4_en_priv *priv =3D netdev_priv(dev);
 	struct mlx4_en_dev *mdev =3D priv->mdev;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/dri=
vers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 65624ac65b4c..86d14c6be8e7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -685,10 +685,13 @@ static u32 mlx5e_get_rxfh_indir_size(struct net_d=
evice *netdev)
 }
=20
 static int mlx5e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *k=
ey,
-			  u8 *hfunc)
+			  u8 *hfunc, u8 *dynamic)
 {
 	struct mlx5e_priv *priv =3D netdev_priv(netdev);
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (indir)
 		memcpy(indir, priv->params.indirection_rqt,
 		       sizeof(priv->params.indirection_rqt));
@@ -704,7 +707,7 @@ static int mlx5e_get_rxfh(struct net_device *netdev=
, u32 *indir, u8 *key,
 }
=20
 static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
-			  const u8 *key, const u8 hfunc)
+			  const u8 *key, const u8 hfunc, const u8 dynamic)
 {
 	struct mlx5e_priv *priv =3D netdev_priv(dev);
 	bool close_open;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/dri=
vers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 9a4084a68db5..448e49fb5db6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -454,7 +454,7 @@ static u32 nfp_net_get_rxfh_key_size(struct net_dev=
ice *netdev)
 }
=20
 static int nfp_net_get_rxfh(struct net_device *netdev, u32 *indir, u8 =
*key,
-			    u8 *hfunc)
+			    u8 *hfunc, u8 *dynamic)
 {
 	struct nfp_net *nn =3D netdev_priv(netdev);
 	int i;
@@ -462,6 +462,9 @@ static int nfp_net_get_rxfh(struct net_device *netd=
ev, u32 *indir, u8 *key,
 	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS))
 		return -EOPNOTSUPP;
=20
+	if (dynamic)
+		*dynamic =3D false;
+
 	if (indir)
 		for (i =3D 0; i < ARRAY_SIZE(nn->rss_itbl); i++)
 			indir[i] =3D nn->rss_itbl[i];
@@ -475,7 +478,7 @@ static int nfp_net_get_rxfh(struct net_device *netd=
ev, u32 *indir, u8 *key,
=20
 static int nfp_net_set_rxfh(struct net_device *netdev,
 			    const u32 *indir, const u8 *key,
-			    const u8 hfunc)
+			    const u8 hfunc, const u8 dynamic)
 {
 	struct nfp_net *nn =3D netdev_priv(netdev);
 	int i;
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/=
sfc/ethtool.c
index 034797661f96..5b483591f02f 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1087,10 +1087,12 @@ static u32 efx_ethtool_get_rxfh_indir_size(stru=
ct net_device *net_dev)
 }
=20
 static int efx_ethtool_get_rxfh(struct net_device *net_dev, u32 *indir=
, u8 *key,
-				u8 *hfunc)
+				u8 *hfunc, u8 *dynamic)
 {
 	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
+	if (dynamic)
+		*dynamic =3D false;
 	if (hfunc)
 		*hfunc =3D ETH_RSS_HASH_TOP;
 	if (indir)
@@ -1099,7 +1101,8 @@ static int efx_ethtool_get_rxfh(struct net_device=
 *net_dev, u32 *indir, u8 *key,
 }
=20
 static int efx_ethtool_set_rxfh(struct net_device *net_dev, const u32 =
*indir,
-				const u8 *key, const u8 hfunc)
+				const u8 *key, const u8 hfunc,
+				const u8 dynamic)
 {
 	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 653dc9c4ebac..b109d98291d1 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -259,9 +259,9 @@ struct ethtool_ops {
 	u32	(*get_rxfh_key_size)(struct net_device *);
 	u32	(*get_rxfh_indir_size)(struct net_device *);
 	int	(*get_rxfh)(struct net_device *, u32 *indir, u8 *key,
-			    u8 *hfunc);
+			    u8 *hfunc, u8 *dynamic);
 	int	(*set_rxfh)(struct net_device *, const u32 *indir,
-			    const u8 *key, const u8 hfunc);
+			    const u8 *key, const u8 hfunc, const u8 dynamic);
 	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
 	int	(*set_channels)(struct net_device *, struct ethtool_channels *);
 	int	(*get_dump_flag)(struct net_device *, struct ethtool_dump *);
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.=
h
index 57fa39005e79..e2c4a6a94f47 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -923,6 +923,10 @@ struct ethtool_rxfh_indir {
  *	hardware hash key.
  * @hfunc: Defines the current RSS hash function used by HW (or to be =
set to).
  *	Valid values are one of the %ETH_RSS_HASH_*.
+ * @dynamic: Indicate whether the device driver may use dynamic RSS se=
ttings
+ *	which change due to various run time factors, such as number of
+ *	queues. When false driver must attempt to preserve RSS settings whe=
n
+ *	possible. When true driver may override any requested RSS settings.
  * @rsvd:	Reserved for future extensions.
  * @rss_config: RX ring/queue index for each hash value i.e., indirect=
ion table
  *	of @indir_size __u32 elements, followed by hash key of @key_size
@@ -933,6 +937,7 @@ struct ethtool_rxfh_indir {
  * %ETH_RXFH_INDIR_NO_CHANGE means that indir table setting is not req=
uested
  * and a @indir_size of zero means the indir table should be reset to =
default
  * values. An hfunc of zero means that hash function setting is not re=
quested.
+ * If dynamic is true, driver may ignore any other settings requested.
  */
 struct ethtool_rxfh {
 	__u32   cmd;
@@ -940,7 +945,8 @@ struct ethtool_rxfh {
 	__u32   indir_size;
 	__u32   key_size;
 	__u8	hfunc;
-	__u8	rsvd8[3];
+	__u8	dynamic;
+	__u8	rsvd8[2];
 	__u32	rsvd32;
 	__u32   rss_config[0];
 };
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index daf04709dd3c..54676b258eef 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -676,7 +676,7 @@ static noinline_for_stack int ethtool_get_rxfh_indi=
r(struct net_device *dev,
 	if (!indir)
 		return -ENOMEM;
=20
-	ret =3D dev->ethtool_ops->get_rxfh(dev, indir, NULL, NULL);
+	ret =3D dev->ethtool_ops->get_rxfh(dev, indir, NULL, NULL, NULL);
 	if (ret)
 		goto out;
=20
@@ -737,7 +737,7 @@ static noinline_for_stack int ethtool_set_rxfh_indi=
r(struct net_device *dev,
 			goto out;
 	}
=20
-	ret =3D ops->set_rxfh(dev, indir, NULL, ETH_RSS_HASH_NO_CHANGE);
+	ret =3D ops->set_rxfh(dev, indir, NULL, ETH_RSS_HASH_NO_CHANGE, false=
);
=20
 out:
 	kfree(indir);
@@ -755,7 +755,7 @@ static noinline_for_stack int ethtool_get_rxfh(stru=
ct net_device *dev,
 	u32 total_size;
 	u32 indir_bytes;
 	u32 *indir =3D NULL;
-	u8 dev_hfunc =3D 0;
+	u8 dev_hfunc =3D 0, dynamic =3D 0;
 	u8 *hkey =3D NULL;
 	u8 *rss_config;
=20
@@ -773,8 +773,7 @@ static noinline_for_stack int ethtool_get_rxfh(stru=
ct net_device *dev,
 	user_key_size =3D rxfh.key_size;
=20
 	/* Check that reserved fields are 0 for now */
-	if (rxfh.rss_context || rxfh.rsvd8[0] || rxfh.rsvd8[1] ||
-	    rxfh.rsvd8[2] || rxfh.rsvd32)
+	if (rxfh.rss_context || rxfh.rsvd8[0] || rxfh.rsvd8[1] || rxfh.rsvd32=
)
 		return -EINVAL;
=20
 	rxfh.indir_size =3D dev_indir_size;
@@ -798,7 +797,8 @@ static noinline_for_stack int ethtool_get_rxfh(stru=
ct net_device *dev,
 	if (user_key_size)
 		hkey =3D rss_config + indir_bytes;
=20
-	ret =3D dev->ethtool_ops->get_rxfh(dev, indir, hkey, &dev_hfunc);
+	ret =3D dev->ethtool_ops->get_rxfh(dev, indir, hkey, &dev_hfunc,
+					 &dynamic);
 	if (ret)
 		goto out;
=20
@@ -809,6 +809,10 @@ static noinline_for_stack int ethtool_get_rxfh(str=
uct net_device *dev,
 			      offsetof(struct ethtool_rxfh, rss_config[0]),
 			      rss_config, total_size)) {
 		ret =3D -EFAULT;
+	} else if (copy_to_user(useraddr +
+				offsetof(struct ethtool_rxfh, dynamic),
+				&dynamic, sizeof(rxfh.dynamic))) {
+		ret =3D -EFAULT;
 	}
 out:
 	kfree(rss_config);
@@ -841,19 +845,20 @@ static noinline_for_stack int ethtool_set_rxfh(st=
ruct net_device *dev,
 		return -EFAULT;
=20
 	/* Check that reserved fields are 0 for now */
-	if (rxfh.rss_context || rxfh.rsvd8[0] || rxfh.rsvd8[1] ||
-	    rxfh.rsvd8[2] || rxfh.rsvd32)
+	if (rxfh.rss_context || rxfh.rsvd8[0] || rxfh.rsvd8[1] || rxfh.rsvd32=
)
 		return -EINVAL;
=20
 	/* If either indir, hash key or function is valid, proceed further.
-	 * Must request at least one change: indir size, hash key or function=
=2E
+	 * Must request at least one change: indir size, hash key, function o=
r
+	 * dynamic mode.
 	 */
 	if ((rxfh.indir_size &&
 	     rxfh.indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE &&
 	     rxfh.indir_size !=3D dev_indir_size) ||
 	    (rxfh.key_size && (rxfh.key_size !=3D dev_key_size)) ||
 	    (rxfh.indir_size =3D=3D ETH_RXFH_INDIR_NO_CHANGE &&
-	     rxfh.key_size =3D=3D 0 && rxfh.hfunc =3D=3D ETH_RSS_HASH_NO_CHAN=
GE))
+	     rxfh.key_size =3D=3D 0 && rxfh.hfunc =3D=3D ETH_RSS_HASH_NO_CHAN=
GE &&
+	     rxfh.dynamic =3D=3D 0))
 		return -EINVAL;
=20
 	if (rxfh.indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE)
@@ -896,7 +901,7 @@ static noinline_for_stack int ethtool_set_rxfh(stru=
ct net_device *dev,
 		}
 	}
=20
-	ret =3D ops->set_rxfh(dev, indir, hkey, rxfh.hfunc);
+	ret =3D ops->set_rxfh(dev, indir, hkey, rxfh.hfunc, rxfh.dynamic);
=20
 out:
 	kfree(rss_config);
--=20
2.6.3.505.g5cc1fd1
