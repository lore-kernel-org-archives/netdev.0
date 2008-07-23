From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] ipt_recent: fix race between recent_mt_destroy and proc manipulations
Date: Thu, 24 Jul 2008 01:29:10 +0400
Message-ID: <4887A2A6.1010704@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The thing is that recent_mt_destroy first flushes the entries
from table with the recent_table_flush and only *after* this
removes the proc file, corresponding to that table.

Thus, if we manage to write to this file the '+XXX' command we
will leak some entries. If we manage to write there a 'clean'
command we'll race in two recent_table_flush flows, since the
recent_mt_destroy calls this outside the recent_lock.

The proper solution as I see it is to remove the proc file first
and then go on with flushing the table. This flushing becomes
safe w/o the lock, since the table is already inaccessible from
the outside.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/netfilter/ipt_recent.c b/net/ipv4/netfilter/ipt_recent.c
index 21cb053..3974d7c 100644
--- a/net/ipv4/netfilter/ipt_recent.c
+++ b/net/ipv4/netfilter/ipt_recent.c
@@ -305,10 +305,10 @@ static void recent_mt_destroy(const struct xt_match *match, void *matchinfo)
 		spin_lock_bh(&recent_lock);
 		list_del(&t->list);
 		spin_unlock_bh(&recent_lock);
-		recent_table_flush(t);
 #ifdef CONFIG_PROC_FS
 		remove_proc_entry(t->name, proc_dir);
 #endif
+		recent_table_flush(t);
 		kfree(t);
 	}
 	mutex_unlock(&recent_mutex);
