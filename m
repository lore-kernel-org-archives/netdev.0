From: kys@exchange.microsoft.com
Subject: [PATCH 1/1] netvsc: Deal with rescinded channels correctly
Date: Wed, 19 Apr 2017 13:49:19 -0700
Message-ID: <1492634959-28942-1-git-send-email-kys@exchange.microsoft.com>
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

We will not be able to send packets over a channel that has been
rescinded. Make necessary adjustments so we can properly cleanup
even when the channel is rescinded. This issue can be trigerred
in the NIC hot-remove path.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 7ab06b3..b5b10fc 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -135,6 +135,13 @@ static void netvsc_destroy_buf(struct hv_device *device)
 				       sizeof(struct nvsp_message),
 				       (unsigned long)revoke_packet,
 				       VM_PKT_DATA_INBAND, 0);
+		/* If the failure is because the channel is rescinded;
+		 * ignore the failure since we cannot send on a rescinded
+		 * channel. This would allow us to properly cleanup
+		 * even when the channel is rescinded.
+		 */
+		if (device->channel->rescind)
+			ret = 0;
 		/*
 		 * If we failed here, we might as well return and
 		 * have a leak rather than continue and a bugchk
@@ -195,6 +202,15 @@ static void netvsc_destroy_buf(struct hv_device *device)
 				       sizeof(struct nvsp_message),
 				       (unsigned long)revoke_packet,
 				       VM_PKT_DATA_INBAND, 0);
+
+		/* If the failure is because the channel is rescinded;
+		 * ignore the failure since we cannot send on a rescinded
+		 * channel. This would allow us to properly cleanup
+		 * even when the channel is rescinded.
+		 */
+		if (device->channel->rescind)
+			ret = 0;
+
 		/* If we failed here, we might as well return and
 		 * have a leak rather than continue and a bugchk
 		 */
-- 
1.7.1
