From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 04/10] netvsc: check error return when restoring
 channels and mtu
Date: Wed,  9 Aug 2017 17:46:06 -0700
Message-ID: <20170810004612.22163-5-sthemmin@microsoft.com>
References: <20170810004612.22163-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170810004612.22163-1-sthemmin@microsoft.com>
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

If setting new values fails, and the attempt to restore original
settings fails. Then log an error and leave device down.
This should never happen, but if it does don't go down in flames.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 07015b1c42c6..c7391889938b 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -845,7 +845,13 @@ static int netvsc_set_channels(struct net_device *net,
 	} else {
 		ret = PTR_ERR(nvdev);
 		device_info.num_chn = orig;
-		rndis_filter_device_add(dev, &device_info);
+		nvdev = rndis_filter_device_add(dev, &device_info);
+
+		if (IS_ERR(nvdev)) {
+			netdev_err(net, "restoring channel setting failed: %ld\n",
+				   PTR_ERR(nvdev));
+			return ret;
+		}
 	}
 
 	if (was_opened)
@@ -953,10 +959,16 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 
 		/* Attempt rollback to original MTU */
 		ndev->mtu = orig_mtu;
-		rndis_filter_device_add(hdev, &device_info);
+		nvdev = rndis_filter_device_add(hdev, &device_info);
 
 		if (vf_netdev)
 			dev_set_mtu(vf_netdev, orig_mtu);
+
+		if (IS_ERR(nvdev)) {
+			netdev_err(ndev, "restoring mtu failed: %ld\n",
+				   PTR_ERR(nvdev));
+			return ret;
+		}
 	}
 
 	if (was_opened)
-- 
2.11.0
