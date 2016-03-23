From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,
 1/2] hv_netvsc: Fix accessing freed memory in netvsc_change_mtu()
Date: Wed, 23 Mar 2016 09:43:09 -0700
Message-ID: <1458751390-26971-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, haiyangz@microsoft.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net,
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

struct netvsc_device is freed in rndis_filter_device_remove(). So we save
the nvdev->num_chn into a temp variable for later usage.

(Please also include this patch into stable branch.)

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/netvsc_drv.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 0860849..b8121eb 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -858,6 +858,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	struct netvsc_device *nvdev = hv_get_drvdata(hdev);
 	struct netvsc_device_info device_info;
 	int limit = ETH_DATA_LEN;
+	u32 num_chn;
 	int ret = 0;
 
 	if (nvdev == NULL || nvdev->destroy)
@@ -873,6 +874,8 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	if (ret)
 		goto out;
 
+	num_chn = nvdev->num_chn;
+
 	nvdev->start_remove = true;
 	rndis_filter_device_remove(hdev);
 
@@ -883,7 +886,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 
 	memset(&device_info, 0, sizeof(device_info));
 	device_info.ring_size = ring_size;
-	device_info.num_chn = nvdev->num_chn;
+	device_info.num_chn = num_chn;
 	device_info.max_num_vrss_chns = max_num_vrss_chns;
 	rndis_filter_device_add(hdev, &device_info);
 
-- 
1.7.4.1
