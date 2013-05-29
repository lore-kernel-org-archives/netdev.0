From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH v3 1/2] xfrm: force a garbage collection after deleting a
 policy
Date: Wed, 29 May 2013 13:36:25 -0400
Message-ID: <20130529173625.31888.4007.stgit@localhost>
References: <20130529173336.31888.29695.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: omoris@redhat.com, pwouters@redhat.com
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61611 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932934Ab3E2Rg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 13:36:28 -0400
In-Reply-To: <20130529173336.31888.29695.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases after deleting a policy from the SPD the policy would
remain in the dst/flow/route cache for an extended period of time
which caused problems for SELinux as its dynamic network access
controls key off of the number of XFRM policy and state entries.
This patch corrects this problem by forcing a XFRM garbage collection
whenever a policy is sucessfully removed.

Reported-by: Ondrej Moris <omoris@redhat.com>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 include/net/xfrm.h     |    5 +++++
 net/key/af_key.c       |    4 ++++
 net/xfrm/xfrm_policy.c |    3 ++-
 net/xfrm/xfrm_user.c   |    2 ++
 4 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ae16531..94ce082 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1160,6 +1160,8 @@ static inline void xfrm_sk_free_policy(struct sock *sk)
 	}
 }
 
+extern void xfrm_garbage_collect(struct net *net);
+
 #else
 
 static inline void xfrm_sk_free_policy(struct sock *sk) {}
@@ -1194,6 +1196,9 @@ static inline int xfrm6_policy_check_reverse(struct sock *sk, int dir,
 {
 	return 1;
 }
+static inline void xfrm_garbage_collect(struct net *net)
+{
+}
 #endif
 
 static __inline__
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 5b1e5af..c5fbd75 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2366,6 +2366,8 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, const struct sa
 
 out:
 	xfrm_pol_put(xp);
+	if (err == 0)
+		xfrm_garbage_collect(net);
 	return err;
 }
 
@@ -2615,6 +2617,8 @@ static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, const struct sadb_
 
 out:
 	xfrm_pol_put(xp);
+	if (delete && err == 0)
+		xfrm_garbage_collect(net);
 	return err;
 }
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 23cea0f..ea970b8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2557,11 +2557,12 @@ static void __xfrm_garbage_collect(struct net *net)
 	}
 }
 
-static void xfrm_garbage_collect(struct net *net)
+void xfrm_garbage_collect(struct net *net)
 {
 	flow_cache_flush();
 	__xfrm_garbage_collect(net);
 }
+EXPORT_SYMBOL(xfrm_garbage_collect);
 
 static void xfrm_garbage_collect_deferred(struct net *net)
 {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index aa77874..3f565e4 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1681,6 +1681,8 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 out:
 	xfrm_pol_put(xp);
+	if (delete && err == 0)
+		xfrm_garbage_collect(net);
 	return err;
 }
 
