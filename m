From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: [PATCH net-next-2.6] IB/{nes,ipoib}: Pass supported flags to
 ethtool_op_set_flags()
Date: Sat, 03 Jul 2010 20:41:29 +0100
Message-ID: <1278186089.4878.570.camel@localhost>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
	 <20100702095514.7fb324c8.randy.dunlap@oracle.com>
	 <20100702.220711.39188625.davem@davemloft.net>
	 <20100703120729.f2a2715b.randy.dunlap@oracle.com>
	 <1278184884.4878.559.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-net-drivers-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	amit.salecha-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	anirban.chakraborty-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, scofeldm-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	vkolluri-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, roprabhu-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org,
	gallatin-vV262kQ/Wyo@public.gmane.org, brice-vV262kQ/Wyo@public.gmane.org, shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	jgarzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Chien Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1278184884.4878.559.camel@localhost>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Following commit 1437ce3983bcbc0447a0dedcd644c14fe833d266 "ethtool:
Change ethtool_op_set_flags to validate flags", ethtool_op_set_flags
takes a third parameter and cannot be used directly as an
implementation of ethtool_ops::set_flags.

Changes nes and ipoib driver to pass in the appropriate value.

Signed-off-by: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
---
This is compile-tested only.

Dave, Roland, you'd better decide between yourselves should apply this.

Ben.

 drivers/infiniband/hw/nes/nes_nic.c          |    8 +++++++-
 drivers/infiniband/ulp/ipoib/ipoib_ethtool.c |    7 ++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 5cc0a9a..42e7aad 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1567,6 +1567,12 @@ static int nes_netdev_set_settings(struct net_device *netdev, struct ethtool_cmd
 }
 

+static int nes_netdev_set_flags(struct net_device *netdev, u32 flags)
+{
+	return ethtool_op_set_flags(netdev, flags, ETH_FLAG_LRO);
+}
+
+
 static const struct ethtool_ops nes_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_settings = nes_netdev_get_settings,
@@ -1588,7 +1594,7 @@ static const struct ethtool_ops nes_ethtool_ops = {
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = ethtool_op_set_tso,
 	.get_flags = ethtool_op_get_flags,
-	.set_flags = ethtool_op_set_flags,
+	.set_flags = nes_netdev_set_flags,
 };
 

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c b/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
index 40e8584..1a1657c 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
@@ -147,6 +147,11 @@ static void ipoib_get_ethtool_stats(struct net_device *dev,
 	data[index++] = priv->lro.lro_mgr.stats.no_desc;
 }
 
+static int ipoib_set_flags(struct net_device *dev, u32 flags)
+{
+	return ethtool_op_set_flags(dev, flags, ETH_FLAG_LRO);
+}
+
 static const struct ethtool_ops ipoib_ethtool_ops = {
 	.get_drvinfo		= ipoib_get_drvinfo,
 	.get_rx_csum		= ipoib_get_rx_csum,
@@ -154,7 +159,7 @@ static const struct ethtool_ops ipoib_ethtool_ops = {
 	.get_coalesce		= ipoib_get_coalesce,
 	.set_coalesce		= ipoib_set_coalesce,
 	.get_flags		= ethtool_op_get_flags,
-	.set_flags		= ethtool_op_set_flags,
+	.set_flags		= ipoib_set_flags,
 	.get_strings		= ipoib_get_strings,
 	.get_sset_count		= ipoib_get_sset_count,
 	.get_ethtool_stats	= ipoib_get_ethtool_stats,
-- 
1.7.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
