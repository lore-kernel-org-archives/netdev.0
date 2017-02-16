From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] net/gtp: Add udp source port generation according to flow hash
Date: Thu, 16 Feb 2017 16:59:01 +0200
Message-ID: <1487257141-11706-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        laforge@gnumonks.org, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56724 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932120AbdBPO7W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 09:59:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generate the source udp header according to the flow represented by
the packet we are encapsulating, as done for other udp tunnels. This
helps on the receiver side to apply RSS spreading.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

found in code inspection.. compile tested only


 drivers/net/gtp.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index bda0c64..ff1244b 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -564,6 +564,7 @@ static netdev_tx_t gtp_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned int proto = ntohs(skb->protocol);
 	struct gtp_pktinfo pktinfo;
+	__be16 src_port;
 	int err;
 
 	/* Ensure there is sufficient headroom. */
@@ -572,6 +573,8 @@ static netdev_tx_t gtp_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb_reset_inner_headers(skb);
 
+	src_port = udp_flow_src_port(dev_net(dev), skb, 0, 0, true);
+
 	/* PDP context lookups in gtp_build_skb_*() need rcu read-side lock. */
 	rcu_read_lock();
 	switch (proto) {
@@ -596,7 +599,7 @@ static netdev_tx_t gtp_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 				    pktinfo.iph->tos,
 				    ip4_dst_hoplimit(&pktinfo.rt->dst),
 				    0,
-				    pktinfo.gtph_port, pktinfo.gtph_port,
+				    src_port, pktinfo.gtph_port,
 				    true, false);
 		break;
 	}
-- 
2.3.7
