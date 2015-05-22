From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/3] netfilter: ensure number of counters is >0 in do_replace()
Date: Fri, 22 May 2015 12:34:05 +0200
Message-ID: <1432290846-4310-3-git-send-email-pablo@netfilter.org>
References: <1432290846-4310-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1432290846-4310-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@codemonkey.org.uk>

After improving setsockopt() coverage in trinity, I started triggering
vmalloc failures pretty reliably from this code path:

warn_alloc_failed+0xe9/0x140
__vmalloc_node_range+0x1be/0x270
vzalloc+0x4b/0x50
__do_replace+0x52/0x260 [ip_tables]
do_ipt_set_ctl+0x15d/0x1d0 [ip_tables]
nf_setsockopt+0x65/0x90
ip_setsockopt+0x61/0xa0
raw_setsockopt+0x16/0x60
sock_common_setsockopt+0x14/0x20
SyS_setsockopt+0x71/0xd0

It turns out we don't validate that the num_counters field in the
struct we pass in from userspace is initialized.

The same problem also exists in ebtables, arptables, ipv6, and the
compat variants.

Signed-off-by: Dave Jones <davej@codemonkey.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtables.c |    4 ++++
 net/ipv4/netfilter/arp_tables.c |    6 ++++++
 net/ipv4/netfilter/ip_tables.c  |    6 ++++++
 net/ipv6/netfilter/ip6_tables.c |    6 ++++++
 4 files changed, 22 insertions(+)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 91180a7..24c7c96 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1117,6 +1117,8 @@ static int do_replace(struct net *net, const void __user *user,
 		return -ENOMEM;
 	if (tmp.num_counters >= INT_MAX / sizeof(struct ebt_counter))
 		return -ENOMEM;
+	if (tmp.num_counters == 0)
+		return -EINVAL;
 
 	tmp.name[sizeof(tmp.name) - 1] = 0;
 
@@ -2159,6 +2161,8 @@ static int compat_copy_ebt_replace_from_user(struct ebt_replace *repl,
 		return -ENOMEM;
 	if (tmp.num_counters >= INT_MAX / sizeof(struct ebt_counter))
 		return -ENOMEM;
+	if (tmp.num_counters == 0)
+		return -EINVAL;
 
 	memcpy(repl, &tmp, offsetof(struct ebt_replace, hook_entry));
 
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 13bfe84..a612007 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1075,6 +1075,9 @@ static int do_replace(struct net *net, const void __user *user,
 	/* overflow check */
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
 		return -ENOMEM;
+	if (tmp.num_counters == 0)
+		return -EINVAL;
+
 	tmp.name[sizeof(tmp.name)-1] = 0;
 
 	newinfo = xt_alloc_table_info(tmp.size);
@@ -1499,6 +1502,9 @@ static int compat_do_replace(struct net *net, void __user *user,
 		return -ENOMEM;
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
 		return -ENOMEM;
+	if (tmp.num_counters == 0)
+		return -EINVAL;
+
 	tmp.name[sizeof(tmp.name)-1] = 0;
 
 	newinfo = xt_alloc_table_info(tmp.size);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index c69db7f..2d0e265 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1262,6 +1262,9 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	/* overflow check */
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
 		return -ENOMEM;
+	if (tmp.num_counters == 0)
+		return -EINVAL;
+
 	tmp.name[sizeof(tmp.name)-1] = 0;
 
 	newinfo = xt_alloc_table_info(tmp.size);
@@ -1809,6 +1812,9 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 		return -ENOMEM;
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
 		return -ENOMEM;
+	if (tmp.num_counters == 0)
+		return -EINVAL;
+
 	tmp.name[sizeof(tmp.name)-1] = 0;
 
 	newinfo = xt_alloc_table_info(tmp.size);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 1a732a1..62f5b0d 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1275,6 +1275,9 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	/* overflow check */
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
 		return -ENOMEM;
+	if (tmp.num_counters == 0)
+		return -EINVAL;
+
 	tmp.name[sizeof(tmp.name)-1] = 0;
 
 	newinfo = xt_alloc_table_info(tmp.size);
@@ -1822,6 +1825,9 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 		return -ENOMEM;
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
 		return -ENOMEM;
+	if (tmp.num_counters == 0)
+		return -EINVAL;
+
 	tmp.name[sizeof(tmp.name)-1] = 0;
 
 	newinfo = xt_alloc_table_info(tmp.size);
-- 
1.7.10.4

