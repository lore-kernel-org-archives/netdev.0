From: Vineeth Remanan Pillai <vineethp@amazon.com>
Subject: [PATCH v2] xen-netfront: Fix Rx stall during network stress and OOM
Date: Thu, 19 Jan 2017 08:35:39 -0800
Message-ID: <66b10c64-936a-8001-6855-2ff1ed626642@amazon.com>
References: <1484771149-12699-1-git-send-email-vineethp@u480fcf3b67f557f68df1.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <vineethp@amazon.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484771149-12699-1-git-send-email-vineethp@u480fcf3b67f557f68df1.ant.amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vineeth Remanan Pillai <vineethp@amazon.com>

During an OOM scenario, request slots could not be created as skb
allocation fails. So the netback cannot pass in packets and netfront
wrongly assumes that there is no more work to be done and it disables
polling. This causes Rx to stall.

The issue is with the retry logic which schedules the timer if the
created slots are less than NET_RX_SLOTS_MIN. The count of new request
slots to be pushed are calculated as a difference between new req_prod
and rsp_cons which could be more than the actual slots, if there are
unconsumed responses.

The fix is to calculate the count of newly created slots as the
difference between new req_prod and old req_prod.

Signed-off-by: Vineeth Remanan Pillai <vineethp@amazon.com>
Reviewed-by: Juergen Gross <jgross@suse.com>
---
Changes in v2:
	- Removed the old implementation of enabling polling on
	  skb allocation error.
	- Corrected the refill timer logic to schedule when newly
	  created slots since last push is less than NET_RX_SLOTS_MIN.

  drivers/net/xen-netfront.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 40f26b6..2c7c29f 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -321,7 +321,7 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
  	queue->rx.req_prod_pvt = req_prod;
  
  	/* Not enough requests? Try again later. */
-	if (req_prod - queue->rx.rsp_cons < NET_RX_SLOTS_MIN) {
+	if (req_prod - queue->rx.sring->req_prod < NET_RX_SLOTS_MIN) {
  		mod_timer(&queue->rx_refill_timer, jiffies + (HZ/10));
  		return;
  	}
-- 
2.7.4
