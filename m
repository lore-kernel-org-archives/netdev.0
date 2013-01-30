From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 3/4] ipv6 flowlabel: Convert np->ipv6_fl_list to RCU.
Date: Thu, 31 Jan 2013 04:27:52 +0900
Message-ID: <51097438.1060302@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56146 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756624Ab3A3T1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 14:27:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/ipv6.h     |    2 +-
 include/net/ipv6.h       |    1 +
 net/ipv6/ip6_flowlabel.c |   72 +++++++++++++++++++++++++---------------------
 3 files changed, 42 insertions(+), 33 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index e971e37..850e95b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -214,7 +214,7 @@ struct ipv6_pinfo {
 
 	struct ipv6_mc_socklist	__rcu *ipv6_mc_list;
 	struct ipv6_ac_socklist	*ipv6_ac_list;
-	struct ipv6_fl_socklist *ipv6_fl_list;
+	struct ipv6_fl_socklist __rcu *ipv6_fl_list;
 
 	struct ipv6_txoptions	*opt;
 	struct sk_buff		*pktoptions;
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 1d45716..851d541 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -239,6 +239,7 @@ struct ip6_flowlabel {
 struct ipv6_fl_socklist {
 	struct ipv6_fl_socklist	*next;
 	struct ip6_flowlabel	*fl;
+	struct rcu_head		rcu;
 };
 
 extern struct ip6_flowlabel	*fl6_sock_lookup(struct sock *sk, __be32 label);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index da15601..22494af 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -62,7 +62,7 @@ static DEFINE_SPINLOCK(ip6_fl_lock);
 
 /* Big socket sock */
 
-static DEFINE_RWLOCK(ip6_sk_fl_lock);
+static DEFINE_SPINLOCK(ip6_sk_fl_lock);
 
 #define for_each_fl_rcu(hash, fl)				\
 	for (fl = rcu_dereference(fl_ht[(hash)]);		\
@@ -73,6 +73,11 @@ static DEFINE_RWLOCK(ip6_sk_fl_lock);
 	     fl != NULL;					\
 	     fl = rcu_dereference(fl->next))
 
+#define for_each_sk_fl_rcu(np, sfl)				\
+	for (sfl = rcu_dereference_bh(np->ipv6_fl_list);	\
+	     sfl != NULL;					\
+	     sfl = rcu_dereference_bh(sfl->next))
+
 static inline struct ip6_flowlabel *__fl_lookup(struct net *net, __be32 label)
 {
 	struct ip6_flowlabel *fl;
@@ -244,17 +249,17 @@ struct ip6_flowlabel * fl6_sock_lookup(struct sock *sk, __be32 label)
 
 	label &= IPV6_FLOWLABEL_MASK;
 
-	read_lock_bh(&ip6_sk_fl_lock);
-	for (sfl=np->ipv6_fl_list; sfl; sfl = sfl->next) {
+	rcu_read_lock_bh();
+	for_each_sk_fl_rcu(np, sfl) {
 		struct ip6_flowlabel *fl = sfl->fl;
 		if (fl->label == label) {
 			fl->lastuse = jiffies;
 			atomic_inc(&fl->users);
-			read_unlock_bh(&ip6_sk_fl_lock);
+			rcu_read_unlock_bh();
 			return fl;
 		}
 	}
-	read_unlock_bh(&ip6_sk_fl_lock);
+	rcu_read_unlock_bh();
 	return NULL;
 }
 
@@ -265,20 +270,21 @@ void fl6_free_socklist(struct sock *sk)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_fl_socklist *sfl;
 
-	if (!np->ipv6_fl_list)
+	if (!rcu_access_pointer(np->ipv6_fl_list))
 		return;
 
-	write_lock_bh(&ipv6_sk_fl_lock);
-	sfl = np->ipv6_fl_list;
-	np->ipv6_fl_list = NULL;
-	write_unlock_bh(&ipv6_sk_fl_lock);
+	spin_lock_bh(&ip6_sk_fl_lock);
+	while ((sfl = rcu_dereference_protected(np->ipv6_fl_list,
+						lockdep_is_held(&ip6_sk_fl_lock))) != NULL) {
+		np->ipv6_fl_list = sfl->next;
+		spin_unlock_bh(&ip6_sk_fl_lock);
 
-	while (sfl) {
-		struct ipv6_fl_socklist *next = sfl->next;
 		fl_release(sfl->fl);
-		kfree(sfl);
-		sfl = next;
+		kfree_rcu(sfl, rcu);
+
+		spin_lock_bh(&ip6_sk_fl_lock);
 	}
+	spin_unlock_bh(&ip6_sk_fl_lock);
 }
 
 /* Service routines */
@@ -443,7 +449,7 @@ static int mem_check(struct sock *sk)
 	if (room > FL_MAX_SIZE - FL_MAX_PER_SOCK)
 		return 0;
 
-	for (sfl = np->ipv6_fl_list; sfl; sfl = sfl->next)
+	for_each_sk_fl_rcu(np, sfl)
 		count++;
 
 	if (room <= 0 ||
@@ -486,11 +492,11 @@ static bool ipv6_opt_cmp(struct ipv6_txoptions *o1, struct ipv6_txoptions *o2)
 static inline void fl_link(struct ipv6_pinfo *np, struct ipv6_fl_socklist *sfl,
 		struct ip6_flowlabel *fl)
 {
-	write_lock_bh(&ip6_sk_fl_lock);
+	spin_lock_bh(&ip6_sk_fl_lock);
 	sfl->fl = fl;
 	sfl->next = np->ipv6_fl_list;
-	np->ipv6_fl_list = sfl;
-	write_unlock_bh(&ip6_sk_fl_lock);
+	rcu_assign_pointer(np->ipv6_fl_list, sfl);
+	spin_unlock_bh(&ip6_sk_fl_lock);
 }
 
 int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
@@ -512,31 +518,33 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 
 	switch (freq.flr_action) {
 	case IPV6_FL_A_PUT:
-		write_lock_bh(&ip6_sk_fl_lock);
-		for (sflp = &np->ipv6_fl_list; (sfl=*sflp)!=NULL; sflp = &sfl->next) {
+		spin_lock_bh(&ip6_sk_fl_lock);
+		for (sflp = &np->ipv6_fl_list;
+		     (sfl = rcu_dereference(*sflp))!=NULL;
+		     sflp = &sfl->next) {
 			if (sfl->fl->label == freq.flr_label) {
 				if (freq.flr_label == (np->flow_label&IPV6_FLOWLABEL_MASK))
 					np->flow_label &= ~IPV6_FLOWLABEL_MASK;
-				*sflp = sfl->next;
-				write_unlock_bh(&ip6_sk_fl_lock);
+				*sflp = rcu_dereference(sfl->next);
+				spin_unlock_bh(&ip6_sk_fl_lock);
 				fl_release(sfl->fl);
-				kfree(sfl);
+				kfree_rcu(sfl, rcu);
 				return 0;
 			}
 		}
-		write_unlock_bh(&ip6_sk_fl_lock);
+		spin_unlock_bh(&ip6_sk_fl_lock);
 		return -ESRCH;
 
 	case IPV6_FL_A_RENEW:
-		read_lock_bh(&ip6_sk_fl_lock);
-		for (sfl = np->ipv6_fl_list; sfl; sfl = sfl->next) {
+		rcu_read_lock_bh();
+		for_each_sk_fl_rcu(np, sfl) {
 			if (sfl->fl->label == freq.flr_label) {
 				err = fl6_renew(sfl->fl, freq.flr_linger, freq.flr_expires);
-				read_unlock_bh(&ip6_sk_fl_lock);
+				rcu_read_unlock_bh();
 				return err;
 			}
 		}
-		read_unlock_bh(&ip6_sk_fl_lock);
+		rcu_read_unlock_bh();
 
 		if (freq.flr_share == IPV6_FL_S_NONE &&
 		    ns_capable(net->user_ns, CAP_NET_ADMIN)) {
@@ -560,11 +568,11 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 
 		if (freq.flr_label) {
 			err = -EEXIST;
-			read_lock_bh(&ip6_sk_fl_lock);
-			for (sfl = np->ipv6_fl_list; sfl; sfl = sfl->next) {
+			rcu_read_lock_bh();
+			for_each_sk_fl_rcu(np, sfl) {
 				if (sfl->fl->label == freq.flr_label) {
 					if (freq.flr_flags&IPV6_FL_F_EXCL) {
-						read_unlock_bh(&ip6_sk_fl_lock);
+						rcu_read_unlock_bh();
 						goto done;
 					}
 					fl1 = sfl->fl;
@@ -572,7 +580,7 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 					break;
 				}
 			}
-			read_unlock_bh(&ip6_sk_fl_lock);
+			rcu_read_unlock_bh();
 
 			if (fl1 == NULL)
 				fl1 = fl_lookup(net, freq.flr_label);
-- 
1.7.9.5
