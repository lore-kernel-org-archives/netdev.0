From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hyperv: Add support for vNIC hot removal
Date: Mon,  1 Dec 2014 13:28:39 -0800
Message-ID: <1417469319-7356-1-git-send-email-haiyangz@microsoft.com>
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

This patch adds proper handling of the vNIC hot removal event, which includes
a rescind-channel-offer message from the host side that triggers vNIC close and
removal. In this case, the notices to the host during close and removal is not
necessary because the channel is rescinded. This patch blocks these unnecessary 
messages, and lets vNIC removal process complete normally.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/hv/channel_mgmt.c         |    2 ++
 drivers/net/hyperv/netvsc.c       |    3 +++
 drivers/net/hyperv/rndis_filter.c |    3 +++
 include/linux/hyperv.h            |    2 ++
 4 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/hv/channel_mgmt.c b/drivers/hv/channel_mgmt.c
index a2d1a96..191a6a3 100644
--- a/drivers/hv/channel_mgmt.c
+++ b/drivers/hv/channel_mgmt.c
@@ -517,6 +517,8 @@ static void vmbus_onoffer_rescind(struct vmbus_channel_message_header *hdr)
 		/* Just return here, no channel found */
 		return;
 
+	channel->rescind = true;
+
 	/* work is initialized for vmbus_process_rescind_offer() from
 	 * vmbus_process_offer() where the channel got created */
 	queue_work(channel->controlwq, &channel->work);
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 6fc834e..dd867e6 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -764,6 +764,9 @@ int netvsc_send(struct hv_device *device,
 		out_channel = device->channel;
 	packet->channel = out_channel;
 
+	if (out_channel->rescind)
+		return -ENODEV;
+
 	if (packet->page_buf_cnt) {
 		ret = vmbus_sendpacket_pagebuffer(out_channel,
 						  packet->page_buf,
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 7b2c5d1..ec0c40a 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -958,6 +958,9 @@ static int rndis_filter_close_device(struct rndis_device *dev)
 		return 0;
 
 	ret = rndis_filter_set_packet_filter(dev, 0);
+	if (ret == -ENODEV)
+		ret = 0;
+
 	if (ret == 0)
 		dev->state = RNDIS_DEV_INITIALIZED;
 
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index 08cfaff..476c685 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -650,6 +650,8 @@ struct vmbus_channel {
 	u8 monitor_grp;
 	u8 monitor_bit;
 
+	bool rescind; /* got rescind msg */
+
 	u32 ringbuffer_gpadlhandle;
 
 	/* Allocated memory for ring buffer */
-- 
1.7.1
