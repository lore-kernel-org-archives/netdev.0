From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH] netvsc: fix use-after-free in netvsc_change_mtu()
Date: Thu, 2 Mar 2017 13:00:53 +0000
Message-ID: <MWHPR03MB266949159A2BCA01B5EBB778BF280@MWHPR03MB2669.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>,
 Stephen Hemminger <sthemmin@microsoft.com>, KY Srinivasan
 <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Language: en-US
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

'nvdev' is freed in rndis_filter_device_remove -> netvsc_device_remove ->
free_netvsc_device, so we mustn't access it, before it's re-created in
rndis_filter_device_add -> netvsc_device_add.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 2d3cdb0..bc05c89 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -859,15 +859,22 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	if (ret)
 		goto out;
 
+	memset(&device_info, 0, sizeof(device_info));
+	device_info.ring_size = ring_size;
+	device_info.num_chn = nvdev->num_chn;
+	device_info.max_num_vrss_chns = nvdev->num_chn;
+
 	ndevctx->start_remove = true;
 	rndis_filter_device_remove(hdev, nvdev);
 
+	/* 'nvdev' has been freed in rndis_filter_device_remove() ->
+	 * netvsc_device_remove () -> free_netvsc_device().
+	 * We mustn't access it before it's re-created in
+	 * rndis_filter_device_add() -> netvsc_device_add().
+	 */
+
 	ndev->mtu = mtu;
 
-	memset(&device_info, 0, sizeof(device_info));
-	device_info.ring_size = ring_size;
-	device_info.num_chn = nvdev->num_chn;
-	device_info.max_num_vrss_chns = nvdev->num_chn;
 	rndis_filter_device_add(hdev, &device_info);
 
 out:
-- 
2.7.4
