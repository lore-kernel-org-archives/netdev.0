From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH 1/1] tipc: return value of skb_linearize should be handled
Date: Wed,  7 Dec 2016 16:11:07 +0800
Message-ID: <1481098267-25801-1-git-send-email-zhouzhouyi@gmail.com>
Cc: Zhouyi Zhou <zhouzhouyi@gmail.com>,
        Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: <jon.maloy@ericsson.com>, <ying.xue@windriver.com>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <tipc-discussion@lists.sourceforge.net>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

return value of skb_linearize should be handled

Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>
Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/tipc/link.c       | 3 ++-
 net/tipc/name_distr.c | 5 ++++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index bda89bf..077c570 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1446,7 +1446,8 @@ static int tipc_link_proto_rcv(struct tipc_link *l, struct sk_buff *skb,
 	if (tipc_own_addr(l->net) > msg_prevnode(hdr))
 		l->net_plane = msg_net_plane(hdr);
 
-	skb_linearize(skb);
+	if (skb_linearize(skb))
+		goto exit;
 	hdr = buf_msg(skb);
 	data = msg_data(hdr);
 
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index c1cfd92..4e05d2a 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -356,7 +356,10 @@ void tipc_named_rcv(struct net *net, struct sk_buff_head *inputq)
 
 	spin_lock_bh(&tn->nametbl_lock);
 	for (skb = skb_dequeue(inputq); skb; skb = skb_dequeue(inputq)) {
-		skb_linearize(skb);
+		if (skb_linearize(skb)) {
+			kfree_skb(skb);
+			continue;
+		}
 		msg = buf_msg(skb);
 		mtype = msg_type(msg);
 		item = (struct distr_item *)msg_data(msg);
-- 
1.9.1
