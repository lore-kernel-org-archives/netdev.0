From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 10/10] hv_netvsc: remove locking in netvsc_send()
Date: Mon, 23 Nov 2015 15:29:06 -0800
Message-ID: <1448321346-21357-10-git-send-email-kys@microsoft.com>
References: <1448321324-21318-1-git-send-email-kys@microsoft.com>
 <1448321346-21357-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1448321346-21357-1-git-send-email-kys@microsoft.com>
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

From: Vitaly Kuznetsov <vkuznets@redhat.com>

Packet scheduler guarantees there won't be multiple senders for the same
queue and as we use q_idx for multi_send_data the spinlock is redundant.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    1 -
 drivers/net/hyperv/netvsc.c     |    8 --------
 2 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index a9d2bdc5..f5b2145 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -633,7 +633,6 @@ struct nvsp_message {
 #define RNDIS_PKT_ALIGN_DEFAULT 8
 
 struct multi_send_data {
-	spinlock_t lock; /* protect struct multi_send_data */
 	struct hv_netvsc_packet *pkt; /* netvsc pkt pending */
 	u32 count; /* counter of batched packets */
 };
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 419b055..081f14f 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -38,7 +38,6 @@ static struct netvsc_device *alloc_net_device(struct hv_device *device)
 {
 	struct netvsc_device *net_device;
 	struct net_device *ndev = hv_get_drvdata(device);
-	int i;
 
 	net_device = kzalloc(sizeof(struct netvsc_device), GFP_KERNEL);
 	if (!net_device)
@@ -58,9 +57,6 @@ static struct netvsc_device *alloc_net_device(struct hv_device *device)
 	net_device->max_pkt = RNDIS_MAX_PKT_DEFAULT;
 	net_device->pkt_align = RNDIS_PKT_ALIGN_DEFAULT;
 
-	for (i = 0; i < num_online_cpus(); i++)
-		spin_lock_init(&net_device->msd[i].lock);
-
 	hv_set_drvdata(device, net_device);
 	return net_device;
 }
@@ -850,7 +846,6 @@ int netvsc_send(struct hv_device *device,
 	u16 q_idx = packet->q_idx;
 	u32 pktlen = packet->total_data_buflen, msd_len = 0;
 	unsigned int section_index = NETVSC_INVALID_INDEX;
-	unsigned long flag;
 	struct multi_send_data *msdp;
 	struct hv_netvsc_packet *msd_send = NULL, *cur_send = NULL;
 	bool try_batch;
@@ -867,7 +862,6 @@ int netvsc_send(struct hv_device *device,
 	msdp = &net_device->msd[q_idx];
 
 	/* batch packets in send buffer if possible */
-	spin_lock_irqsave(&msdp->lock, flag);
 	if (msdp->pkt)
 		msd_len = msdp->pkt->total_data_buflen;
 
@@ -927,8 +921,6 @@ int netvsc_send(struct hv_device *device,
 		cur_send = packet;
 	}
 
-	spin_unlock_irqrestore(&msdp->lock, flag);
-
 	if (msd_send) {
 		m_ret = netvsc_send_pkt(msd_send, net_device);
 
-- 
1.7.4.1
