From: kaber@trash.net
Subject: [PATCH 34/37] netfilter: ip_tables: fix infoleak to userspace
Date: Tue, 15 Mar 2011 20:44:14 +0100
Message-ID: <1300218257-26953-35-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49431 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758474Ab1COTod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:33 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasiliy Kulikov <segoon@openwall.com>

Structures ipt_replace, compat_ipt_replace, and xt_get_revision are
copied from userspace.  Fields of these structs that are
zero-terminated strings are not checked.  When they are used as argument
to a format string containing "%s" in request_module(), some sensitive
information is leaked to userspace via argument of spawned modprobe
process.

The first and the third bugs were introduced before the git epoch; the
second was introduced in 2722971c (v2.6.17-rc1).  To trigger the bug
one should have CAP_NET_ADMIN.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ip_tables.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index ef7d7b9..b09ed0d 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1262,6 +1262,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	/* overflow check */
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
 		return -ENOMEM;
+	tmp.name[sizeof(tmp.name)-1] = 0;
 
 	newinfo = xt_alloc_table_info(tmp.size);
 	if (!newinfo)
@@ -1807,6 +1808,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 		return -ENOMEM;
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
 		return -ENOMEM;
+	tmp.name[sizeof(tmp.name)-1] = 0;
 
 	newinfo = xt_alloc_table_info(tmp.size);
 	if (!newinfo)
@@ -2036,6 +2038,7 @@ do_ipt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 			ret = -EFAULT;
 			break;
 		}
+		rev.name[sizeof(rev.name)-1] = 0;
 
 		if (cmd == IPT_SO_GET_REVISION_TARGET)
 			target = 1;
-- 
1.7.2.3

