From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next v2 4/5] hv_netvsc: pass struct net_device to
 rndis_filter_set_device_mac()
Date: Fri,  3 Jun 2016 17:51:01 +0200
Message-ID: <1464969062-22132-5-git-send-email-vkuznets@redhat.com>
References: <1464969062-22132-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1464969062-22132-1-git-send-email-vkuznets@redhat.com>
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

We unpack 'struct net_device' in netvsc_set_mac_addr() to get to
'struct hv_device' pointer which we use in rndis_filter_set_device_mac()
to get back to 'struct net_device'.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/hyperv_net.h   | 2 +-
 drivers/net/hyperv/netvsc_drv.c   | 4 +---
 drivers/net/hyperv/rndis_filter.c | 3 +--
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index f650ec1..467fb8b 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -201,7 +201,7 @@ int rndis_filter_receive(struct hv_device *dev,
 			struct vmbus_channel *channel);
 
 int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter);
-int rndis_filter_set_device_mac(struct hv_device *hdev, char *mac);
+int rndis_filter_set_device_mac(struct net_device *ndev, char *mac);
 
 void netvsc_switch_datapath(struct net_device *nv_dev, bool vf);
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 591ab58..733dea1 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -982,8 +982,6 @@ static struct rtnl_link_stats64 *netvsc_get_stats64(struct net_device *net,
 
 static int netvsc_set_mac_addr(struct net_device *ndev, void *p)
 {
-	struct net_device_context *ndevctx = netdev_priv(ndev);
-	struct hv_device *hdev =  ndevctx->device_ctx;
 	struct sockaddr *addr = p;
 	char save_adr[ETH_ALEN];
 	unsigned char save_aatype;
@@ -996,7 +994,7 @@ static int netvsc_set_mac_addr(struct net_device *ndev, void *p)
 	if (err != 0)
 		return err;
 
-	err = rndis_filter_set_device_mac(hdev, addr->sa_data);
+	err = rndis_filter_set_device_mac(ndev, addr->sa_data);
 	if (err != 0) {
 		/* roll back to saved MAC */
 		memcpy(ndev->dev_addr, save_adr, ETH_ALEN);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 2c2f3b9..f1692bc 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -543,9 +543,8 @@ static int rndis_filter_query_device_mac(struct rndis_device *dev)
 #define NWADR_STR "NetworkAddress"
 #define NWADR_STRLEN 14
 
-int rndis_filter_set_device_mac(struct hv_device *hdev, char *mac)
+int rndis_filter_set_device_mac(struct net_device *ndev, char *mac)
 {
-	struct net_device *ndev = hv_get_drvdata(hdev);
 	struct netvsc_device *nvdev = net_device_to_netvsc_device(ndev);
 	struct rndis_device *rdev = nvdev->extension;
 	struct rndis_request *request;
-- 
2.5.5
