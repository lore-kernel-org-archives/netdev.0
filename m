From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net] hyperv: Fix the error processing in netvsc_send()
Date: Thu, 29 Jan 2015 12:34:49 -0800
Message-ID: <1422563689-31036-1-git-send-email-haiyangz@microsoft.com>
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

The existing code frees the skb in EAGAIN case, in which the skb will be
retried from upper layer and used again.
Also, the existing code doesn't free send buffer slot in error case, because
there is no completion message for unsent packets.
This patch fixes these problems.

(Please also include this patch for stable trees. Thanks!)

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 9f49c01..7cd4eb3 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -716,7 +716,7 @@ int netvsc_send(struct hv_device *device,
 	u64 req_id;
 	unsigned int section_index = NETVSC_INVALID_INDEX;
 	u32 msg_size = 0;
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	u16 q_idx = packet->q_idx;
 
 
@@ -743,8 +743,6 @@ int netvsc_send(struct hv_device *device,
 							   packet);
 			skb = (struct sk_buff *)
 			      (unsigned long)packet->send_completion_tid;
-			if (skb)
-				dev_kfree_skb_any(skb);
 			packet->page_buf_cnt = 0;
 		}
 	}
@@ -810,6 +808,13 @@ int netvsc_send(struct hv_device *device,
 			   packet, ret);
 	}
 
+	if (ret != 0) {
+		if (section_index != NETVSC_INVALID_INDEX)
+			netvsc_free_send_slot(net_device, section_index);
+	} else if (skb) {
+		dev_kfree_skb_any(skb);
+	}
+
 	return ret;
 }
 
-- 
1.7.4.1
