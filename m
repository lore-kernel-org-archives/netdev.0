From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V6 5/8] Drivers: hv: vmbus: add a hvsock flag in struct
 hv_driver
Date: Tue, 26 Jan 2016 01:44:52 -0800
Message-ID: <1453801492-3397-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pebolle@tiscali.nl, dan.carpenter@oracle.com, stefanha@redhat.com
To: gregkh@linuxfoundation.org, davem@davemloft.net,
 stephen@networkplumber.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, driverdev-devel@linuxdriverproject.org,
 olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
 vkuznets@redhat.com
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

Only the coming hv_sock driver has a "true" value for this flag.

We treat the hvsock offers/channels as special VMBus devices.
Since the hv_sock driver handles all the hvsock offers/channels, we need to
tweak vmbus_match() for hv_sock driver, so we introduce this flag.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 drivers/hv/vmbus_drv.c |  4 ++++
 include/linux/hyperv.h | 14 ++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/drivers/hv/vmbus_drv.c b/drivers/hv/vmbus_drv.c
index 328e4c3..c1c9d71 100644
--- a/drivers/hv/vmbus_drv.c
+++ b/drivers/hv/vmbus_drv.c
@@ -562,6 +562,10 @@ static int vmbus_match(struct device *device, struct device_driver *driver)
 	struct hv_driver *drv = drv_to_hv_drv(driver);
 	struct hv_device *hv_dev = device_to_hv_device(device);
 
+	/* The hv_sock driver handles all hv_sock offers. */
+	if (is_hvsock_channel(hv_dev->channel))
+		return drv->hvsock;
+
 	if (hv_vmbus_get_id(drv->id_table, &hv_dev->dev_type))
 		return 1;
 
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index b835d80..5587711 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -964,6 +964,20 @@ extern void vmbus_ontimer(unsigned long data);
 struct hv_driver {
 	const char *name;
 
+	/*
+	 * A hvsock offer, which has a VMBUS_CHANNEL_TLNPI_PROVIDER_OFFER
+	 * channel flag, actually doesn't mean a synthetic device because the
+	 * offer's if_type/if_instance can change for every new hvsock
+	 * connection.
+	 *
+	 * However, to facilitate the notification of new-offer/rescind-offer
+	 * from vmbus driver to hvsock driver, we can handle hvsock offer as
+	 * a special vmbus device, and hence we need the below flag to
+	 * indicate if the driver is the hvsock driver or not: we need to
+	 * specially treat the hvosck offer & driver in vmbus_match().
+	 */
+	bool hvsock;
+
 	/* the device type supported by this driver */
 	uuid_le dev_type;
 	const struct hv_vmbus_device_id *id_table;
-- 
2.1.0
