From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 20/31: xtables: check for standard verdicts in policies
Date: Thu, 10 Sep 2009 18:12:12 +0200 (MEST)
Message-ID: <20090910161208.31179.83644.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit e2fe35c17fed62d4ab5038fa9bc489e967ff8416
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sat Jul 18 15:22:30 2009 +0200

    netfilter: xtables: check for standard verdicts in policies
    
    This adds the second check that Rusty wanted to have a long time ago. :-)
    
    Base chain policies must have absolute verdicts that cease processing
    in the table, otherwise rule execution may continue in an unexpected
    spurious fashion (e.g. next chain that follows in memory).
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 064082d..7bc11ff 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -533,6 +533,21 @@ out:
 	return ret;
 }
 
+static bool check_underflow(struct arpt_entry *e)
+{
+	const struct arpt_entry_target *t;
+	unsigned int verdict;
+
+	if (!unconditional(&e->arp))
+		return false;
+	t = arpt_get_target(e);
+	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) != 0)
+		return false;
+	verdict = ((struct arpt_standard_target *)t)->verdict;
+	verdict = -verdict - 1;
+	return verdict == NF_DROP || verdict == NF_ACCEPT;
+}
+
 static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 					     struct xt_table_info *newinfo,
 					     unsigned char *base,
@@ -564,8 +579,10 @@ static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
 		if ((unsigned char *)e - base == underflows[h]) {
-			if (!unconditional(&e->arp)) {
-				pr_err("Underflows must be unconditional\n");
+			if (!check_underflow(e)) {
+				pr_err("Underflows must be unconditional and "
+				       "use the STANDARD target with "
+				       "ACCEPT/DROP\n");
 				return -EINVAL;
 			}
 			newinfo->underflow[h] = underflows[h];
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 6e546d5..0b43fd7 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -708,6 +708,21 @@ find_check_entry(struct ipt_entry *e, const char *name, unsigned int size,
 	return ret;
 }
 
+static bool check_underflow(struct ipt_entry *e)
+{
+	const struct ipt_entry_target *t;
+	unsigned int verdict;
+
+	if (!unconditional(&e->ip))
+		return false;
+	t = ipt_get_target(e);
+	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) != 0)
+		return false;
+	verdict = ((struct ipt_standard_target *)t)->verdict;
+	verdict = -verdict - 1;
+	return verdict == NF_DROP || verdict == NF_ACCEPT;
+}
+
 static int
 check_entry_size_and_hooks(struct ipt_entry *e,
 			   struct xt_table_info *newinfo,
@@ -740,8 +755,10 @@ check_entry_size_and_hooks(struct ipt_entry *e,
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
 		if ((unsigned char *)e - base == underflows[h]) {
-			if (!unconditional(&e->ip)) {
-				pr_err("Underflows must be unconditional\n");
+			if (!check_underflow(e)) {
+				pr_err("Underflows must be unconditional and "
+				       "use the STANDARD target with "
+				       "ACCEPT/DROP\n");
 				return -EINVAL;
 			}
 			newinfo->underflow[h] = underflows[h];
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index b0599b9..a5d0c27 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -740,6 +740,21 @@ find_check_entry(struct ip6t_entry *e, const char *name, unsigned int size,
 	return ret;
 }
 
+static bool check_underflow(struct ip6t_entry *e)
+{
+	const struct ip6t_entry_target *t;
+	unsigned int verdict;
+
+	if (!unconditional(&e->ipv6))
+		return false;
+	t = ip6t_get_target(e);
+	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) != 0)
+		return false;
+	verdict = ((struct ip6t_standard_target *)t)->verdict;
+	verdict = -verdict - 1;
+	return verdict == NF_DROP || verdict == NF_ACCEPT;
+}
+
 static int
 check_entry_size_and_hooks(struct ip6t_entry *e,
 			   struct xt_table_info *newinfo,
@@ -772,8 +787,10 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
 		if ((unsigned char *)e - base == underflows[h]) {
-			if (!unconditional(&e->ipv6)) {
-				pr_err("Underflows must be unconditional\n");
+			if (!check_underflow(e)) {
+				pr_err("Underflows must be unconditional and "
+				       "use the STANDARD target with "
+				       "ACCEPT/DROP\n");
 				return -EINVAL;
 			}
 			newinfo->underflow[h] = underflows[h];
