From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/9] netfilter: x_tables: enforce nul-terminated table name from getsockopt GET_ENTRIES
Date: Mon, 28 Mar 2016 19:58:01 +0200
Message-ID: <1459187882-5357-9-git-send-email-pablo@netfilter.org>
References: <1459187882-5357-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50841 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754738AbcC1R6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 13:58:16 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C7ED6E8397
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:14 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 817DEDA386
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:15 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 792B0DA38B
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:13 +0200 (CEST)
In-Reply-To: <1459187882-5357-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure the table names via getsockopt GET_ENTRIES is nul-terminated
in ebtables and all the x_tables variants and their respective compat
code. Uncovered by KASAN.

Reported-by: Baozeng Ding <sploving1@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtables.c | 4 ++++
 net/ipv4/netfilter/arp_tables.c | 2 ++
 net/ipv4/netfilter/ip_tables.c  | 2 ++
 net/ipv6/netfilter/ip6_tables.c | 2 ++
 4 files changed, 10 insertions(+)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 67b2e27..8570bc7 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1521,6 +1521,8 @@ static int do_ebt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	if (copy_from_user(&tmp, user, sizeof(tmp)))
 		return -EFAULT;
 
+	tmp.name[sizeof(tmp.name) - 1] = '\0';
+
 	t = find_table_lock(net, tmp.name, &ret, &ebt_mutex);
 	if (!t)
 		return ret;
@@ -2332,6 +2334,8 @@ static int compat_do_ebt_get_ctl(struct sock *sk, int cmd,
 	if (copy_from_user(&tmp, user, sizeof(tmp)))
 		return -EFAULT;
 
+	tmp.name[sizeof(tmp.name) - 1] = '\0';
+
 	t = find_table_lock(net, tmp.name, &ret, &ebt_mutex);
 	if (!t)
 		return ret;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index a1bb5e7..4133b0f 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -969,6 +969,7 @@ static int get_entries(struct net *net, struct arpt_get_entries __user *uptr,
 			 sizeof(struct arpt_get_entries) + get.size);
 		return -EINVAL;
 	}
+	get.name[sizeof(get.name) - 1] = '\0';
 
 	t = xt_find_table_lock(net, NFPROTO_ARP, get.name);
 	if (!IS_ERR_OR_NULL(t)) {
@@ -1663,6 +1664,7 @@ static int compat_get_entries(struct net *net,
 			 *len, sizeof(get) + get.size);
 		return -EINVAL;
 	}
+	get.name[sizeof(get.name) - 1] = '\0';
 
 	xt_compat_lock(NFPROTO_ARP);
 	t = xt_find_table_lock(net, NFPROTO_ARP, get.name);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 89b5d95..631c100 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1156,6 +1156,7 @@ get_entries(struct net *net, struct ipt_get_entries __user *uptr,
 			 *len, sizeof(get) + get.size);
 		return -EINVAL;
 	}
+	get.name[sizeof(get.name) - 1] = '\0';
 
 	t = xt_find_table_lock(net, AF_INET, get.name);
 	if (!IS_ERR_OR_NULL(t)) {
@@ -1935,6 +1936,7 @@ compat_get_entries(struct net *net, struct compat_ipt_get_entries __user *uptr,
 			 *len, sizeof(get) + get.size);
 		return -EINVAL;
 	}
+	get.name[sizeof(get.name) - 1] = '\0';
 
 	xt_compat_lock(AF_INET);
 	t = xt_find_table_lock(net, AF_INET, get.name);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 541b59f..86b67b7 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1168,6 +1168,7 @@ get_entries(struct net *net, struct ip6t_get_entries __user *uptr,
 			 *len, sizeof(get) + get.size);
 		return -EINVAL;
 	}
+	get.name[sizeof(get.name) - 1] = '\0';
 
 	t = xt_find_table_lock(net, AF_INET6, get.name);
 	if (!IS_ERR_OR_NULL(t)) {
@@ -1944,6 +1945,7 @@ compat_get_entries(struct net *net, struct compat_ip6t_get_entries __user *uptr,
 			 *len, sizeof(get) + get.size);
 		return -EINVAL;
 	}
+	get.name[sizeof(get.name) - 1] = '\0';
 
 	xt_compat_lock(AF_INET6);
 	t = xt_find_table_lock(net, AF_INET6, get.name);
-- 
2.1.4
