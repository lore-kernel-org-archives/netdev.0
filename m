From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/8] netvsc: change order of steps in setting queues
Date: Wed, 19 Jul 2017 11:53:14 -0700
Message-ID: <20170719185319.25871-4-sthemmin@microsoft.com>
References: <20170719185319.25871-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170719185319.25871-1-sthemmin@microsoft.com>
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

This fixes the error unwind logic for incorrect number of queues.
If netif_set_real_num_XX_queues failed then rndis_filter_device_add
would have been called twice. Since input arguments are already
ranged checked this is a hypothetical only problem, not possible
in actual code.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index e8e82a6a4b1a..91637336d1fb 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -724,17 +724,15 @@ static int netvsc_set_queues(struct net_device *net, struct hv_device *dev,
 	device_info.ring_size = ring_size;
 	device_info.max_num_vrss_chns = num_chn;
 
-	ret = rndis_filter_device_add(dev, &device_info);
-	if (ret)
-		return ret;
-
 	ret = netif_set_real_num_tx_queues(net, num_chn);
 	if (ret)
 		return ret;
 
 	ret = netif_set_real_num_rx_queues(net, num_chn);
+	if (ret)
+		return ret;
 
-	return ret;
+	return rndis_filter_device_add(dev, &device_info);
 }
 
 static int netvsc_set_channels(struct net_device *net,
-- 
2.11.0
