From: pablo@netfilter.org
Subject: [PATCH 1/6] netfilter: ebtables: fix wrong name length while copying to user-space
Date: Tue,  6 Mar 2012 12:22:50 +0100
Message-ID: <1331032975-5303-2-git-send-email-pablo@netfilter.org>
References: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48317 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759079Ab2CFLXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2012 06:23:08 -0500
In-Reply-To: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Nayak <santoshprasadnayak@gmail.com>

user-space ebtables expects 32 bytes-long names, but xt_match names
use 29 bytes. We have to copy less 29 bytes and then, make sure we
fill the remaining bytes with zeroes.

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtables.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 8aa4ad0..15e9575 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1335,7 +1335,12 @@ static inline int ebt_make_matchname(const struct ebt_entry_match *m,
     const char *base, char __user *ubase)
 {
 	char __user *hlp = ubase + ((char *)m - base);
-	if (copy_to_user(hlp, m->u.match->name, EBT_FUNCTION_MAXNAMELEN))
+	char name[EBT_FUNCTION_MAXNAMELEN] = {};
+
+	/* ebtables expects 32 bytes long names but xt_match names are 29 bytes
+	   long. Copy 29 bytes and fill remaining bytes with zeroes. */
+	strncpy(name, m->u.match->name, sizeof(name));
+	if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
 		return -EFAULT;
 	return 0;
 }
@@ -1344,7 +1349,10 @@ static inline int ebt_make_watchername(const struct ebt_entry_watcher *w,
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
@@ -1355,10 +1363,12 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 	int ret;
 	char __user *hlp;
 	const struct ebt_entry_target *t;
+	char name[EBT_FUNCTION_MAXNAMELEN] = {};
 
 	if (e->bitmask == 0)
 		return 0;
 
+	strncpy(name, t->u.target->name, sizeof(name));
 	hlp = ubase + (((char *)e + e->target_offset) - base);
 	t = (struct ebt_entry_target *)(((char *)e) + e->target_offset);
 
@@ -1368,7 +1378,7 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 	ret = EBT_WATCHER_ITERATE(e, ebt_make_watchername, base, ubase);
 	if (ret != 0)
 		return ret;
-	if (copy_to_user(hlp, t->u.target->name, EBT_FUNCTION_MAXNAMELEN))
+	if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
 		return -EFAULT;
 	return 0;
 }
-- 
1.7.7.3
