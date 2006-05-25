From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/3] ixgb: use rx copybreak/skb recycle
Date: Thu, 25 May 2006 13:26:33 -0700
Message-ID: <20060525202633.25618.38259.stgit@gitlost.site>
References: <20060525202532.25618.58162.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:15622 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751258AbWEYUVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 16:21:31 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060525202532.25618.58162.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


o use rx copybreak/skb recycle

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 27034b3..0e23994 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1990,6 +1990,26 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 			goto rxdesc_done;
 		}
 
+		/* code added for copybreak, this should improve
+		 * performance for small packets with large amounts
+		 * of reassembly being done in the stack */
+#define IXGB_CB_LENGTH 256
+		if (length < IXGB_CB_LENGTH) {
+			struct sk_buff *new_skb =
+			    dev_alloc_skb(length + NET_IP_ALIGN);
+			if (new_skb) {
+				skb_reserve(new_skb, NET_IP_ALIGN);
+				new_skb->dev = netdev;
+				memcpy(new_skb->data - NET_IP_ALIGN,
+				       skb->data - NET_IP_ALIGN,
+				       length + NET_IP_ALIGN);
+				/* save the skb in buffer_info as good */
+				buffer_info->skb = skb;
+				skb = new_skb;
+			}
+		}
+		/* end copybreak code */
+
 		/* Good Receive */
 		skb_put(skb, length);
 



--
Auke Kok <auke-jan.h.kok@intel.com>
