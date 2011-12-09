From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 11/13] udp_diag: Implement the get_exact dumping functionality
Date: Fri, 09 Dec 2011 20:24:06 +0400
Message-ID: <4EE23626.6000104@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39274 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798Ab1LIQYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:24:12 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do the same as TCP does -- lookup a socket in the given udp_table,
check cookie, fill the reply message with existing inet socket dumping
helper and send one back.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/ipv4/udp_diag.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 15936a3..3938aef 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -21,7 +21,57 @@
 static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 		const struct nlmsghdr *nlh, struct inet_diag_req *req)
 {
-	return 0;
+	int err = -EINVAL;
+	struct sock *sk;
+	struct sk_buff *rep;
+
+	if (req->sdiag_family == AF_INET)
+		sk = __udp4_lib_lookup(&init_net,
+				req->id.idiag_src[0], req->id.idiag_sport,
+				req->id.idiag_dst[0], req->id.idiag_dport,
+				req->id.idiag_if, tbl);
+	else if (req->sdiag_family == AF_INET6)
+		sk = __udp6_lib_lookup(&init_net,
+				(struct in6_addr *)req->id.idiag_src,
+				req->id.idiag_sport,
+				(struct in6_addr *)req->id.idiag_dst,
+				req->id.idiag_dport,
+				req->id.idiag_if, tbl);
+	else
+		goto out_nosk;
+
+	err = -ENOENT;
+	if (sk == NULL)
+		goto out_nosk;
+
+	err = inet_diag_check_cookie(sk, req);
+	if (err)
+		goto out;
+
+	err = -ENOMEM;
+	rep = alloc_skb(NLMSG_SPACE((sizeof(struct inet_diag_msg) +
+				     sizeof(struct inet_diag_meminfo) +
+				     64)), GFP_KERNEL);
+	if (!rep)
+		goto out;
+
+	err = inet_sk_diag_fill(sk, NULL, rep, req,
+			   NETLINK_CB(in_skb).pid,
+			   nlh->nlmsg_seq, 0, nlh);
+	if (err < 0) {
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(rep);
+		goto out;
+	}
+	err = netlink_unicast(sock_diag_nlsk, rep, NETLINK_CB(in_skb).pid,
+			      MSG_DONTWAIT);
+	if (err > 0)
+		err = 0;
+out:
+	if (sk)
+		sock_put(sk);
+out_nosk:
+	return err;
 }
 
 static void udp_dump(struct udp_table *table, struct sk_buff *skb, struct netlink_callback *cb,
-- 
1.5.5.6
