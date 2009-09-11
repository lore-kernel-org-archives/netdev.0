From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/5] netxen: change firmware write size
Date: Fri, 11 Sep 2009 14:28:11 -0700
Message-ID: <1252704495-16118-2-git-send-email-dhananjay@netxen.com>
References: <1252704495-16118-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@qlogic.com>,
	Amit Kumar Salecha <amit@netxen.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43917 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756911AbZIKV2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 17:28:13 -0400
In-Reply-To: <1252704495-16118-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@qlogic.com>

Use 8 byte strides for firmware download into card
memory since oncard memory controller needs 8 byte
(64 bit) accesses. This avoids unnecessary rmw cycles.

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_init.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 485b947..8926b0e 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -727,21 +727,28 @@ netxen_load_firmware(struct netxen_adapter *adapter)
 			flashaddr += 8;
 		}
 	} else {
-		u32 data;
+		u64 data;
+		u32 hi, lo;
 
-		size = (NETXEN_IMAGE_START - NETXEN_BOOTLD_START) / 4;
+		size = (NETXEN_IMAGE_START - NETXEN_BOOTLD_START) / 8;
 		flashaddr = NETXEN_BOOTLD_START;
 
 		for (i = 0; i < size; i++) {
 			if (netxen_rom_fast_read(adapter,
-					flashaddr, (int *)&data) != 0)
+					flashaddr, &lo) != 0)
+				return -EIO;
+			if (netxen_rom_fast_read(adapter,
+					flashaddr + 4, &hi) != 0)
 				return -EIO;
 
+			/* hi, lo are already in host endian byteorder */
+			data = (((u64)hi << 32) | lo);
+
 			if (adapter->pci_mem_write(adapter,
-						flashaddr, &data, 4))
+						flashaddr, &data, 8))
 				return -EIO;
 
-			flashaddr += 4;
+			flashaddr += 8;
 		}
 	}
 	msleep(1);
-- 
1.6.0.2

