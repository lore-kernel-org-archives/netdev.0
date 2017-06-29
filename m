From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/29] netns: add and use net_ns_barrier
Date: Fri, 30 Jun 2017 00:53:21 +0200
Message-ID: <1498776807-11124-24-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57602 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752376AbdF2Wx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:56 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 54293BDF5F
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 45CAFD1CB1
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 58DF1D1CA7
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:41 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Quoting Joe Stringer:
  If a user loads nf_conntrack_ftp, sends FTP traffic through a network
  namespace, destroys that namespace then unloads the FTP helper module,
  then the kernel will crash.

Events that lead to the crash:
1. conntrack is created with ftp helper in netns x
2. This netns is destroyed
3. netns destruction is scheduled
4. netns destruction wq starts, removes netns from global list
5. ftp helper is unloaded, which resets all helpers of the conntracks
via for_each_net()

but because netns is already gone from list the for_each_net() loop
doesn't include it, therefore all of these conntracks are unaffected.

6. helper module unload finishes
7. netns wq invokes destructor for rmmod'ed helper

CC: "Eric W. Biederman" <ebiederm@xmission.com>
Reported-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/net_namespace.h       |  3 +++
 net/core/net_namespace.c          | 17 +++++++++++++++++
 net/netfilter/nf_conntrack_core.c |  9 +++++++++
 3 files changed, 29 insertions(+)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index fe80bb48ab1f..a24a57593202 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -158,6 +158,7 @@ extern struct net init_net;
 struct net *copy_net_ns(unsigned long flags, struct user_namespace *user_ns,
 			struct net *old_net);
 
+void net_ns_barrier(void);
 #else /* CONFIG_NET_NS */
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
@@ -168,6 +169,8 @@ static inline struct net *copy_net_ns(unsigned long flags,
 		return ERR_PTR(-EINVAL);
 	return old_net;
 }
+
+static inline void net_ns_barrier(void) {}
 #endif /* CONFIG_NET_NS */
 
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 1934efd4a9d4..1f15abb1d733 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -482,6 +482,23 @@ static void cleanup_net(struct work_struct *work)
 		net_drop_ns(net);
 	}
 }
+
+/**
+ * net_ns_barrier - wait until concurrent net_cleanup_work is done
+ *
+ * cleanup_net runs from work queue and will first remove namespaces
+ * from the global list, then run net exit functions.
+ *
+ * Call this in module exit path to make sure that all netns
+ * ->exit ops have been invoked before the function is removed.
+ */
+void net_ns_barrier(void)
+{
+	mutex_lock(&net_mutex);
+	mutex_unlock(&net_mutex);
+}
+EXPORT_SYMBOL(net_ns_barrier);
+
 static DECLARE_WORK(net_cleanup_work, cleanup_net);
 
 void __put_net(struct net *net)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index c3bd9b086dcc..9979f46c81dc 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1720,6 +1720,8 @@ EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup_net);
  * Like nf_ct_iterate_cleanup, but first marks conntracks on the
  * unconfirmed list as dying (so they will not be inserted into
  * main table).
+ *
+ * Can only be called in module exit path.
  */
 void
 nf_ct_iterate_destroy(int (*iter)(struct nf_conn *i, void *data), void *data)
@@ -1734,6 +1736,13 @@ nf_ct_iterate_destroy(int (*iter)(struct nf_conn *i, void *data), void *data)
 	}
 	rtnl_unlock();
 
+	/* Need to wait for netns cleanup worker to finish, if its
+	 * running -- it might have deleted a net namespace from
+	 * the global list, so our __nf_ct_unconfirmed_destroy() might
+	 * not have affected all namespaces.
+	 */
+	net_ns_barrier();
+
 	/* a conntrack could have been unlinked from unconfirmed list
 	 * before we grabbed pcpu lock in __nf_ct_unconfirmed_destroy().
 	 * This makes sure its inserted into conntrack table.
-- 
2.1.4
