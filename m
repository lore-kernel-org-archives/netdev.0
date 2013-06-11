From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH v3 net 4/5] vxlan: fix crash from work pending on module
 removal
Date: Mon, 10 Jun 2013 17:37:20 -0700
Message-ID: <20130610173720.574ad41d@nehalam.linuxnetplumber.net>
References: <20130611002547.346603375@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:37566 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754443Ab3FKAhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 20:37:42 -0400
Received: by mail-pd0-f181.google.com with SMTP id 14so5301090pdj.40
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 17:37:42 -0700 (PDT)
In-Reply-To: <20130611002547.346603375@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch to using a per module work queue so that all the socket
deletion callbacks are done when module is removed.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
v3 - get rid of destroy_workqueue that snuck in from later patch

Only impacts -net and later; del_work was first introduced 3.10


--- a/drivers/net/vxlan.c	2013-06-10 15:10:11.603785773 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 15:10:43.271357218 -0700
@@ -148,6 +148,7 @@ struct vxlan_dev {
 
 /* salt for hash table */
 static u32 vxlan_salt __read_mostly;
+static struct workqueue_struct *vxlan_wq;
 
 /* Virtual Network hash table head */
 static inline struct hlist_head *vni_head(struct vxlan_sock *vs, u32 id)
@@ -1645,7 +1646,7 @@ static void vxlan_dellink(struct net_dev
 
 	if (--vs->refcnt == 0) {
 		hlist_del_rcu(&vs->hlist);
-		schedule_work(&vs->del_work);
+		queue_work(vxlan_wq, &vs->del_work);
 	}
 }
 
@@ -1764,6 +1765,10 @@ static int __init vxlan_init_module(void
 {
 	int rc;
 
+	vxlan_wq = alloc_workqueue("vxlan", 0, 0);
+	if (!vxlan_wq)
+		return -ENOMEM;
+
 	get_random_bytes(&vxlan_salt, sizeof(vxlan_salt));
 
 	rc = register_pernet_device(&vxlan_net_ops);
@@ -1779,6 +1784,7 @@ static int __init vxlan_init_module(void
 out2:
 	unregister_pernet_device(&vxlan_net_ops);
 out1:
+	destroy_workqueue(vxlan_wq);
 	return rc;
 }
 late_initcall(vxlan_init_module);
@@ -1787,6 +1793,7 @@ static void __exit vxlan_cleanup_module(
 {
 	unregister_pernet_device(&vxlan_net_ops);
 	rtnl_link_unregister(&vxlan_link_ops);
+	destroy_workqueue(vxlan_wq);
 	rcu_barrier();
 }
 module_exit(vxlan_cleanup_module);
