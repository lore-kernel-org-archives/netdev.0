From: santosh nayak <santoshprasadnayak@gmail.com>
Subject: Resend [PATCH] netfilter: Fix copy_to_user too small size parametre.
Date: Thu,  1 Mar 2012 22:39:03 +0530
Message-ID: <1330621743-12883-1-git-send-email-santoshprasadnayak@gmail.com>
Cc: pablo@netfilter.org, kaber@trash.net, shemminger@vyatta.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Santosh Nayak <santoshprasadnayak@gmail.com>
To: bart.de.schuymer@pandora.be
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Nayak <santoshprasadnayak@gmail.com>

user-space ebtables expects 32 bytes-long names, but xt_match uses
29 bytes. Fill the remaining bytes with zeroes.

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
---
 net/bridge/netfilter/ebtables.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 5864cc4..21f337a 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1335,7 +1335,10 @@ static inline int ebt_make_matchname(const struct ebt_entry_match *m,
     const char *base, char __user *ubase)
 {
 	char __user *hlp = ubase + ((char *)m - base);
-	if (copy_to_user(hlp, m->u.match->name, EBT_FUNCTION_MAXNAMELEN))
+	char name[EBT_FUNCTION_MAXNAMELEN] = {};
+
+	strncpy(name, m->u.match->name, sizeof(name));
+	if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
 		return -EFAULT;
 	return 0;
 }
@@ -1344,7 +1347,10 @@ static inline int ebt_make_watchername(const struct ebt_entry_watcher *w,
     const char *base, char __user *ubase)
 {
 	char __user *hlp = ubase + ((char *)w - base);
-	if (copy_to_user(hlp , w->u.watcher->name, EBT_FUNCTION_MAXNAMELEN))
+	char name[EBT_FUNCTION_MAXNAMELEN] = {};
+
+	strncpy(name, w->u.watcher->name, sizeof(name));
+	if (copy_to_user(hlp , name, EBT_FUNCTION_MAXNAMELEN))
 		return -EFAULT;
 	return 0;
 }
@@ -1355,10 +1361,12 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 	int ret;
 	char __user *hlp;
 	const struct ebt_entry_target *t;
+	char name[EBT_FUNCTION_MAXNAMELEN] = {};
 
 	if (e->bitmask == 0)
 		return 0;
 
+	strncpy(name, t->u.target->name, sizeof(name));
 	hlp = ubase + (((char *)e + e->target_offset) - base);
 	t = (struct ebt_entry_target *)(((char *)e) + e->target_offset);
 
@@ -1368,7 +1376,7 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 	ret = EBT_WATCHER_ITERATE(e, ebt_make_watchername, base, ubase);
 	if (ret != 0)
 		return ret;
-	if (copy_to_user(hlp, t->u.target->name, EBT_FUNCTION_MAXNAMELEN))
+	if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
 		return -EFAULT;
 	return 0;
 }
-- 
1.7.4.4
