From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Fix the order of num_sc_offered decrement
Date: Wed, 23 Mar 2016 14:54:48 -0700
Message-ID: <1458770088-923-1-git-send-email-haiyangz@microsoft.com>
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

Reorder the code in netvsc_sc_open(), so num_sc_offered is only decremented
after vmbus_open() is called. This avoid pontential race of removing device
before all channels are setup.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/rndis_filter.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index d5a54da..c4e1e04 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -986,12 +986,6 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 
 	nvscdev = hv_get_drvdata(new_sc->primary_channel->device_obj);
 
-	spin_lock_irqsave(&nvscdev->sc_lock, flags);
-	nvscdev->num_sc_offered--;
-	spin_unlock_irqrestore(&nvscdev->sc_lock, flags);
-	if (nvscdev->num_sc_offered == 0)
-		complete(&nvscdev->channel_init_wait);
-
 	if (chn_index >= nvscdev->num_chn)
 		return;
 
@@ -1004,6 +998,12 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 
 	if (ret == 0)
 		nvscdev->chn_table[chn_index] = new_sc;
+
+	spin_lock_irqsave(&nvscdev->sc_lock, flags);
+	nvscdev->num_sc_offered--;
+	spin_unlock_irqrestore(&nvscdev->sc_lock, flags);
+	if (nvscdev->num_sc_offered == 0)
+		complete(&nvscdev->channel_init_wait);
 }
 
 int rndis_filter_device_add(struct hv_device *dev,
-- 
1.7.4.1
