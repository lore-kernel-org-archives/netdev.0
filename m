From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/3] netxen: fix context deletion sequence
Date: Fri, 17 Jul 2009 18:27:06 -0700
Message-ID: <1247880428-4895-2-git-send-email-dhananjay@netxen.com>
References: <1247880428-4895-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:44300 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751674AbZGRB1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2009 21:27:10 -0400
In-Reply-To: <1247880428-4895-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Use D3 reset context deletion for NX2031, it cleans up
  more resources in the firmware.
o Release rx buffers after hardware context has been reset.
o Delete tx context after rx context, some firmware control
  commands are sent on tx context, so it should be the last
  to go.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    1 +
 drivers/net/netxen/netxen_nic_ctx.c  |   13 +++++++------
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index e1cdba7..9fa71fa 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -210,6 +210,7 @@
 #define NETXEN_CTX_SIGNATURE	0xdee0
 #define NETXEN_CTX_SIGNATURE_V2	0x0002dee0
 #define NETXEN_CTX_RESET	0xbad0
+#define NETXEN_CTX_D3_RESET	0xacc0
 #define NETXEN_RCV_PRODUCER(ringid)	(ringid)
 
 #define PHAN_PEG_RCV_INITIALIZED	0xff01
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 4754f5c..9f8ae47 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -684,10 +684,8 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 			goto err_out_free;
 	} else {
 		err = netxen_init_old_ctx(adapter);
-		if (err) {
-			netxen_free_hw_resources(adapter);
-			return err;
-		}
+		if (err)
+			goto err_out_free;
 	}
 
 	return 0;
@@ -708,15 +706,18 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 	int port = adapter->portnum;
 
 	if (adapter->fw_major >= 4) {
-		nx_fw_cmd_destroy_tx_ctx(adapter);
 		nx_fw_cmd_destroy_rx_ctx(adapter);
+		nx_fw_cmd_destroy_tx_ctx(adapter);
 	} else {
 		netxen_api_lock(adapter);
 		NXWR32(adapter, CRB_CTX_SIGNATURE_REG(port),
-				NETXEN_CTX_RESET | port);
+				NETXEN_CTX_D3_RESET | port);
 		netxen_api_unlock(adapter);
 	}
 
+	/* Allow dma queues to drain after context reset */
+	msleep(20);
+
 	recv_ctx = &adapter->recv_ctx;
 
 	if (recv_ctx->hwctx != NULL) {
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 27539dd..9a7c4c8 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -943,8 +943,8 @@ err_out_free_sw:
 static void
 netxen_nic_detach(struct netxen_adapter *adapter)
 {
-	netxen_release_rx_buffers(adapter);
 	netxen_free_hw_resources(adapter);
+	netxen_release_rx_buffers(adapter);
 	netxen_nic_free_irq(adapter);
 	netxen_free_sw_resources(adapter);
 
-- 
1.6.0.2

