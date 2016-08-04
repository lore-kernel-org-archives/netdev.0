From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,
 2/2] hv_netvsc: Add handler for physical link speed change
Date: Thu,  4 Aug 2016 10:42:15 -0700
Message-ID: <1470332535-15554-2-git-send-email-haiyangz@exchange.microsoft.com>
References: <1470332535-15554-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, driverdev-devel@linuxdriverproject.org,
 olaf@aepfle.de
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1470332535-15554-1-git-send-email-haiyangz@exchange.microsoft.com>
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

From: Haiyang Zhang <haiyangz@microsoft.com>

On Hyper-V host 2016 and later, VMs gets an event message of the physical
link speed when vSwitch is changed. This patch handles this message, so
the updated link speed can be reported by ethtool.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    1 +
 drivers/net/hyperv/netvsc.c     |    6 +++++-
 drivers/net/hyperv/netvsc_drv.c |   25 +++++++++++++++++++------
 3 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 467fb8b..c1403fd 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -490,6 +490,7 @@ struct nvsp_2_vsc_capability {
 			u64 sriov:1;
 			u64 ieee8021q:1;
 			u64 correlation_id:1;
+			u64 teaming:1;
 		};
 	};
 } __packed;
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 20e0917..36a7994 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -472,9 +472,13 @@ static int negotiate_nvsp_ver(struct hv_device *device,
 	init_packet->msg.v2_msg.send_ndis_config.mtu = ndev->mtu + ETH_HLEN;
 	init_packet->msg.v2_msg.send_ndis_config.capability.ieee8021q = 1;
 
-	if (nvsp_ver >= NVSP_PROTOCOL_VERSION_5)
+	if (nvsp_ver >= NVSP_PROTOCOL_VERSION_5) {
 		init_packet->msg.v2_msg.send_ndis_config.capability.sriov = 1;
 
+		/* Teaming bit is needed to receive link speed updates */
+		init_packet->msg.v2_msg.send_ndis_config.capability.teaming = 1;
+	}
+
 	ret = vmbus_sendpacket(device->channel, init_packet,
 				sizeof(struct nvsp_message),
 				(unsigned long)init_packet,
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 3e5356b..82c8f6d 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -579,19 +579,32 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
 	struct netvsc_reconfig *event;
 	unsigned long flags;
 
-	/* Handle link change statuses only */
+	net = hv_get_drvdata(device_obj);
+
+	if (!net)
+		return;
+
+	ndev_ctx = netdev_priv(net);
+
+	/* Update the physical link speed when changing to another vSwitch */
+	if (indicate->status == RNDIS_STATUS_LINK_SPEED_CHANGE) {
+		u32 speed;
+
+		speed = *(u32 *)((void *)indicate + indicate->
+				 status_buf_offset) / 10000;
+		ndev_ctx->speed = speed;
+		return;
+	}
+
+	/* Handle these link change statuses below */
 	if (indicate->status != RNDIS_STATUS_NETWORK_CHANGE &&
 	    indicate->status != RNDIS_STATUS_MEDIA_CONNECT &&
 	    indicate->status != RNDIS_STATUS_MEDIA_DISCONNECT)
 		return;
 
-	net = hv_get_drvdata(device_obj);
-
-	if (!net || net->reg_state != NETREG_REGISTERED)
+	if (net->reg_state != NETREG_REGISTERED)
 		return;
 
-	ndev_ctx = netdev_priv(net);
-
 	event = kzalloc(sizeof(*event), GFP_ATOMIC);
 	if (!event)
 		return;
-- 
1.7.4.1
