From: Colin King <colin.king@canonical.com>
Subject: [PATCH] netvsc: fix dereference before null check errors
Date: Sat, 25 Mar 2017 14:26:39 +0000
Message-ID: <20170325142639.11452-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "K . Y . Srinivasan" <kys@microsoft.com>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 Stephen Hemminger <sthemmin@microsoft.com>, devel@linuxdriverproject.org,
 netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

ndev is being checked to see if it is a null pointer however before
the null check ndev is being dereferenced; hence there is a potential
null pointer dereference bug that needs fixing. Fix this by only
dereferencing ndev after the null check.

Detected by CoverityScan, CID#1420760, CID#140761 ("Dereference
before null check")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/hyperv/netvsc_drv.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f830bbbd8ad4..f24c2891dd0c 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1135,7 +1135,7 @@ static int netvsc_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 {
 	struct net_device_context *ndc = netdev_priv(dev);
 	struct netvsc_device *ndev = rcu_dereference(ndc->nvdev);
-	struct rndis_device *rndis_dev = ndev->extension;
+	struct rndis_device *rndis_dev;
 	int i;
 
 	if (!ndev)
@@ -1144,6 +1144,7 @@ static int netvsc_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 	if (hfunc)
 		*hfunc = ETH_RSS_HASH_TOP;	/* Toeplitz */
 
+	rndis_dev = ndev->extension;
 	if (indir) {
 		for (i = 0; i < ITAB_NUM; i++)
 			indir[i] = rndis_dev->ind_table[i];
@@ -1160,7 +1161,7 @@ static int netvsc_set_rxfh(struct net_device *dev, const u32 *indir,
 {
 	struct net_device_context *ndc = netdev_priv(dev);
 	struct netvsc_device *ndev = rtnl_dereference(ndc->nvdev);
-	struct rndis_device *rndis_dev = ndev->extension;
+	struct rndis_device *rndis_dev;
 	int i;
 
 	if (!ndev)
@@ -1169,6 +1170,7 @@ static int netvsc_set_rxfh(struct net_device *dev, const u32 *indir,
 	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
 		return -EOPNOTSUPP;
 
+	rndis_dev = ndev->extension;
 	if (indir) {
 		for (i = 0; i < ITAB_NUM; i++)
 			if (indir[i] >= dev->num_rx_queues)
-- 
2.11.0
