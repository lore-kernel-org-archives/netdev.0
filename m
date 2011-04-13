From: amit.salecha@qlogic.com
Subject: [PATCHv2 NET-2.6 1/1] qlcnic: limit skb frags for non tso packet
Date: Tue, 12 Apr 2011 20:05:55 -0700
Message-ID: <1302663955-31849-2-git-send-email-amit.salecha@qlogic.com>
References: <1302663955-31849-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:60030 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1756412Ab1DMDLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 23:11:10 -0400
In-Reply-To: <1302663955-31849-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

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
 drivers/net/qlcnic/qlcnic.h      |    1 +
 drivers/net/qlcnic/qlcnic_main.c |   14 ++++++++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index dc44564..b0dead0 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -99,6 +99,7 @@
 #define TX_UDPV6_PKT	0x0c
 
 /* Tx defines */
+#define QLCNIC_MAX_FRAGS_PER_TX	14
 #define MAX_TSO_HEADER_DESC	2
 #define MGMT_CMD_DESC_RESV	4
 #define TX_STOP_THRESH		((MAX_SKB_FRAGS >> 2) + MAX_TSO_HEADER_DESC \
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index cd88c7e..cb1a1ef 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2099,6 +2099,7 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	struct cmd_desc_type0 *hwdesc, *first_desc;
 	struct pci_dev *pdev;
 	struct ethhdr *phdr;
+	int delta = 0;
 	int i, k;
 
 	u32 producer;
@@ -2118,6 +2119,19 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
+	/* 14 frags supported for normal packet and
+	 * 32 frags supported for TSO packet
+	 */
+	if (!skb_is_gso(skb) && frag_count > QLCNIC_MAX_FRAGS_PER_TX) {
+
+		for (i = 0; i < (frag_count - QLCNIC_MAX_FRAGS_PER_TX); i++)
+			delta += skb_shinfo(skb)->frags[i].size;
+
+		if (!__pskb_pull_tail(skb, delta))
+			goto drop_packet;
+
+		frag_count = 1 + skb_shinfo(skb)->nr_frags;
+	}
 
 	/* 4 fragments per cmd des */
 	no_of_desc = (frag_count + 3) >> 2;
-- 
1.6.0.2

