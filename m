From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/03: ctnetlink: fix regression in expectation handling
Date: Wed,  8 Apr 2009 18:52:19 +0200 (MEST)
Message-ID: <20090408165216.6702.57294.sendpatchset@x2.localnet>
References: <20090408165212.6702.44171.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090408165212.6702.44171.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 83731671d9e6878c0a05d309c68fb71c16d3235a
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Apr 6 17:47:20 2009 +0200

    netfilter: ctnetlink: fix regression in expectation handling
    
    This patch fixes a regression (introduced by myself in commit 19abb7b:
    netfilter: ctnetlink: deliver events for conntracks changed from
    userspace) that results in an expectation re-insertion since
    __nf_ct_expect_check() may return 0 for expectation timer refreshing.
    
    This patch also removes a unnecessary refcount bump that
    pretended to avoid a possible race condition with event delivery
    and expectation timers (as said, not needed since we hold a
    reference to the object since until we finish the expectation
    setup). This also merges nf_ct_expect_related_report() and
    nf_ct_expect_related() which look basically the same.
    
    Reported-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index ab17a15..a965280 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -99,9 +99,12 @@ void nf_ct_expect_init(struct nf_conntrack_expect *, unsigned int, u_int8_t,
 		       const union nf_inet_addr *,
 		       u_int8_t, const __be16 *, const __be16 *);
 void nf_ct_expect_put(struct nf_conntrack_expect *exp);
-int nf_ct_expect_related(struct nf_conntrack_expect *expect);
 int nf_ct_expect_related_report(struct nf_conntrack_expect *expect, 
 				u32 pid, int report);
+static inline int nf_ct_expect_related(struct nf_conntrack_expect *expect)
+{
+	return nf_ct_expect_related_report(expect, 0, 0);
+}
 
 #endif /*_NF_CONNTRACK_EXPECT_H*/
 
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 3940f99..afde8f9 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -372,7 +372,7 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 	struct net *net = nf_ct_exp_net(expect);
 	struct hlist_node *n;
 	unsigned int h;
-	int ret = 0;
+	int ret = 1;
 
 	if (!master_help->helper) {
 		ret = -ESHUTDOWN;
@@ -412,41 +412,23 @@ out:
 	return ret;
 }
 
-int nf_ct_expect_related(struct nf_conntrack_expect *expect)
+int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
+				u32 pid, int report)
 {
 	int ret;
 
 	spin_lock_bh(&nf_conntrack_lock);
 	ret = __nf_ct_expect_check(expect);
-	if (ret < 0)
+	if (ret <= 0)
 		goto out;
 
+	ret = 0;
 	nf_ct_expect_insert(expect);
-	atomic_inc(&expect->use);
-	spin_unlock_bh(&nf_conntrack_lock);
-	nf_ct_expect_event(IPEXP_NEW, expect);
-	nf_ct_expect_put(expect);
-	return ret;
-out:
 	spin_unlock_bh(&nf_conntrack_lock);
+	nf_ct_expect_event_report(IPEXP_NEW, expect, pid, report);
 	return ret;
-}
-EXPORT_SYMBOL_GPL(nf_ct_expect_related);
-
-int nf_ct_expect_related_report(struct nf_conntrack_expect *expect, 
-				u32 pid, int report)
-{
-	int ret;
-
-	spin_lock_bh(&nf_conntrack_lock);
-	ret = __nf_ct_expect_check(expect);
-	if (ret < 0)
-		goto out;
-	nf_ct_expect_insert(expect);
 out:
 	spin_unlock_bh(&nf_conntrack_lock);
-	if (ret == 0)
-		nf_ct_expect_event_report(IPEXP_NEW, expect, pid, report);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_related_report);
