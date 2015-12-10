From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Fix race condition on Multi-Send Data
 field
Date: Thu, 10 Dec 2015 12:19:35 -0800
Message-ID: <1449778775-14404-1-git-send-email-haiyangz@microsoft.com>
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

In commit 2a04ae8acb14 ("hv_netvsc: remove locking in netvsc_send()"), the
locking for MSD (Multi-Send Data) field was removed. This could cause a
race condition between RNDIS control messages and data packets processing,
because these two types of traffic are not synchronized.
This patch fixes this issue by sending control messages out directly
without reading MSD field.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 02bab9a..059fc52 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -867,6 +867,14 @@ int netvsc_send(struct hv_device *device,
 	packet->send_buf_index = NETVSC_INVALID_INDEX;
 	packet->cp_partial = false;
 
+	/* Send control message directly without accessing msd (Multi-Send
+	 * Data) field which may be changed during data packet processing.
+	 */
+	if (!skb) {
+		cur_send = packet;
+		goto send_now;
+	}
+
 	msdp = &net_device->msd[q_idx];
 
 	/* batch packets in send buffer if possible */
@@ -939,6 +947,7 @@ int netvsc_send(struct hv_device *device,
 		}
 	}
 
+send_now:
 	if (cur_send)
 		ret = netvsc_send_pkt(cur_send, net_device, pb, skb);
 
-- 
1.7.4.1
