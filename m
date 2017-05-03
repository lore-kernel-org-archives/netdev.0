From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/16] netfilter: ctnetlink: fix deadlock due to acquire _expect_lock twice
Date: Wed,  3 May 2017 11:32:01 +0200
Message-ID: <1493803931-2837-7-git-send-email-pablo@netfilter.org>
References: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

Currently, ctnetlink_change_conntrack is always protected by _expect_lock,
but this will cause a deadlock when deleting the helper from a conntrack,
as the _expect_lock will be acquired again by nf_ct_remove_expectations:

         CPU0
        ----
  lock(nf_conntrack_expect_lock);
  lock(nf_conntrack_expect_lock);

  *** DEADLOCK ***
  May be due to missing lock nesting notation

  2 locks held by lt-conntrack_gr/12853:
  #0:  (&table[i].mutex){+.+.+.}, at: [<ffffffffa05e2009>]
       nfnetlink_rcv_msg+0x399/0x6a9 [nfnetlink]
  #1:  (nf_conntrack_expect_lock){+.....}, at: [<ffffffffa05f2c1f>]
       ctnetlink_new_conntrack+0x17f/0x408 [nf_conntrack_netlink]

  Call Trace:
   dump_stack+0x85/0xc2
   __lock_acquire+0x1608/0x1680
   ? ctnetlink_parse_tuple_proto+0x10f/0x1c0 [nf_conntrack_netlink]
   lock_acquire+0x100/0x1f0
   ? nf_ct_remove_expectations+0x32/0x90 [nf_conntrack]
   _raw_spin_lock_bh+0x3f/0x50
   ? nf_ct_remove_expectations+0x32/0x90 [nf_conntrack]
   nf_ct_remove_expectations+0x32/0x90 [nf_conntrack]
   ctnetlink_change_helper+0xc6/0x190 [nf_conntrack_netlink]
   ctnetlink_new_conntrack+0x1b2/0x408 [nf_conntrack_netlink]
   nfnetlink_rcv_msg+0x60a/0x6a9 [nfnetlink]
   ? nfnetlink_rcv_msg+0x1b9/0x6a9 [nfnetlink]
   ? nfnetlink_bind+0x1a0/0x1a0 [nfnetlink]
   netlink_rcv_skb+0xa4/0xc0
   nfnetlink_rcv+0x87/0x770 [nfnetlink]

Since the operations are unrelated to nf_ct_expect, so we can drop the
_expect_lock. Also note, after removing the _expect_lock protection,
another CPU may invoke nf_conntrack_helper_unregister, so we should
use rcu_read_lock to protect __nf_conntrack_helper_find invoked by
ctnetlink_change_helper.

Fixes: ca7433df3a67 ("netfilter: conntrack: seperate expect locking from nf_conntrack_lock")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 48c184552de0..e5f97777b1f4 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1510,23 +1510,29 @@ static int ctnetlink_change_helper(struct nf_conn *ct,
 		return 0;
 	}
 
+	rcu_read_lock();
 	helper = __nf_conntrack_helper_find(helpname, nf_ct_l3num(ct),
 					    nf_ct_protonum(ct));
-	if (helper == NULL)
+	if (helper == NULL) {
+		rcu_read_unlock();
 		return -EOPNOTSUPP;
+	}
 
 	if (help) {
 		if (help->helper == helper) {
 			/* update private helper data if allowed. */
 			if (helper->from_nlattr)
 				helper->from_nlattr(helpinfo, ct);
-			return 0;
+			err = 0;
 		} else
-			return -EBUSY;
+			err = -EBUSY;
+	} else {
+		/* we cannot set a helper for an existing conntrack */
+		err = -EOPNOTSUPP;
 	}
 
-	/* we cannot set a helper for an existing conntrack */
-	return -EOPNOTSUPP;
+	rcu_read_unlock();
+	return err;
 }
 
 static int ctnetlink_change_timeout(struct nf_conn *ct,
@@ -1945,9 +1951,7 @@ static int ctnetlink_new_conntrack(struct net *net, struct sock *ctnl,
 	err = -EEXIST;
 	ct = nf_ct_tuplehash_to_ctrack(h);
 	if (!(nlh->nlmsg_flags & NLM_F_EXCL)) {
-		spin_lock_bh(&nf_conntrack_expect_lock);
 		err = ctnetlink_change_conntrack(ct, cda);
-		spin_unlock_bh(&nf_conntrack_expect_lock);
 		if (err == 0) {
 			nf_conntrack_eventmask_report((1 << IPCT_REPLY) |
 						      (1 << IPCT_ASSURED) |
@@ -2342,11 +2346,7 @@ ctnetlink_glue_parse(const struct nlattr *attr, struct nf_conn *ct)
 	if (ret < 0)
 		return ret;
 
-	spin_lock_bh(&nf_conntrack_expect_lock);
-	ret = ctnetlink_glue_parse_ct((const struct nlattr **)cda, ct);
-	spin_unlock_bh(&nf_conntrack_expect_lock);
-
-	return ret;
+	return ctnetlink_glue_parse_ct((const struct nlattr **)cda, ct);
 }
 
 static int ctnetlink_glue_exp_parse(const struct nlattr * const *cda,
-- 
2.1.4

