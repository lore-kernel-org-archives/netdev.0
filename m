From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/4] e1000: remove workaround for Errata 23 from jumbo alloc
Date: Thu, 17 May 2012 04:27:48 -0700
Message-ID: <1337254070-32500-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1337254070-32500-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40139 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761647Ab2EQL1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 07:27:54 -0400
In-Reply-To: <1337254070-32500-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

According to the comment, errata 23 says that the memory we allocate
can't cross a 64KiB boundary. In case of jumbo frames we allocate
complete pages which can never cross the 64KiB boundary because
PAGE_SIZE should be a multiple of 64KiB so we stop either before the
boundary or start after it but never cross it. Furthermore the check
seems bogus because it looks at skb->data which is not seen by the HW
at all because we only pass the DMA address of the page we allocated. So
I *think* the workaround is not required here.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   24 ------------------------
 1 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index f1aef68..fefbf4d 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4391,30 +4391,6 @@ e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
 			break;
 		}
 
-		/* Fix for errata 23, can't cross 64kB boundary */
-		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
-			struct sk_buff *oldskb = skb;
-			e_err(rx_err, "skb align check failed: %u bytes at "
-			      "%p\n", bufsz, skb->data);
-			/* Try again, without freeing the previous */
-			skb = netdev_alloc_skb_ip_align(netdev, bufsz);
-			/* Failed allocation, critical failure */
-			if (!skb) {
-				dev_kfree_skb(oldskb);
-				adapter->alloc_rx_buff_failed++;
-				break;
-			}
-
-			if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
-				/* give up */
-				dev_kfree_skb(skb);
-				dev_kfree_skb(oldskb);
-				break; /* while (cleaned_count--) */
-			}
-
-			/* Use new allocation */
-			dev_kfree_skb(oldskb);
-		}
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
 check_page:
-- 
1.7.7.6
