From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 3/7][RFC] netfilter: qtaguid: initialize a local var to keep compiler happy.
Date: Fri, 21 Sep 2012 22:10:49 -0400
Message-ID: <1348279853-44499-4-git-send-email-john.stultz@linaro.org>
References: <1348279853-44499-1-git-send-email-john.stultz@linaro.org>
Cc: JP Abgrall <jpa@google.com>, netdev@vger.kernel.org,
	Ashish Sharma <ashishsharma@google.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	John Stultz <john.stultz@linaro.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348279853-44499-1-git-send-email-john.stultz@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: JP Abgrall <jpa@google.com>

There was a case that might have seemed like new_tag_stat was not
initialized and actually used.
Added comment explaining why it was impossible, and a BUG()
in case the logic gets changed.

Cc: netdev@vger.kernel.org
Cc: JP Abgrall <jpa@google.com>
Cc: Ashish Sharma <ashishsharma@google.com>
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: JP Abgrall <jpa@google.com>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 net/netfilter/xt_qtaguid.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/xt_qtaguid.c b/net/netfilter/xt_qtaguid.c
index 7c4ac46..214a990 100644
--- a/net/netfilter/xt_qtaguid.c
+++ b/net/netfilter/xt_qtaguid.c
@@ -1255,7 +1255,7 @@ static void if_tag_stat_update(const char *ifname, uid_t uid,
 	struct data_counters *uid_tag_counters;
 	struct sock_tag *sock_tag_entry;
 	struct iface_stat *iface_entry;
-	struct tag_stat *new_tag_stat;
+	struct tag_stat *new_tag_stat = NULL;
 	MT_DEBUG("qtaguid: if_tag_stat_update(ifname=%s "
 		"uid=%u sk=%p dir=%d proto=%d bytes=%d)\n",
 		 ifname, uid, sk, direction, proto, bytes);
@@ -1320,8 +1320,19 @@ static void if_tag_stat_update(const char *ifname, uid_t uid,
 	}
 
 	if (acct_tag) {
+		/* Create the child {acct_tag, uid_tag} and hook up parent. */
 		new_tag_stat = create_if_tag_stat(iface_entry, tag);
 		new_tag_stat->parent_counters = uid_tag_counters;
+	} else {
+		/*
+		 * For new_tag_stat to be still NULL here would require:
+		 *  {0, uid_tag} exists
+		 *  and {acct_tag, uid_tag} doesn't exist
+		 *  AND acct_tag == 0.
+		 * Impossible. This reassures us that new_tag_stat
+		 * below will always be assigned.
+		 */
+		BUG_ON(!new_tag_stat);
 	}
 	tag_stat_update(new_tag_stat, direction, proto, bytes);
 	spin_unlock_bh(&iface_entry->tag_stat_list_lock);
-- 
1.7.9.5
