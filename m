From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH Round 4 3/3] Cleanup ib_addr module to use the netevent patch.
Date: Tue, 18 Jul 2006 13:49:17 -0500
Message-ID: <20060718184917.25455.75688.stgit@dell3.ogc.int>
References: <20060718184847.25455.88191.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:34269 "EHLO
	dell3.ogc.int") by vger.kernel.org with ESMTP id S932358AbWGRStS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 14:49:18 -0400
To: davem@davemloft.net, rdreier@cisco.com
In-Reply-To: <20060718184847.25455.88191.stgit@dell3.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



---

 drivers/infiniband/core/addr.c |   30 ++++++++++++++----------------
 1 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index d294bbc..1205e80 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -35,6 +35,7 @@ #include <linux/if_arp.h>
 #include <net/arp.h>
 #include <net/neighbour.h>
 #include <net/route.h>
+#include <net/netevent.h>
 #include <rdma/ib_addr.h>
 
 MODULE_AUTHOR("Sean Hefty");
@@ -326,25 +327,22 @@ void rdma_addr_cancel(struct rdma_dev_ad
 }
 EXPORT_SYMBOL(rdma_addr_cancel);
 
-static int addr_arp_recv(struct sk_buff *skb, struct net_device *dev,
-			 struct packet_type *pkt, struct net_device *orig_dev)
+static int netevent_callback(struct notifier_block *self, unsigned long event, 
+	void *ctx)
 {
-	struct arphdr *arp_hdr;
+	if (event == NETEVENT_NEIGH_UPDATE) {  
+		struct neighbour *neigh = ctx;
 
-	arp_hdr = (struct arphdr *) skb->nh.raw;
-
-	if (arp_hdr->ar_op == htons(ARPOP_REQUEST) ||
-	    arp_hdr->ar_op == htons(ARPOP_REPLY))
-		set_timeout(jiffies);
-
-	kfree_skb(skb);
+		if (neigh->dev->type == ARPHRD_INFINIBAND &&
+		    (neigh->nud_state & NUD_VALID)) {
+			set_timeout(jiffies);
+		}
+	}
 	return 0;
 }
 
-static struct packet_type addr_arp = {
-	.type           = __constant_htons(ETH_P_ARP),
-	.func           = addr_arp_recv,
-	.af_packet_priv = (void*) 1,
+static struct notifier_block nb = {
+	.notifier_call = netevent_callback
 };
 
 static int addr_init(void)
@@ -353,13 +351,13 @@ static int addr_init(void)
 	if (!addr_wq)
 		return -ENOMEM;
 
-	dev_add_pack(&addr_arp);
+	register_netevent_notifier(&nb);
 	return 0;
 }
 
 static void addr_cleanup(void)
 {
-	dev_remove_pack(&addr_arp);
+	unregister_netevent_notifier(&nb);
 	destroy_workqueue(addr_wq);
 }
 
