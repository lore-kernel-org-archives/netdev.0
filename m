From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 7/8] e1000: tune our dynamic itr transmit packet accounting
Date: Fri, 12 Jan 2007 16:37:54 -0800
Message-ID: <20070113003754.16816.93724.stgit@gitlost.site>
References: <20070113003650.16816.34076.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1194 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161170AbXAMAyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jan 2007 19:54:10 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20070113003650.16816.34076.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The driver was still mis-calculating the number of bytes sent during
transmit, now the driver computes what appears to be exactly 100%
correct byte counts (not including CRC) when figuring out how many
bytes and frames were sent during the current transmit packet.
---

 drivers/net/e1000/e1000_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8c6c74d..ae76479 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4020,10 +4020,13 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 
 			if (cleaned) {
 				struct sk_buff *skb = buffer_info->skb;
-				unsigned int segs = skb_shinfo(skb)->gso_segs;
+				unsigned int segs, bytecount;
+				segs = skb_shinfo(skb)->gso_segs ?: 1;
+				/* multiply data chunks by size of headers */
+				bytecount = ((segs - 1) * skb_headlen(skb)) +
+				            skb->len;
 				total_tx_packets += segs;
-				total_tx_packets++;
-				total_tx_bytes += skb->len;
+				total_tx_bytes += bytecount;
 			}
 			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 			tx_desc->upper.data = 0;



---
Auke Kok <auke-jan.h.kok@intel.com>
