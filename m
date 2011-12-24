From: pablo@netfilter.org
Subject: [PATCH 1/2] netfilter: ctnetlink: fix return value of ctnetlink_get_expect()
Date: Sat, 24 Dec 2011 19:52:47 +0100
Message-ID: <1324752768-5853-2-git-send-email-pablo@netfilter.org>
References: <1324752768-5853-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1324752768-5853-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This fixes one bogus error that is returned to user-space:

libnetfilter_conntrack/utils# ./expect_get
TEST: get expectation (-1)(Unknown error 18446744073709551504)

This patch includes the correct handling for EAGAIN (nfnetlink
uses this error value to restart the operation after module
auto-loading).

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index ef21b22..3d7ea7a 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1869,25 +1869,30 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 
 	err = -ENOMEM;
 	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (skb2 == NULL)
+	if (skb2 == NULL) {
+		nf_ct_expect_put(exp);
 		goto out;
+	}
 
 	rcu_read_lock();
 	err = ctnetlink_exp_fill_info(skb2, NETLINK_CB(skb).pid,
 				      nlh->nlmsg_seq, IPCTNL_MSG_EXP_NEW, exp);
 	rcu_read_unlock();
+	nf_ct_expect_put(exp);
 	if (err <= 0)
 		goto free;
 
-	nf_ct_expect_put(exp);
+	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	if (err < 0)
+		goto out;
 
-	return netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	return 0;
 
 free:
 	kfree_skb(skb2);
 out:
-	nf_ct_expect_put(exp);
-	return err;
+	/* this avoids a loop in nfnetlink. */
+	return err == -EAGAIN ? -ENOBUFS : err;
 }
 
 static int
-- 
1.7.2.5

