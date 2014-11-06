From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 2/2] amd-xgbe: Check for complete packet on skb
 allocation error
Date: Thu, 6 Nov 2014 17:02:19 -0600
Message-ID: <20141106230219.21973.44275.stgit@tlendack-t1.amdoffice.net>
References: <20141106230207.21973.67338.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0115.outbound.protection.outlook.com ([207.46.100.115]:64640
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753280AbaKFXCZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2014 18:02:25 -0500
In-Reply-To: <20141106230207.21973.67338.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the skb allocation fails during receive processing, the driver would
continue reading descriptors without first determining if there were
any more descriptors for the current packet. Update the code to check
whether more descriptors are associated with the current packet or
whether to move on to the next descriptor as a new packet.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index ec5fff3..0544931 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1908,7 +1908,7 @@ read_again:
 				skb = xgbe_create_skb(pdata, rdata, &put_len);
 				if (!skb) {
 					error = 1;
-					goto read_again;
+					goto skip_data;
 				}
 			}
 
@@ -1926,10 +1926,10 @@ read_again:
 			}
 		}
 
+skip_data:
 		if (incomplete || context_next)
 			goto read_again;
 
-		/* Stray Context Descriptor? */
 		if (!skb)
 			goto next_packet;
 
