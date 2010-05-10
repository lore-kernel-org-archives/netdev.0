From: kaber@trash.net
Subject: [PATCH 78/84] netfilter: x_tables: move sleeping allocation outside BH-disabled region
Date: Mon, 10 May 2010 22:18:49 +0200
Message-ID: <1273522735-24672-79-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

The jumpstack allocation needs to be moved out of the critical region.
Corrects this notice:

BUG: sleeping function called from invalid context at mm/slub.c:1705
[  428.295762] in_atomic(): 1, irqs_disabled(): 0, pid: 9111, name: iptables
[  428.295771] Pid: 9111, comm: iptables Not tainted 2.6.34-rc1 #2
[  428.295776] Call Trace:
[  428.295791]  [<c012138e>] __might_sleep+0xe5/0xed
[  428.295801]  [<c019e8ca>] __kmalloc+0x92/0xfc
[  428.295825]  [<f865b3bb>] ? xt_jumpstack_alloc+0x36/0xff [x_tables]

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/x_tables.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 3ae3234..445de70 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -801,6 +801,12 @@ xt_replace_table(struct xt_table *table,
 	struct xt_table_info *private;
 	int ret;
 
+	ret = xt_jumpstack_alloc(newinfo);
+	if (ret < 0) {
+		*error = ret;
+		return NULL;
+	}
+
 	/* Do the substitution. */
 	local_bh_disable();
 	private = table->private;
@@ -814,12 +820,6 @@ xt_replace_table(struct xt_table *table,
 		return NULL;
 	}
 
-	ret = xt_jumpstack_alloc(newinfo);
-	if (ret < 0) {
-		*error = ret;
-		return NULL;
-	}
-
 	table->private = newinfo;
 	newinfo->initial_entries = private->initial_entries;
 
-- 
1.7.0.4

