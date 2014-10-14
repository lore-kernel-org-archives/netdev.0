From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net 3/4] cxgb4i : All this code is only needed when IPV6 is enabled, disable when not required, also fixes -Wunused-function warning
Date: Tue, 14 Oct 2014 15:13:10 -0700
Message-ID: <1413324791-12104-4-git-send-email-anish@chelsio.com>
References: <1413324791-12104-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
	kxie@chelsio.com, manojmalviya@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43768
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932569AbaJNWNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 18:13:50 -0400
In-Reply-To: <1413324791-12104-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 8 ++++++++
 drivers/scsi/cxgbi/libcxgbi.c      | 2 ++
 2 files changed, 10 insertions(+)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 18d0d1c145ad..df176f0e5e60 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -259,6 +259,7 @@ static void send_act_open_req(struct cxgbi_sock *csk, struct sk_buff *skb,
 	cxgb4_l2t_send(csk->cdev->ports[csk->port_id], skb, csk->l2t);
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
 static void send_act_open_req6(struct cxgbi_sock *csk, struct sk_buff *skb,
 			       struct l2t_entry *e)
 {
@@ -344,6 +345,7 @@ static void send_act_open_req6(struct cxgbi_sock *csk, struct sk_buff *skb,
 
 	cxgb4_l2t_send(csk->cdev->ports[csk->port_id], skb, csk->l2t);
 }
+#endif
 
 static void send_close_req(struct cxgbi_sock *csk)
 {
@@ -781,9 +783,11 @@ static void csk_act_open_retry_timer(unsigned long data)
 	if (csk->csk_family == AF_INET) {
 		send_act_open_func = send_act_open_req;
 		skb = alloc_wr(size, 0, GFP_ATOMIC);
+#if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		send_act_open_func = send_act_open_req6;
 		skb = alloc_wr(size6, 0, GFP_ATOMIC);
+#endif
 	}
 
 	if (!skb)
@@ -1335,8 +1339,10 @@ static int init_act_open(struct cxgbi_sock *csk)
 
 	if (csk->csk_family == AF_INET)
 		skb = alloc_wr(size, 0, GFP_NOIO);
+#if IS_ENABLED(CONFIG_IPV6)
 	else
 		skb = alloc_wr(size6, 0, GFP_NOIO);
+#endif
 
 	if (!skb)
 		goto rel_resource;
@@ -1370,8 +1376,10 @@ static int init_act_open(struct cxgbi_sock *csk)
 	cxgbi_sock_set_state(csk, CTP_ACTIVE_OPEN);
 	if (csk->csk_family == AF_INET)
 		send_act_open_req(csk, skb, csk->l2t);
+#if IS_ENABLED(CONFIG_IPV6)
 	else
 		send_act_open_req6(csk, skb, csk->l2t);
+#endif
 	neigh_release(n);
 
 	return 0;
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index d65df6dc106f..64fcb1eea0af 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -230,6 +230,7 @@ struct cxgbi_device *cxgbi_device_find_by_netdev(struct net_device *ndev,
 }
 EXPORT_SYMBOL_GPL(cxgbi_device_find_by_netdev);
 
+#if IS_ENABLED(CONFIG_IPV6)
 static struct cxgbi_device *cxgbi_device_find_by_mac(struct net_device *ndev,
 						     int *port)
 {
@@ -262,6 +263,7 @@ static struct cxgbi_device *cxgbi_device_find_by_mac(struct net_device *ndev,
 		  ndev, ndev->name);
 	return NULL;
 }
+#endif
 
 void cxgbi_hbas_remove(struct cxgbi_device *cdev)
 {
-- 
2.1.2
