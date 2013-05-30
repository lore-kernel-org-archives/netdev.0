From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 2/5] netxen_nic: Log proper error message in case of mismatched adapter type
Date: Thu, 30 May 2013 15:51:35 -0400
Message-ID: <1369943498-1732-3-git-send-email-manish.chopra@qlogic.com>
References: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0187.outbound.messaging.microsoft.com ([213.199.154.187]:7659
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755138Ab3E3URB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 16:17:01 -0400
In-Reply-To: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o log "Unknown" board name and "Unknown" serial number in case
  of mismatched adapter type found. This will avoid weird characters
  logs when an adapter is in bad state or corrupted.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |   10 +++++++---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    4 +++-
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index 322a36b..e5ab1ec 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -1855,7 +1855,7 @@ static const struct netxen_brdinfo netxen_boards[] = {
 
 #define NUM_SUPPORTED_BOARDS ARRAY_SIZE(netxen_boards)
 
-static inline void get_brd_name_by_type(u32 type, char *name)
+static inline int netxen_nic_get_brd_name_by_type(u32 type, char *name)
 {
 	int i, found = 0;
 	for (i = 0; i < NUM_SUPPORTED_BOARDS; ++i) {
@@ -1864,10 +1864,14 @@ static inline void get_brd_name_by_type(u32 type, char *name)
 			found = 1;
 			break;
 		}
+	}
 
+	if (!found) {
+		strcpy(name, "Unknown");
+		return -EINVAL;
 	}
-	if (!found)
-		name = "Unknown";
+
+	return 0;
 }
 
 static inline u32 netxen_tx_avail(struct nx_host_tx_ring *tx_ring)
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 2294cd2..558df46 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -841,7 +841,9 @@ netxen_check_options(struct netxen_adapter *adapter)
 	}
 
 	if (adapter->portnum == 0) {
-		get_brd_name_by_type(adapter->ahw.board_type, brd_name);
+		if (netxen_nic_get_brd_name_by_type(adapter->ahw.board_type,
+						    brd_name))
+			strcpy(serial_num, "Unknown");
 
 		pr_info("%s: %s Board S/N %s  Chip rev 0x%x\n",
 				module_name(THIS_MODULE),
-- 
1.7.1
