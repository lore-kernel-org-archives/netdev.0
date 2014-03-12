From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/7] tipc: replace reference table rwlock with spinlock
Date: Wed, 12 Mar 2014 11:31:07 -0400
Message-ID: <1394638273-6127-2-git-send-email-jon.maloy@ericsson.com>
References: <1394638273-6127-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.ne1.yahoo.com ([98.138.207.11]:33815 "HELO
	smtp104.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754899AbaCLPbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 11:31:21 -0400
In-Reply-To: <1394638273-6127-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lock for protecting the reference table is declared as an
RWLOCK, although it is only used in write mode, never in read
mode.

We redefine it to become a spinlock.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/ref.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index de3d593..67176b5 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -89,7 +89,7 @@ struct ref_table {
 
 static struct ref_table tipc_ref_table;
 
-static DEFINE_RWLOCK(ref_table_lock);
+static DEFINE_SPINLOCK(ref_table_lock);
 
 /**
  * tipc_ref_table_init - create reference table for objects
@@ -159,7 +159,7 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 	}
 
 	/* take a free entry, if available; otherwise initialize a new entry */
-	write_lock_bh(&ref_table_lock);
+	spin_lock_bh(&ref_table_lock);
 	if (tipc_ref_table.first_free) {
 		index = tipc_ref_table.first_free;
 		entry = &(tipc_ref_table.entries[index]);
@@ -175,7 +175,7 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 	} else {
 		ref = 0;
 	}
-	write_unlock_bh(&ref_table_lock);
+	spin_unlock_bh(&ref_table_lock);
 
 	/*
 	 * Grab the lock so no one else can modify this entry
@@ -216,7 +216,7 @@ void tipc_ref_discard(u32 ref)
 	index = ref & index_mask;
 	entry = &(tipc_ref_table.entries[index]);
 
-	write_lock_bh(&ref_table_lock);
+	spin_lock_bh(&ref_table_lock);
 
 	if (!entry->object) {
 		pr_err("Attempt to discard ref. to non-existent obj\n");
@@ -242,7 +242,7 @@ void tipc_ref_discard(u32 ref)
 	tipc_ref_table.last_free = index;
 
 exit:
-	write_unlock_bh(&ref_table_lock);
+	spin_unlock_bh(&ref_table_lock);
 }
 
 /**
-- 
1.7.9.5
