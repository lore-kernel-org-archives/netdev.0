From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 12/13] udp_diag: Implement the dump-all functionality
Date: Fri, 09 Dec 2011 20:24:21 +0400
Message-ID: <4EE23635.6030504@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:11929 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750758Ab1LIQY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:24:29 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do the same as TCP does -- iterate the given udp_table, filter
sockets with bytecode and dump sockets into reply message.

The same filtering as for TCP applies, though only some of the
state bits really matter.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/ipv4/udp_diag.c |   54 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 3938aef..3447634 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -18,6 +18,17 @@
 #include <linux/inet_diag.h>
 #include <linux/sock_diag.h>
 
+static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
+		struct netlink_callback *cb, struct inet_diag_req *req,
+		struct nlattr *bc)
+{
+	if (!inet_diag_bc_sk(bc, sk))
+		return 0;
+
+	return inet_sk_diag_fill(sk, NULL, skb, req, NETLINK_CB(cb->skb).pid,
+			cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
+}
+
 static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 		const struct nlmsghdr *nlh, struct inet_diag_req *req)
 {
@@ -77,6 +88,49 @@ out_nosk:
 static void udp_dump(struct udp_table *table, struct sk_buff *skb, struct netlink_callback *cb,
 		struct inet_diag_req *r, struct nlattr *bc)
 {
+	int num, s_num, slot, s_slot;
+
+	s_slot = cb->args[0];
+	num = s_num = cb->args[1];
+
+	for (slot = s_slot; slot <= table->mask; num = s_num = 0, slot++) {
+		struct sock *sk;
+		struct hlist_nulls_node *node;
+		struct udp_hslot *hslot = &table->hash[slot];
+
+		if (hlist_nulls_empty(&hslot->head))
+			continue;
+
+		spin_lock_bh(&hslot->lock);
+		sk_nulls_for_each(sk, node, &hslot->head) {
+			struct inet_sock *inet = inet_sk(sk);
+
+			if (num < s_num)
+				goto next;
+			if (!(r->idiag_states & (1 << sk->sk_state)))
+				goto next;
+			if (r->sdiag_family != AF_UNSPEC &&
+					sk->sk_family != r->sdiag_family)
+				goto next;
+			if (r->id.idiag_sport != inet->inet_sport &&
+			    r->id.idiag_sport)
+				goto next;
+			if (r->id.idiag_dport != inet->inet_dport &&
+			    r->id.idiag_dport)
+				goto next;
+
+			if (sk_diag_dump(sk, skb, cb, r, bc) < 0) {
+				spin_unlock_bh(&hslot->lock);
+				goto done;
+			}
+next:
+			num++;
+		}
+		spin_unlock_bh(&hslot->lock);
+	}
+done:
+	cb->args[0] = slot;
+	cb->args[1] = num;
 }
 
 static void udp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-- 
1.5.5.6
