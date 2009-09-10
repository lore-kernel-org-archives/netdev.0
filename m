From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 18/31: xtables: ignore unassigned hooks in check_entry_size_and_hooks
Date: Thu, 10 Sep 2009 18:12:10 +0200 (MEST)
Message-ID: <20090910161205.31179.87662.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit a7d51738e757c1ab94595e7d05594c61f0fb32ce
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sat Jul 18 14:52:58 2009 +0200

    netfilter: xtables: ignore unassigned hooks in check_entry_size_and_hooks
    
    The "hook_entry" and "underflow" array contains values even for hooks
    not provided, such as PREROUTING in conjunction with the "filter"
    table. Usually, the values point to whatever the next rule is. For
    the upcoming unconditionality and underflow checking patches however,
    we must not inspect that arbitrary rule.
    
    Skipping unassigned hooks seems like a good idea, also because
    newinfo->hook_entry and newinfo->underflow will then continue to have
    the poison value for detecting abnormalities.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index b9f7243..d91f083 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -539,6 +539,7 @@ static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 					     unsigned char *limit,
 					     const unsigned int *hook_entries,
 					     const unsigned int *underflows,
+					     unsigned int valid_hooks,
 					     unsigned int *i)
 {
 	unsigned int h;
@@ -558,6 +559,8 @@ static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 
 	/* Check hooks & underflows */
 	for (h = 0; h < NF_ARP_NUMHOOKS; h++) {
+		if (!(valid_hooks & (1 << h)))
+			continue;
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
 		if ((unsigned char *)e - base == underflows[h])
@@ -626,7 +629,7 @@ static int translate_table(const char *name,
 				 newinfo,
 				 entry0,
 				 entry0 + size,
-				 hook_entries, underflows, &i);
+				 hook_entries, underflows, valid_hooks, &i);
 	duprintf("translate_table: ARPT_ENTRY_ITERATE gives %d\n", ret);
 	if (ret != 0)
 		return ret;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 3431a77..6e7b7e8 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -714,6 +714,7 @@ check_entry_size_and_hooks(struct ipt_entry *e,
 			   unsigned char *limit,
 			   const unsigned int *hook_entries,
 			   const unsigned int *underflows,
+			   unsigned int valid_hooks,
 			   unsigned int *i)
 {
 	unsigned int h;
@@ -733,6 +734,8 @@ check_entry_size_and_hooks(struct ipt_entry *e,
 
 	/* Check hooks & underflows */
 	for (h = 0; h < NF_INET_NUMHOOKS; h++) {
+		if (!(valid_hooks & (1 << h)))
+			continue;
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
 		if ((unsigned char *)e - base == underflows[h])
@@ -804,7 +807,7 @@ translate_table(const char *name,
 				newinfo,
 				entry0,
 				entry0 + size,
-				hook_entries, underflows, &i);
+				hook_entries, underflows, valid_hooks, &i);
 	if (ret != 0)
 		return ret;
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 1389ad9..8e4921a 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -747,6 +747,7 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 			   unsigned char *limit,
 			   const unsigned int *hook_entries,
 			   const unsigned int *underflows,
+			   unsigned int valid_hooks,
 			   unsigned int *i)
 {
 	unsigned int h;
@@ -766,6 +767,8 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 
 	/* Check hooks & underflows */
 	for (h = 0; h < NF_INET_NUMHOOKS; h++) {
+		if (!(valid_hooks & (1 << h)))
+			continue;
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
 		if ((unsigned char *)e - base == underflows[h])
@@ -837,7 +840,7 @@ translate_table(const char *name,
 				newinfo,
 				entry0,
 				entry0 + size,
-				hook_entries, underflows, &i);
+				hook_entries, underflows, valid_hooks, &i);
 	if (ret != 0)
 		return ret;
 
