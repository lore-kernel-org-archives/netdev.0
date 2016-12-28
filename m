From: Paul Blakey <paulb@mellanox.com>
Subject: [PATCH net] net/sched: cls_flower: Fix missing addr_type in classify
Date: Wed, 28 Dec 2016 14:54:47 +0200
Message-ID: <1482929687-20159-1-git-send-email-paulb@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Paul Blakey <paulb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60558 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751467AbcL1MzS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:55:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we now use a non zero mask on addr_type, we are matching on its
value (IPV4/IPV6). So before this fix, matching on enc_src_ip/enc_dst_ip
failed in SW/classify path since its value was zero.
This patch sets the proper value of addr_type for encapsulated packets.

Fixes: 970bfcd09791 ('net/sched: cls_flower: Use mask for addr_type')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 net/sched/cls_flower.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 333f8e2..970db7a 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -153,10 +153,14 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 		switch (ip_tunnel_info_af(info)) {
 		case AF_INET:
+			skb_key.enc_control.addr_type =
+				FLOW_DISSECTOR_KEY_IPV4_ADDRS;
 			skb_key.enc_ipv4.src = key->u.ipv4.src;
 			skb_key.enc_ipv4.dst = key->u.ipv4.dst;
 			break;
 		case AF_INET6:
+			skb_key.enc_control.addr_type =
+				FLOW_DISSECTOR_KEY_IPV6_ADDRS;
 			skb_key.enc_ipv6.src = key->u.ipv6.src;
 			skb_key.enc_ipv6.dst = key->u.ipv6.dst;
 			break;
-- 
1.8.3.1
