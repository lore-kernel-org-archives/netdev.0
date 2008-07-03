From: Patrick McHardy <kaber@trash.net>
Subject: bridge 02/06: Use STP demux
Date: Thu,  3 Jul 2008 19:04:44 +0200 (MEST)
Message-ID: <20080703170444.6650.33738.sendpatchset@localhost.localdomain>
References: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>
Cc: shemminger@vyatta.com, Patrick McHardy <kaber@trash.net>,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42849 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbYGCREp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 13:04:45 -0400
In-Reply-To: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Use STP demux

Use the STP demux layer for receiving STP PDUs instead of directly
registering with LLC.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 85ecc2934a05203a4f6372cd8f0b132c2d1f2f97
tree 331543d774aa6897e5902576b337515cfe70eb9c
parent 6c0be0e52a154f1991c221a6f60c6b9be71a10c8
author Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 18:06:07 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 18:06:07 +0200

 net/bridge/Kconfig       |    1 +
 net/bridge/br.c          |   16 +++++++++-------
 net/bridge/br_private.h  |    5 +++--
 net/bridge/br_stp_bpdu.c |   12 +++---------
 4 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/net/bridge/Kconfig b/net/bridge/Kconfig
index 12265af..e143ca6 100644
--- a/net/bridge/Kconfig
+++ b/net/bridge/Kconfig
@@ -5,6 +5,7 @@
 config BRIDGE
 	tristate "802.1d Ethernet Bridging"
 	select LLC
+	select STP
 	---help---
 	  If you say Y here, then your Linux box will be able to act as an
 	  Ethernet bridge, which means that the different Ethernet segments it
diff --git a/net/bridge/br.c b/net/bridge/br.c
index cede010..573acdf 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -18,21 +18,24 @@
 #include <linux/init.h>
 #include <linux/llc.h>
 #include <net/llc.h>
+#include <net/stp.h>
 
 #include "br_private.h"
 
 int (*br_should_route_hook)(struct sk_buff *skb);
 
-static struct llc_sap *br_stp_sap;
+static const struct stp_proto br_stp_proto = {
+	.rcv	= br_stp_rcv,
+};
 
 static int __init br_init(void)
 {
 	int err;
 
-	br_stp_sap = llc_sap_open(LLC_SAP_BSPAN, br_stp_rcv);
-	if (!br_stp_sap) {
+	err = stp_proto_register(&br_stp_proto);
+	if (err < 0) {
 		printk(KERN_ERR "bridge: can't register sap for STP\n");
-		return -EADDRINUSE;
+		return err;
 	}
 
 	err = br_fdb_init();
@@ -65,13 +68,13 @@ err_out2:
 err_out1:
 	br_fdb_fini();
 err_out:
-	llc_sap_put(br_stp_sap);
+	stp_proto_unregister(&br_stp_proto);
 	return err;
 }
 
 static void __exit br_deinit(void)
 {
-	rcu_assign_pointer(br_stp_sap->rcv_func, NULL);
+	stp_proto_unregister(&br_stp_proto);
 
 	br_netlink_fini();
 	unregister_netdevice_notifier(&br_device_notifier);
@@ -82,7 +85,6 @@ static void __exit br_deinit(void)
 	synchronize_net();
 
 	br_netfilter_fini();
-	llc_sap_put(br_stp_sap);
 	br_fdb_get_hook = NULL;
 	br_fdb_put_hook = NULL;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8593c9f..815ed38 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -226,8 +226,9 @@ extern void br_stp_set_path_cost(struct net_bridge_port *p,
 extern ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id);
 
 /* br_stp_bpdu.c */
-extern int br_stp_rcv(struct sk_buff *skb, struct net_device *dev,
-		      struct packet_type *pt, struct net_device *orig_dev);
+struct stp_proto;
+extern void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
+		       struct net_device *dev);
 
 /* br_stp_timer.c */
 extern void br_stp_timer_init(struct net_bridge *br);
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 9dc2de6..9964761 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -18,6 +18,7 @@
 #include <net/net_namespace.h>
 #include <net/llc.h>
 #include <net/llc_pdu.h>
+#include <net/stp.h>
 #include <asm/unaligned.h>
 
 #include "br_private.h"
@@ -131,10 +132,9 @@ void br_send_tcn_bpdu(struct net_bridge_port *p)
  *
  * NO locks, but rcu_read_lock (preempt_disabled)
  */
-int br_stp_rcv(struct sk_buff *skb, struct net_device *dev,
-	       struct packet_type *pt, struct net_device *orig_dev)
+void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
+		struct net_device *dev)
 {
-	const struct llc_pdu_un *pdu = llc_pdu_un_hdr(skb);
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	struct net_bridge_port *p = rcu_dereference(dev->br_port);
 	struct net_bridge *br;
@@ -146,11 +146,6 @@ int br_stp_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!p)
 		goto err;
 
-	if (pdu->ssap != LLC_SAP_BSPAN
-	    || pdu->dsap != LLC_SAP_BSPAN
-	    || pdu->ctrl_1 != LLC_PDU_TYPE_U)
-		goto err;
-
 	if (!pskb_may_pull(skb, 4))
 		goto err;
 
@@ -224,5 +219,4 @@ int br_stp_rcv(struct sk_buff *skb, struct net_device *dev,
 	spin_unlock(&br->lock);
  err:
 	kfree_skb(skb);
-	return 0;
 }
