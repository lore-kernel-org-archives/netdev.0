From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/9] cnic: Fix iSCSI TCP port endian order.
Date: Thu, 23 Dec 2010 09:42:56 -0800
Message-ID: <1293126184-13097-2-git-send-email-mchan@broadcom.com>
References: <1293126184-13097-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2734 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753649Ab0LWSkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 13:40:35 -0500
In-Reply-To: <1293126184-13097-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass the TCP port parameter for iSCSI connections to the firmware in
proper endian order.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   23 +++++++++++++----------
 drivers/net/cnic.h |    2 +-
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 594ca9c..9c2e786 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2883,7 +2883,7 @@ static void cnic_cm_cleanup(struct cnic_sock *csk)
 		struct cnic_dev *dev = csk->dev;
 		struct cnic_local *cp = dev->cnic_priv;
 
-		cnic_free_id(&cp->csk_port_tbl, csk->src_port);
+		cnic_free_id(&cp->csk_port_tbl, be16_to_cpu(csk->src_port));
 		csk->src_port = 0;
 	}
 }
@@ -3014,7 +3014,8 @@ static int cnic_get_route(struct cnic_sock *csk, struct cnic_sockaddr *saddr)
 	int is_v6, rc = 0;
 	struct dst_entry *dst = NULL;
 	struct net_device *realdev;
-	u32 local_port;
+	__be16 local_port;
+	u32 port_id;
 
 	if (saddr->local.v6.sin6_family == AF_INET6 &&
 	    saddr->remote.v6.sin6_family == AF_INET6)
@@ -3054,19 +3055,21 @@ static int cnic_get_route(struct cnic_sock *csk, struct cnic_sockaddr *saddr)
 		}
 	}
 
-	if (local_port >= CNIC_LOCAL_PORT_MIN &&
-	    local_port < CNIC_LOCAL_PORT_MAX) {
-		if (cnic_alloc_id(&cp->csk_port_tbl, local_port))
-			local_port = 0;
+	port_id = be16_to_cpu(local_port);
+	if (port_id >= CNIC_LOCAL_PORT_MIN &&
+	    port_id < CNIC_LOCAL_PORT_MAX) {
+		if (cnic_alloc_id(&cp->csk_port_tbl, port_id))
+			port_id = 0;
 	} else
-		local_port = 0;
+		port_id = 0;
 
-	if (!local_port) {
-		local_port = cnic_alloc_new_id(&cp->csk_port_tbl);
-		if (local_port == -1) {
+	if (!port_id) {
+		port_id = cnic_alloc_new_id(&cp->csk_port_tbl);
+		if (port_id == -1) {
 			rc = -ENOMEM;
 			goto err_out;
 		}
+		local_port = cpu_to_be16(port_id);
 	}
 	csk->src_port = local_port;
 
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 6a4a0ae..bf38e57 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -82,7 +82,7 @@ struct cnic_redirect_entry {
 #define MAX_ISCSI_TBL_SZ	256
 
 #define CNIC_LOCAL_PORT_MIN	60000
-#define CNIC_LOCAL_PORT_MAX	61000
+#define CNIC_LOCAL_PORT_MAX	61024
 #define CNIC_LOCAL_PORT_RANGE	(CNIC_LOCAL_PORT_MAX - CNIC_LOCAL_PORT_MIN)
 
 #define KWQE_CNT (BCM_PAGE_SIZE / sizeof(struct kwqe))
-- 
1.6.4.GIT


