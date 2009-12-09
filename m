From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/4] netxen: fix tx timeout recovery
Date: Tue,  8 Dec 2009 22:40:55 -0800
Message-ID: <1260340857-11487-3-git-send-email-amit.salecha@qlogic.com>
References: <1260340857-11487-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:53143 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755981AbZLIGkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2009 01:40:51 -0500
In-Reply-To: <1260340857-11487-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o In case of tx timeout, firmare may be healthy, but some pci-func may
  see no response from it. Force firmware reset, if some pci-func
  explicitly requests so.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_init.c |    3 +++
 drivers/net/netxen/netxen_nic_main.c |    4 +++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 02f8d4b..ba62411 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -778,6 +778,9 @@ netxen_need_fw_reset(struct netxen_adapter *adapter)
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
 		return 1;
 
+	if (adapter->need_fw_reset)
+		return 1;
+
 	/* last attempt had failed */
 	if (NXRD32(adapter, CRB_CMDPEG_STATE) == PHAN_INITIALIZE_FAILED)
 		return 1;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6a51ca3..37a64dc 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -2282,8 +2282,10 @@ netxen_check_health(struct netxen_adapter *adapter)
 	}
 
 	state = NXRD32(adapter, NX_CRB_DEV_STATE);
-	if (state == NX_DEV_NEED_RESET)
+	if (state == NX_DEV_NEED_RESET) {
+		adapter->need_fw_reset = 1;
 		goto detach;
+	}
 
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
 		return 0;
-- 
1.6.0.2

