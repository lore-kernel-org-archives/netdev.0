From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 1/2] cxgb3 - Notify fatal errors
Date: Mon, 26 Jan 2009 09:46:05 -0800
Message-ID: <20090126174605.29703.40342.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, wenxiong@us.ibm.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:6738 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751845AbZAZRqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 12:46:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Set up a notification mechanism to inform upper layer modules
(iWARP, iSCSI) of a chip reset due to an EEH event or a fatal error.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c    |   13 +++++++++----
 drivers/net/cxgb3/cxgb3_offload.c |   12 ++++++++++++
 drivers/net/cxgb3/cxgb3_offload.h |    7 +++++++
 3 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 7381f37..f2c7cc3 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2542,6 +2542,12 @@ static int t3_adapter_error(struct adapter *adapter, int reset)
 {
 	int i, ret = 0;
 
+	if (is_offload(adapter) &&
+	    test_bit(OFFLOAD_DEVMAP_BIT, &adapter->open_device_map)) {
+		cxgb3_err_notify(&adapter->tdev, OFFLOAD_STATUS_DOWN, 0);
+		offload_close(&adapter->tdev);
+	}
+
 	/* Stop all ports */
 	for_each_port(adapter, i) {
 		struct net_device *netdev = adapter->port[i];
@@ -2550,10 +2556,6 @@ static int t3_adapter_error(struct adapter *adapter, int reset)
 			cxgb_close(netdev);
 	}
 
-	if (is_offload(adapter) &&
-	    test_bit(OFFLOAD_DEVMAP_BIT, &adapter->open_device_map))
-		offload_close(&adapter->tdev);
-
 	/* Stop SGE timers */
 	t3_stop_sge_timers(adapter);
 
@@ -2605,6 +2607,9 @@ static void t3_resume_ports(struct adapter *adapter)
 			}
 		}
 	}
+
+	if (is_offload(adapter) && !ofld_disable)
+		cxgb3_err_notify(&adapter->tdev, OFFLOAD_STATUS_UP, 0);
 }
 
 /*
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 2d7f69a..620d80b 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -153,6 +153,18 @@ void cxgb3_remove_clients(struct t3cdev *tdev)
 	mutex_unlock(&cxgb3_db_lock);
 }
 
+void cxgb3_err_notify(struct t3cdev *tdev, u32 status, u32 error)
+{
+	struct cxgb3_client *client;
+
+	mutex_lock(&cxgb3_db_lock);
+	list_for_each_entry(client, &client_list, client_list) {
+		if (client->err_handler)
+			client->err_handler(tdev, status, error);
+	}
+	mutex_unlock(&cxgb3_db_lock);
+}
+
 static struct net_device *get_iff_from_mac(struct adapter *adapter,
 					   const unsigned char *mac,
 					   unsigned int vlan)
diff --git a/drivers/net/cxgb3/cxgb3_offload.h b/drivers/net/cxgb3/cxgb3_offload.h
index d514e50..a8e8e5f 100644
--- a/drivers/net/cxgb3/cxgb3_offload.h
+++ b/drivers/net/cxgb3/cxgb3_offload.h
@@ -64,10 +64,16 @@ void cxgb3_register_client(struct cxgb3_client *client);
 void cxgb3_unregister_client(struct cxgb3_client *client);
 void cxgb3_add_clients(struct t3cdev *tdev);
 void cxgb3_remove_clients(struct t3cdev *tdev);
+void cxgb3_err_notify(struct t3cdev *tdev, u32 status, u32 error);
 
 typedef int (*cxgb3_cpl_handler_func)(struct t3cdev *dev,
 				      struct sk_buff *skb, void *ctx);
 
+enum {
+	OFFLOAD_STATUS_UP,
+	OFFLOAD_STATUS_DOWN
+};
+
 struct cxgb3_client {
 	char *name;
 	void (*add) (struct t3cdev *);
@@ -76,6 +82,7 @@ struct cxgb3_client {
 	int (*redirect)(void *ctx, struct dst_entry *old,
 			struct dst_entry *new, struct l2t_entry *l2t);
 	struct list_head client_list;
+	void (*err_handler)(struct t3cdev *tdev, u32 status, u32 error);
 };
 
 /*

