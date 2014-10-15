From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net v2 3/4] cxgb4i : Fix -Wunused-function warning
Date: Tue, 14 Oct 2014 20:07:23 -0700
Message-ID: <1413342444-16388-4-git-send-email-anish@chelsio.com>
References: <1413342444-16388-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hch@infradead.org, jbottomley@parallels.com,
	kxie@chelsio.com, manojmalviya@chelsio.com, hariprasad@chelsio.com,
	leedom@chelsio.com, swise@opengridcomputing.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:44192
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755831AbaJODIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 23:08:02 -0400
In-Reply-To: <1413342444-16388-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bunch of ipv6 related code is left on by default. While this causes no
compilation issues, there is no need to have this enabled by default. Guard
with an ipv6 check, which also takes care of a -Wunused-function warning.

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 8 ++++++++
 drivers/scsi/cxgbi/libcxgbi.c      | 2 ++
 2 files changed, 10 insertions(+)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 18d0d1c..df176f0 100644
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
index 6a2001d..54fa6e0 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -275,6 +275,7 @@ struct cxgbi_device *cxgbi_device_find_by_netdev_rcu(struct net_device *ndev,
 }
 EXPORT_SYMBOL_GPL(cxgbi_device_find_by_netdev_rcu);
 
+#if IS_ENABLED(CONFIG_IPV6)
 static struct cxgbi_device *cxgbi_device_find_by_mac(struct net_device *ndev,
 						     int *port)
 {
@@ -307,6 +308,7 @@ static struct cxgbi_device *cxgbi_device_find_by_mac(struct net_device *ndev,
 		  ndev, ndev->name);
 	return NULL;
 }
+#endif
 
 void cxgbi_hbas_remove(struct cxgbi_device *cdev)
 {
-- 
2.1.2
