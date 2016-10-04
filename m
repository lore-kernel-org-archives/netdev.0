From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 5/8] net/ncsi: Allow to extend NCSI request properties
Date: Tue,  4 Oct 2016 11:25:51 +1100
Message-ID: <1475540754-31169-6-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:54201 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752147AbcJDAZ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 20:25:29 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u940MqKX094562
        for <netdev@vger.kernel.org>; Mon, 3 Oct 2016 20:25:28 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25uy9jw0dj-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 20:25:28 -0400
Received: from localhost
        by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 4 Oct 2016 10:25:25 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id 9B3EE2CE8059
        for <netdev@vger.kernel.org>; Tue,  4 Oct 2016 11:25:22 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u940PM9x197044
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:22 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
        by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u940PLfW028543
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:22 +1100
In-Reply-To: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is only one NCSI request property for now: the response for
the sent command need drive the workqueue or not. So we had one
field (@driven) for the purpose. We lost the flexibility to extend
NCSI request properties.

This replaces @driven with @flags and @req_flags in NCSI request
and NCSI command argument struct. Each bit of the newly introduced
field can be used for one property. No functional changes introduced.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Reviewed-by: Joel Stanley <joel@jms.id.au>
---
 net/ncsi/internal.h    |  8 +++++---
 net/ncsi/ncsi-cmd.c    |  2 +-
 net/ncsi/ncsi-manage.c | 19 ++++++++++---------
 net/ncsi/ncsi-rsp.c    |  2 +-
 4 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index c956fe8..26e9295 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -207,7 +207,8 @@ struct ncsi_package {
 struct ncsi_request {
 	unsigned char        id;      /* Request ID - 0 to 255           */
 	bool                 used;    /* Request that has been assigned  */
-	bool                 driven;  /* Drive state machine             */
+	unsigned int         flags;   /* NCSI request property           */
+#define NCSI_REQ_FLAG_EVENT_DRIVEN	1
 	struct ncsi_dev_priv *ndp;    /* Associated NCSI device          */
 	struct sk_buff       *cmd;    /* Associated NCSI command packet  */
 	struct sk_buff       *rsp;    /* Associated NCSI response packet */
@@ -276,7 +277,7 @@ struct ncsi_cmd_arg {
 	unsigned char        package;     /* Destination package ID        */
 	unsigned char        channel;     /* Detination channel ID or 0x1f */
 	unsigned short       payload;     /* Command packet payload length */
-	bool                 driven;      /* Drive the state machine?      */
+	unsigned int         req_flags;   /* NCSI request properties       */
 	union {
 		unsigned char  bytes[16]; /* Command packet specific data  */
 		unsigned short words[8];
@@ -315,7 +316,8 @@ void ncsi_find_package_and_channel(struct ncsi_dev_priv *ndp,
 				   unsigned char id,
 				   struct ncsi_package **np,
 				   struct ncsi_channel **nc);
-struct ncsi_request *ncsi_alloc_request(struct ncsi_dev_priv *ndp, bool driven);
+struct ncsi_request *ncsi_alloc_request(struct ncsi_dev_priv *ndp,
+					unsigned int req_flags);
 void ncsi_free_request(struct ncsi_request *nr);
 struct ncsi_dev *ncsi_find_dev(struct net_device *dev);
 int ncsi_process_next_channel(struct ncsi_dev_priv *ndp);
diff --git a/net/ncsi/ncsi-cmd.c b/net/ncsi/ncsi-cmd.c
index 21057a8..db7083b 100644
--- a/net/ncsi/ncsi-cmd.c
+++ b/net/ncsi/ncsi-cmd.c
@@ -272,7 +272,7 @@ static struct ncsi_request *ncsi_alloc_command(struct ncsi_cmd_arg *nca)
 	struct sk_buff *skb;
 	struct ncsi_request *nr;
 
-	nr = ncsi_alloc_request(ndp, nca->driven);
+	nr = ncsi_alloc_request(ndp, nca->req_flags);
 	if (!nr)
 		return NULL;
 
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 00ce2c7..adf5401 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -194,7 +194,7 @@ static void ncsi_channel_monitor(unsigned long data)
 		nca.package = np->id;
 		nca.channel = nc->id;
 		nca.type = NCSI_PKT_CMD_GLS;
-		nca.driven = false;
+		nca.req_flags = 0;
 		ret = ncsi_xmit_cmd(&nca);
 		if (ret) {
 			netdev_err(ndp->ndev.dev, "Error %d sending GLS\n",
@@ -419,7 +419,8 @@ void ncsi_find_package_and_channel(struct ncsi_dev_priv *ndp,
  * be same. Otherwise, the bogus response might be replied. So
  * the available IDs are allocated in round-robin fashion.
  */
-struct ncsi_request *ncsi_alloc_request(struct ncsi_dev_priv *ndp, bool driven)
+struct ncsi_request *ncsi_alloc_request(struct ncsi_dev_priv *ndp,
+					unsigned int req_flags)
 {
 	struct ncsi_request *nr = NULL;
 	int i, limit = ARRAY_SIZE(ndp->requests);
@@ -433,7 +434,7 @@ struct ncsi_request *ncsi_alloc_request(struct ncsi_dev_priv *ndp, bool driven)
 
 		nr = &ndp->requests[i];
 		nr->used = true;
-		nr->driven = driven;
+		nr->flags = req_flags;
 		ndp->request_id = i + 1;
 		goto found;
 	}
@@ -445,7 +446,7 @@ struct ncsi_request *ncsi_alloc_request(struct ncsi_dev_priv *ndp, bool driven)
 
 		nr = &ndp->requests[i];
 		nr->used = true;
-		nr->driven = driven;
+		nr->flags = req_flags;
 		ndp->request_id = i + 1;
 		goto found;
 	}
@@ -473,7 +474,7 @@ void ncsi_free_request(struct ncsi_request *nr)
 	nr->cmd = NULL;
 	nr->rsp = NULL;
 	nr->used = false;
-	driven = nr->driven;
+	driven = !!(nr->flags & NCSI_REQ_FLAG_EVENT_DRIVEN);
 	spin_unlock_irqrestore(&ndp->lock, flags);
 
 	if (driven && cmd && --ndp->pending_req_num == 0)
@@ -527,7 +528,7 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 	int ret;
 
 	nca.ndp = ndp;
-	nca.driven = true;
+	nca.req_flags = NCSI_REQ_FLAG_EVENT_DRIVEN;
 	switch (nd->state) {
 	case ncsi_dev_state_suspend:
 		nd->state = ncsi_dev_state_suspend_select;
@@ -596,7 +597,7 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
 	int ret;
 
 	nca.ndp = ndp;
-	nca.driven = true;
+	nca.req_flags = NCSI_REQ_FLAG_EVENT_DRIVEN;
 	switch (nd->state) {
 	case ncsi_dev_state_config:
 	case ncsi_dev_state_config_sp:
@@ -825,7 +826,7 @@ static void ncsi_probe_channel(struct ncsi_dev_priv *ndp)
 	int ret;
 
 	nca.ndp = ndp;
-	nca.driven = true;
+	nca.req_flags = NCSI_REQ_FLAG_EVENT_DRIVEN;
 	switch (nd->state) {
 	case ncsi_dev_state_probe:
 		nd->state = ncsi_dev_state_probe_deselect;
@@ -1101,7 +1102,7 @@ static int ncsi_inet6addr_event(struct notifier_block *this,
 		return NOTIFY_OK;
 
 	nca.ndp = ndp;
-	nca.driven = false;
+	nca.req_flags = 0;
 	nca.package = np->id;
 	nca.channel = nc->id;
 	nca.dwords[0] = nc->caps[NCSI_CAP_MC].cap;
diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index af84389..86cdaeb 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -317,7 +317,7 @@ static int ncsi_rsp_handler_gls(struct ncsi_request *nr)
 	ncm->data[3] = ntohl(rsp->other);
 	ncm->data[4] = ntohl(rsp->oem_status);
 
-	if (nr->driven)
+	if (nr->flags & NCSI_REQ_FLAG_EVENT_DRIVEN)
 		return 0;
 
 	/* Reset the channel monitor if it has been enabled */
-- 
2.1.0
