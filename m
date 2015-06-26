From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Add support to set MTU reservation from
 guest side
Date: Fri, 26 Jun 2015 12:06:00 -0700
Message-ID: <1435345560-5972-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
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

When packet encapsulation is in use, the MTU needs to be reduced for
headroom reservation.
The existing code takes the updated MTU value only from the host side.
But vSwitch extensions, such as Open vSwitch, require the flexibility
to change the MTU to different values from within a guest during the
lifecycle of a vNIC, when the encapsulation protocol is changed. The
patch supports this kind of MTU changes.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c   |    3 +--
 drivers/net/hyperv/rndis_filter.c |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 358475e..68e7ece 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -743,8 +743,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	if (nvdev->nvsp_version >= NVSP_PROTOCOL_VERSION_2)
 		limit = NETVSC_MTU - ETH_HLEN;
 
-	/* Hyper-V hosts don't support MTU < ETH_DATA_LEN (1500) */
-	if (mtu < ETH_DATA_LEN || mtu > limit)
+	if (mtu < 68 || mtu > limit)
 		return -EINVAL;
 
 	nvdev->start_remove = true;
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 006c1b8..172824e 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1053,7 +1053,7 @@ int rndis_filter_device_add(struct hv_device *dev,
 	ret = rndis_filter_query_device(rndis_device,
 					RNDIS_OID_GEN_MAXIMUM_FRAME_SIZE,
 					&mtu, &size);
-	if (ret == 0 && size == sizeof(u32))
+	if (ret == 0 && size == sizeof(u32) && mtu < net_device->ndev->mtu)
 		net_device->ndev->mtu = mtu;
 
 	/* Get the mac address */
-- 
1.7.4.1
