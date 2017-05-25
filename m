From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix rare pci_driver.probe failure of VF
 driver
Date: Thu, 25 May 2017 10:42:14 -0700
Message-ID: <20170525174214.GA1444@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        prasad.kanneganti@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0074.outbound.protection.outlook.com ([104.47.37.74]:9486
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S966879AbdEYRmh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 13:42:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasad Kanneganti <prasad.kanneganti@cavium.com>

There's a rare pci_driver.probe failure of the VF driver that's caused by
PF/VF handshake going out of sync.  The culprit is octeon_mbox_write() who
ignores an ack timeout condition; it just keeps unconditionally writing all
elements of mbox_cmd->data[] even when the other side is not ready for
them.  Fix it by making each write of mbox_cmd->data[i] conditional to
having previously received an ack.

Also fix the octeon_mbox_state enum such that each state gets a unique
value.  Also add ULL suffix to numeric literals in macro definitions.

Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c |  5 ++++-
 drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h | 12 ++++++------
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
index 5cca73b..57af7df 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
@@ -178,7 +178,10 @@ int octeon_mbox_write(struct octeon_device *oct,
 					break;
 				}
 			}
-			writeq(mbox_cmd->data[i], mbox->mbox_write_reg);
+			if (ret == OCTEON_MBOX_STATUS_SUCCESS)
+				writeq(mbox_cmd->data[i], mbox->mbox_write_reg);
+			else
+				break;
 		}
 	}
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h
index c9376fe..1def22a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h
@@ -20,16 +20,16 @@
 
 /* Macros for Mail Box Communication */
 
-#define OCTEON_MBOX_DATA_MAX	32
+#define OCTEON_MBOX_DATA_MAX		32
 
 #define OCTEON_VF_ACTIVE		0x1
 #define OCTEON_VF_FLR_REQUEST		0x2
 #define OCTEON_PF_CHANGED_VF_MACADDR	0x4
 
 /*Macro for Read acknowldgement*/
-#define OCTEON_PFVFACK			0xffffffffffffffff
-#define OCTEON_PFVFSIG			0x1122334455667788
-#define OCTEON_PFVFERR			0xDEADDEADDEADDEAD
+#define OCTEON_PFVFACK			0xffffffffffffffffULL
+#define OCTEON_PFVFSIG			0x1122334455667788ULL
+#define OCTEON_PFVFERR			0xDEADDEADDEADDEADULL
 
 #define LIO_MBOX_WRITE_WAIT_CNT         1000
 #define LIO_MBOX_WRITE_WAIT_TIME        msecs_to_jiffies(1)
@@ -74,8 +74,8 @@ enum octeon_mbox_state {
 	OCTEON_MBOX_STATE_REQUEST_RECEIVED = 4,
 	OCTEON_MBOX_STATE_RESPONSE_PENDING = 8,
 	OCTEON_MBOX_STATE_RESPONSE_RECEIVING = 16,
-	OCTEON_MBOX_STATE_RESPONSE_RECEIVED = 16,
-	OCTEON_MBOX_STATE_ERROR = 32
+	OCTEON_MBOX_STATE_RESPONSE_RECEIVED = 32,
+	OCTEON_MBOX_STATE_ERROR = 64
 };
 
 struct octeon_mbox {
