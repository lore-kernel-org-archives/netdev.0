From: Bob Peterson <rpeterso@redhat.com>
Subject: [PATCH] tipc: Fix tipc_sk_reinit handling of -EAGAIN
Date: Wed, 23 Aug 2017 10:43:02 -0400 (EDT)
Message-ID: <25145358.1155254.1503499382947.JavaMail.zimbra@redhat.com>
References: <1907606232.1152250.1503498773672.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: herbert@gondor.apana.org.au, Phil Sutter <psutter@redhat.com>,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1907606232.1152250.1503498773672.JavaMail.zimbra@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

In 9dbbfb0ab6680c6a85609041011484e6658e7d3c function tipc_sk_reinit
had additional logic added to loop in the event that function
rhashtable_walk_next() returned -EAGAIN. No worries.

However, if rhashtable_walk_start returns -EAGAIN, it does "continue",
and therefore skips the call to rhashtable_walk_stop(). That has
the effect of calling rcu_read_lock() without its paired call to
rcu_read_unlock(). Since rcu_read_lock() may be nested, the problem
may not be apparent for a while, especially since resize events may
be rare. But the comments to rhashtable_walk_start() state:

 * ...Note that we take the RCU lock in all
 * cases including when we return an error.  So you must always call
 * rhashtable_walk_stop to clean up.

This patch replaces the continue with a goto and label to ensure a
matching call to rhashtable_walk_stop().

Signed-off-by: Bob Peterson <rpeterso@redhat.com>
---
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 101e3597338f..d50edd6e0019 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2255,8 +2255,8 @@ void tipc_sk_reinit(struct net *net)
 
 	do {
 		tsk = ERR_PTR(rhashtable_walk_start(&iter));
-		if (tsk)
-			continue;
+		if (IS_ERR(tsk))
+			goto walk_stop;
 
 		while ((tsk = rhashtable_walk_next(&iter)) && !IS_ERR(tsk)) {
 			spin_lock_bh(&tsk->sk.sk_lock.slock);
@@ -2265,7 +2265,7 @@ void tipc_sk_reinit(struct net *net)
 			msg_set_orignode(msg, tn->own_addr);
 			spin_unlock_bh(&tsk->sk.sk_lock.slock);
 		}
-
+walk_stop:
 		rhashtable_walk_stop(&iter);
 	} while (tsk == ERR_PTR(-EAGAIN));
 }
