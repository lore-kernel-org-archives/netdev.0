From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] Use RCU for fib_rules
Date: Wed, 31 Mar 2004 11:28:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331112839.02e8d4c2@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Paul McKenney
 <Paul.McKenney@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The IP forwarding rules, uses rwlock when it could use RCU.
Don't know if this would help or hurt the recent discussions about
large rulesets and DOS attacks.

Also, it increases the size of fib_rule slightly.

Patch against 2.6.5-rc3

diff -Nru a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
--- a/net/ipv4/fib_rules.c	Wed Mar 31 11:24:52 2004
+++ b/net/ipv4/fib_rules.c	Wed Mar 31 11:24:52 2004
@@ -51,7 +51,7 @@
 
 struct fib_rule
 {
-	struct fib_rule *r_next;
+	struct list_head r_list;
 	atomic_t	r_clntref;
 	u32		r_preference;
 	unsigned char	r_table;
@@ -74,6 +74,7 @@
 #endif
 	char		r_ifname[IFNAMSIZ];
 	int		r_dead;
+	struct rcu_head	r_rcu;
 };
 
 static struct fib_rule default_rule = {
@@ -84,7 +85,6 @@
 };
 
 static struct fib_rule main_rule = {
-	.r_next =	&default_rule,
 	.r_clntref =	ATOMIC_INIT(2),
 	.r_preference =	0x7FFE,
 	.r_table =	RT_TABLE_MAIN,
@@ -92,23 +92,23 @@
 };
 
 static struct fib_rule local_rule = {
-	.r_next =	&main_rule,
 	.r_clntref =	ATOMIC_INIT(2),
 	.r_table =	RT_TABLE_LOCAL,
 	.r_action =	RTN_UNICAST,
 };
 
-static struct fib_rule *fib_rules = &local_rule;
-static rwlock_t fib_rules_lock = RW_LOCK_UNLOCKED;
+static LIST_HEAD(fib_rules);
+static spinlock_t fib_rules_lock = SPIN_LOCK_UNLOCKED;
 
 int inet_rtm_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct rtattr **rta = arg;
 	struct rtmsg *rtm = NLMSG_DATA(nlh);
-	struct fib_rule *r, **rp;
+	struct fib_rule *r;
 	int err = -ESRCH;
 
-	for (rp=&fib_rules; (r=*rp) != NULL; rp=&r->r_next) {
+	spin_lock_bh(&fib_rules_lock);
+	list_for_each_entry(r, &fib_rules, r_list) {
 		if ((!rta[RTA_SRC-1] || memcmp(RTA_DATA(rta[RTA_SRC-1]), &r->r_src, 4) == 0) &&
 		    rtm->rtm_src_len == r->r_src_len &&
 		    rtm->rtm_dst_len == r->r_dst_len &&
@@ -125,15 +125,15 @@
 			if (r == &local_rule)
 				break;
 
-			write_lock_bh(&fib_rules_lock);
-			*rp = r->r_next;
+			list_del_rcu(&r->r_list);
 			r->r_dead = 1;
-			write_unlock_bh(&fib_rules_lock);
-			fib_rule_put(r);
+			call_rcu(&r->r_rcu, 
+				 (void (*)(void *))fib_rule_put, r);
 			err = 0;
 			break;
 		}
 	}
+	spin_unlock_bh(&fib_rules_lock);
 	return err;
 }
 
@@ -163,7 +163,7 @@
 {
 	struct rtattr **rta = arg;
 	struct rtmsg *rtm = NLMSG_DATA(nlh);
-	struct fib_rule *r, *new_r, **rp;
+	struct fib_rule *r, *new_r;
 	unsigned char table_id;
 
 	if (rtm->rtm_src_len > 32 || rtm->rtm_dst_len > 32 ||
@@ -221,27 +221,27 @@
 		memcpy(&new_r->r_tclassid, RTA_DATA(rta[RTA_FLOW-1]), 4);
 #endif
 
-	rp = &fib_rules;
+
+	spin_lock_bh(&fib_rules_lock);
+	r = list_entry(&fib_rules, struct fib_rule, r_list);
 	if (!new_r->r_preference) {
-		r = fib_rules;
-		if (r && (r = r->r_next) != NULL) {
-			rp = &fib_rules->r_next;
+		if (!list_empty(&fib_rules)) {
+			r = list_entry(fib_rules.next, struct fib_rule, r_list);
 			if (r->r_preference)
 				new_r->r_preference = r->r_preference - 1;
 		}
 	}
 
-	while ( (r = *rp) != NULL ) {
+	list_for_each_entry_continue(r, &fib_rules, r_list) {
 		if (r->r_preference > new_r->r_preference)
 			break;
-		rp = &r->r_next;
 	}
 
-	new_r->r_next = r;
 	atomic_inc(&new_r->r_clntref);
-	write_lock_bh(&fib_rules_lock);
-	*rp = new_r;
-	write_unlock_bh(&fib_rules_lock);
+
+	list_add_rcu(&new_r->r_list, &r->r_list);
+	spin_unlock_bh(&fib_rules_lock);
+
 	return 0;
 }
 
@@ -285,26 +285,30 @@
 {
 	struct fib_rule *r;
 
-	for (r=fib_rules; r; r=r->r_next) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(r, &fib_rules, r_list) {
 		if (r->r_ifindex == dev->ifindex) {
-			write_lock_bh(&fib_rules_lock);
+			spin_lock_bh(&fib_rules_lock);
 			r->r_ifindex = -1;
-			write_unlock_bh(&fib_rules_lock);
+			spin_unlock_bh(&fib_rules_lock);
 		}
 	}
+	rcu_read_unlock();
 }
 
 static void fib_rules_attach(struct net_device *dev)
 {
 	struct fib_rule *r;
 
-	for (r=fib_rules; r; r=r->r_next) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(r, &fib_rules, r_list) {
 		if (r->r_ifindex == -1 && strcmp(dev->name, r->r_ifname) == 0) {
-			write_lock_bh(&fib_rules_lock);
+			spin_lock_bh(&fib_rules_lock);
 			r->r_ifindex = dev->ifindex;
-			write_unlock_bh(&fib_rules_lock);
+			spin_unlock_bh(&fib_rules_lock);
 		}
 	}
+	rcu_read_unlock();
 }
 
 int fib_lookup(const struct flowi *flp, struct fib_result *res)
@@ -318,8 +322,9 @@
 
 FRprintk("Lookup: %u.%u.%u.%u <- %u.%u.%u.%u ",
 	NIPQUAD(flp->fl4_dst), NIPQUAD(flp->fl4_src));
-	read_lock(&fib_rules_lock);
-	for (r = fib_rules; r; r=r->r_next) {
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(r, &fib_rules, r_list) {
 		if (((saddr^r->r_src) & r->r_srcmask) ||
 		    ((daddr^r->r_dst) & r->r_dstmask) ||
 #ifdef CONFIG_IP_ROUTE_TOS
@@ -342,10 +347,10 @@
 			return -ENETUNREACH;
 		default:
 		case RTN_BLACKHOLE:
-			read_unlock(&fib_rules_lock);
+			rcu_read_unlock(); 
 			return -EINVAL;
 		case RTN_PROHIBIT:
-			read_unlock(&fib_rules_lock);
+			rcu_read_unlock();
 			return -EACCES;
 		}
 
@@ -356,16 +361,18 @@
 			res->r = policy;
 			if (policy)
 				atomic_inc(&policy->r_clntref);
-			read_unlock(&fib_rules_lock);
+
+			rcu_read_unlock(); 
 			return 0;
 		}
 		if (err < 0 && err != -EAGAIN) {
-			read_unlock(&fib_rules_lock);
+			rcu_read_unlock(); 
 			return err;
 		}
 	}
 FRprintk("FAILURE\n");
-	read_unlock(&fib_rules_lock);
+
+	rcu_read_unlock(); 
 	return -ENETUNREACH;
 }
 
@@ -391,8 +398,8 @@
 }
 
 
-struct notifier_block fib_rules_notifier = {
-	.notifier_call =fib_rules_event,
+static struct notifier_block fib_rules_notifier = {
+	.notifier_call = fib_rules_event,
 };
 
 static __inline__ int inet_fill_rule(struct sk_buff *skb,
@@ -444,18 +451,16 @@
 
 int inet_dump_rules(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int idx;
+	int idx = 0;
 	int s_idx = cb->args[0];
 	struct fib_rule *r;
 
-	read_lock(&fib_rules_lock);
-	for (r=fib_rules, idx=0; r; r = r->r_next, idx++) {
-		if (idx < s_idx)
-			continue;
-		if (inet_fill_rule(skb, r, cb) < 0)
+	rcu_read_lock();
+	list_for_each_entry_rcu(r, &fib_rules, r_list) {
+		if (idx++ >= s_idx && inet_fill_rule(skb, r, cb) < 0)
 			break;
 	}
-	read_unlock(&fib_rules_lock);
+	rcu_read_unlock();
 	cb->args[0] = idx;
 
 	return skb->len;
@@ -464,4 +469,10 @@
 void __init fib_rules_init(void)
 {
 	register_netdevice_notifier(&fib_rules_notifier);
+
+	spin_lock_bh(&fib_rules_lock);
+	list_add_rcu(&local_rule.r_list, &fib_rules);
+	list_add_rcu(&main_rule.r_list, &local_rule.r_list);
+	list_add_rcu(&default_rule.r_list, &main_rule.r_list);
+	spin_unlock_bh(&fib_rules_lock);
 }
