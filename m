From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NET-2.6 1/1] netxen: limit skb frags for non tso packet
Date: Mon, 11 Apr 2011 11:50:14 -0700
Message-ID: <1302547814-4400-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:4560 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755944Ab1DKWwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 18:52:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Machines are getting deadlock in four node cluster environment.
All nodes are accessing (find /gfs2 -depth -print|cpio -ocv > /dev/null)
200 GB storage on a GFS2 filesystem.
This result in memory fragmentation and driver receives 18 frags for
1448 byte packets.
For non tso packet, fw drops the tx request, if it has >14 frags.

Fixing it by pulling extra frags.

Cc: stable@kernel.org
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic.h      |    4 ++--
 drivers/net/netxen/netxen_nic_main.c |   17 +++++++++++++++++
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index d7299f1..679dc85 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -174,7 +174,7 @@
 
 #define	MAX_NUM_CARDS		4
 
-#define MAX_BUFFERS_PER_CMD	32
+#define NETXEN_MAX_FRAGS_PER_TX	14
 #define MAX_TSO_HEADER_DESC	2
 #define MGMT_CMD_DESC_RESV	4
 #define TX_STOP_THRESH		((MAX_SKB_FRAGS >> 2) + MAX_TSO_HEADER_DESC \
@@ -558,7 +558,7 @@ struct netxen_recv_crb {
  */
 struct netxen_cmd_buffer {
 	struct sk_buff *skb;
-	struct netxen_skb_frag frag_array[MAX_BUFFERS_PER_CMD + 1];
+	struct netxen_skb_frag frag_array[MAX_SKB_FRAGS + 1];
 	u32 frag_count;
 };
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 83348dc..e8a4b66 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1844,6 +1844,8 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	struct cmd_desc_type0 *hwdesc, *first_desc;
 	struct pci_dev *pdev;
 	int i, k;
+	int delta = 0;
+	struct skb_frag_struct *frag;
 
 	u32 producer;
 	int frag_count, no_of_desc;
@@ -1851,6 +1853,21 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
 
+	/* 14 frags supported for normal packet and
+	 * 32 frags supported for TSO packet
+	 */
+	if (!skb_is_gso(skb) && frag_count > NETXEN_MAX_FRAGS_PER_TX) {
+
+		for (i = 0; i < (frag_count - NETXEN_MAX_FRAGS_PER_TX); i++) {
+			frag = &skb_shinfo(skb)->frags[i];
+			delta += frag->size;
+		}
+
+		if (!__pskb_pull_tail(skb, delta))
+			goto drop_packet;
+
+		frag_count = 1 + skb_shinfo(skb)->nr_frags;
+	}
 	/* 4 fragments per cmd des */
 	no_of_desc = (frag_count + 3) >> 2;
 
-- 
1.7.3.2

