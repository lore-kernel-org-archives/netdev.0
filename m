From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net-next 2/4] netns: ebtable: allow unprivileged users to operate ebtables
Date: Fri, 1 Feb 2013 10:30:58 +0800
Message-ID: <1359685860-29636-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1359685860-29636-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	ebiederm@xmission.com, serge@hallyn.com, pablo@netfilter.org,
	amwang@redhat.com, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:3031 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754323Ab3BACao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 21:30:44 -0500
In-Reply-To: <1359685860-29636-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebt_table is a private resource of netns, operating ebtables
in one netns will not affect other netns, we can allow the
creator user of userns and netns to change the ebtables.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/bridge/netfilter/ebtables.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 5fe2ff3..8d493c9 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1472,16 +1472,17 @@ static int do_ebt_set_ctl(struct sock *sk,
 	int cmd, void __user *user, unsigned int len)
 {
 	int ret;
+	struct net *net = sock_net(sk);
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch(cmd) {
 	case EBT_SO_SET_ENTRIES:
-		ret = do_replace(sock_net(sk), user, len);
+		ret = do_replace(net, user, len);
 		break;
 	case EBT_SO_SET_COUNTERS:
-		ret = update_counters(sock_net(sk), user, len);
+		ret = update_counters(net, user, len);
 		break;
 	default:
 		ret = -EINVAL;
@@ -1494,14 +1495,15 @@ static int do_ebt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	int ret;
 	struct ebt_replace tmp;
 	struct ebt_table *t;
+	struct net *net = sock_net(sk);
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (copy_from_user(&tmp, user, sizeof(tmp)))
 		return -EFAULT;
 
-	t = find_table_lock(sock_net(sk), tmp.name, &ret, &ebt_mutex);
+	t = find_table_lock(net, tmp.name, &ret, &ebt_mutex);
 	if (!t)
 		return ret;
 
@@ -2279,16 +2281,17 @@ static int compat_do_ebt_set_ctl(struct sock *sk,
 		int cmd, void __user *user, unsigned int len)
 {
 	int ret;
+	struct net *net = sock_net(sk);
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
 	case EBT_SO_SET_ENTRIES:
-		ret = compat_do_replace(sock_net(sk), user, len);
+		ret = compat_do_replace(net, user, len);
 		break;
 	case EBT_SO_SET_COUNTERS:
-		ret = compat_update_counters(sock_net(sk), user, len);
+		ret = compat_update_counters(net, user, len);
 		break;
 	default:
 		ret = -EINVAL;
@@ -2302,8 +2305,9 @@ static int compat_do_ebt_get_ctl(struct sock *sk, int cmd,
 	int ret;
 	struct compat_ebt_replace tmp;
 	struct ebt_table *t;
+	struct net *net = sock_net(sk);
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	/* try real handler in case userland supplied needed padding */
@@ -2314,7 +2318,7 @@ static int compat_do_ebt_get_ctl(struct sock *sk, int cmd,
 	if (copy_from_user(&tmp, user, sizeof(tmp)))
 		return -EFAULT;
 
-	t = find_table_lock(sock_net(sk), tmp.name, &ret, &ebt_mutex);
+	t = find_table_lock(net, tmp.name, &ret, &ebt_mutex);
 	if (!t)
 		return ret;
 
-- 
1.7.11.7
