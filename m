From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: [PATCH] infinite recursion in netlink
Date: Wed, 25 Apr 2007 22:38:56 +0400
Message-ID: <20070425183856.GA6028@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jaco@kroon.co.za
To: davem@davemloft.net, security@kernel.org, greg@kroah.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:39332 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S2992961AbXDYTOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 15:14:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Reply to NETLINK_FIB_LOOKUP messages were misrouted back to kernel,
which resulted in infinite recursion and stack overflow.

The bug is present in all kernel versions since the feature appeared.

The patch also makes some minimal cleanup:

1. Return something consistent (-ENOENT) when fib table is missing
2. Do not crash when queue is empty (does not happen, but yet)
3. Put result of lookup

Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>


diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index fc920f6..cac06c4 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -776,6 +776,8 @@ static void nl_fib_lookup(struct fib_res
 				       .nl_u = { .ip4_u = { .daddr = frn->fl_addr,
 							    .tos = frn->fl_tos,
 							    .scope = frn->fl_scope } } };
+
+	frn->err = -ENOENT;
 	if (tb) {
 		local_bh_disable();
 
@@ -787,6 +789,7 @@ static void nl_fib_lookup(struct fib_res
 			frn->nh_sel = res.nh_sel;
 			frn->type = res.type;
 			frn->scope = res.scope;
+			fib_res_put(&res);
 		}
 		local_bh_enable();
 	}
@@ -801,6 +804,9 @@ static void nl_fib_input(struct sock *sk
 	struct fib_table *tb;
 
 	skb = skb_dequeue(&sk->sk_receive_queue);
+	if (skb == NULL)
+		return;
+
 	nlh = (struct nlmsghdr *)skb->data;
 	if (skb->len < NLMSG_SPACE(0) || skb->len < nlh->nlmsg_len ||
 	    nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*frn))) {
@@ -813,7 +819,7 @@ static void nl_fib_input(struct sock *sk
 
 	nl_fib_lookup(frn, tb);
 
-	pid = nlh->nlmsg_pid;           /*pid of sending process */
+	pid = NETLINK_CB(skb).pid;       /* pid of sending process */
 	NETLINK_CB(skb).pid = 0;         /* from kernel */
 	NETLINK_CB(skb).dst_group = 0;  /* unicast */
 	netlink_unicast(sk, skb, pid, MSG_DONTWAIT);
