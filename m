From: kys@exchange.microsoft.com
Subject: [PATCH net-next 1/1] netvsc: Initialize all channel related state
 prior to opening the channel
Date: Thu,  6 Apr 2017 14:59:21 -0700
Message-ID: <1491515961-15624-1-git-send-email-kys@exchange.microsoft.com>
Reply-To: kys@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, leann.ogasawara@canonical.comi,
 marcelo.cerri@canonical.com, sthemmin@microsoft.com
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

From: K. Y. Srinivasan <kys@microsoft.com>

Prior to opening the channel we should have all the state setup to handle
interrupts. The current code does not do that; fix the bug. This bug
can result in faults in the interrupt path.
 
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc.c       |   27 +++++++++++++++------------
 drivers/net/hyperv/rndis_filter.c |    5 +++--
 2 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index e998e2f..7ab06b3 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1289,6 +1289,21 @@ int netvsc_device_add(struct hv_device *device,
 	 */
 	set_channel_read_mode(device->channel, HV_CALL_ISR);
 
+	/* If we're reopening the device we may have multiple queues, fill the
+	 * chn_table with the default channel to use it before subchannels are
+	 * opened.
+	 * Initialize the channel state before we open;
+	 * we can be interrupted as soon as we open the channel.
+	 */
+
+	for (i = 0; i < VRSS_CHANNEL_MAX; i++) {
+		struct netvsc_channel *nvchan = &net_device->chan_table[i];
+
+		nvchan->channel = device->channel;
+		netif_napi_add(ndev, &nvchan->napi,
+			       netvsc_poll, NAPI_POLL_WEIGHT);
+	}
+
 	/* Open the channel */
 	ret = vmbus_open(device->channel, ring_size * PAGE_SIZE,
 			 ring_size * PAGE_SIZE, NULL, 0,
@@ -1303,18 +1318,6 @@ int netvsc_device_add(struct hv_device *device,
 	/* Channel is opened */
 	netdev_dbg(ndev, "hv_netvsc channel opened successfully\n");
 
-	/* If we're reopening the device we may have multiple queues, fill the
-	 * chn_table with the default channel to use it before subchannels are
-	 * opened.
-	 */
-	for (i = 0; i < VRSS_CHANNEL_MAX; i++) {
-		struct netvsc_channel *nvchan = &net_device->chan_table[i];
-
-		nvchan->channel = device->channel;
-		netif_napi_add(ndev, &nvchan->napi,
-			       netvsc_poll, NAPI_POLL_WEIGHT);
-	}
-
 	/* Enable NAPI handler for init callbacks */
 	napi_enable(&net_device->chan_table[0].napi);
 
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 9835825..1e9445b 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1007,12 +1007,13 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 	 */
 	set_channel_read_mode(new_sc, HV_CALL_ISR);
 
+	/* Set the channel before opening.*/
+	nvchan->channel = new_sc;
+
 	ret = vmbus_open(new_sc, nvscdev->ring_size * PAGE_SIZE,
 			 nvscdev->ring_size * PAGE_SIZE, NULL, 0,
 			 netvsc_channel_cb, nvchan);
 
-	if (ret == 0)
-		nvchan->channel = new_sc;
 
 	napi_enable(&nvchan->napi);
 
-- 
1.7.1
