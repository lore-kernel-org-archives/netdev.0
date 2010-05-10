From: kaber@trash.net
Subject: [PATCH 15/84] netfilter: xt_recent: add an entry reaper
Date: Mon, 10 May 2010 22:17:46 +0200
Message-ID: <1273522735-24672-16-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54506 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756669Ab0EJUTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:00 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Gardner <tim.gardner@canonical.com>

One of the problems with the way xt_recent is implemented is that
there is no efficient way to remove expired entries. Of course,
one can write a rule '-m recent --remove', but you have to know
beforehand which entry to delete. This commit adds reaper
logic which checks the head of the LRU list when a rule
is invoked that has a '--seconds' value and XT_RECENT_REAP set. If an
entry ceases to accumulate time stamps, then it will eventually bubble
to the top of the LRU list where it is then reaped.

Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/xt_recent.h |    4 ++++
 net/netfilter/xt_recent.c           |   28 +++++++++++++++++++++++++++-
 2 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/xt_recent.h b/include/linux/netfilter/xt_recent.h
index d2c2766..bba990e 100644
--- a/include/linux/netfilter/xt_recent.h
+++ b/include/linux/netfilter/xt_recent.h
@@ -9,6 +9,7 @@ enum {
 	XT_RECENT_UPDATE   = 1 << 2,
 	XT_RECENT_REMOVE   = 1 << 3,
 	XT_RECENT_TTL      = 1 << 4,
+	XT_RECENT_REAP     = 1 << 5,
 
 	XT_RECENT_SOURCE   = 0,
 	XT_RECENT_DEST     = 1,
@@ -16,6 +17,9 @@ enum {
 	XT_RECENT_NAME_LEN = 200,
 };
 
+/* Only allowed with --rcheck and --update */
+#define XT_RECENT_MODIFIERS (XT_RECENT_TTL|XT_RECENT_REAP)
+
 struct xt_recent_mtinfo {
 	__u32 seconds;
 	__u32 hit_count;
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 2ff8aae..b65eca9 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -143,6 +143,25 @@ static void recent_entry_remove(struct recent_table *t, struct recent_entry *e)
 	t->entries--;
 }
 
+/*
+ * Drop entries with timestamps older then 'time'.
+ */
+static void recent_entry_reap(struct recent_table *t, unsigned long time)
+{
+	struct recent_entry *e;
+
+	/*
+	 * The head of the LRU list is always the oldest entry.
+	 */
+	e = list_entry(t->lru_list.next, struct recent_entry, lru_list);
+
+	/*
+	 * The last time stamp is the most recent.
+	 */
+	if (time_after(time, e->stamps[e->index-1]))
+		recent_entry_remove(t, e);
+}
+
 static struct recent_entry *
 recent_entry_init(struct recent_table *t, const union nf_inet_addr *addr,
 		  u_int16_t family, u_int8_t ttl)
@@ -269,6 +288,10 @@ recent_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 				break;
 			}
 		}
+
+		/* info->seconds must be non-zero */
+		if (info->check_set & XT_RECENT_REAP)
+			recent_entry_reap(t, time);
 	}
 
 	if (info->check_set & XT_RECENT_SET ||
@@ -301,7 +324,10 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 		      XT_RECENT_CHECK | XT_RECENT_UPDATE)) != 1)
 		return false;
 	if ((info->check_set & (XT_RECENT_SET | XT_RECENT_REMOVE)) &&
-	    (info->seconds || info->hit_count))
+	    (info->seconds || info->hit_count ||
+	    (info->check_set & XT_RECENT_MODIFIERS)))
+		return false;
+	if ((info->check_set & XT_RECENT_REAP) && !info->seconds)
 		return false;
 	if (info->hit_count > ip_pkt_list_tot) {
 		pr_info(KBUILD_MODNAME ": hitcount (%u) is larger than "
-- 
1.7.0.4

