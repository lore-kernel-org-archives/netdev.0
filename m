From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 04/14] SCTP: Update RCU handling during the ADD-IP case
Date: Mon, 12 Nov 2007 11:38:19 -0500
Message-ID: <11948855131462-git-send-email-vladislav.yasevich@hp.com>
References: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:56239 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753970AbXKLQie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 11:38:34 -0500
In-Reply-To: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After learning more about rcu, it looks like the ADD-IP hadling
doesn't need to call call_rcu_bh.  All the rcu critical sections
use rcu_read_lock, so using call_rcu_bh is wrong here.
Now, restore the local_bh_disable() code blocks and use normal
call_rcu() calls.  Also restore the missing return statement.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    4 +---
 net/sctp/bind_addr.c       |   13 +++----------
 net/sctp/sm_make_chunk.c   |    6 +++++-
 net/sctp/socket.c          |    2 +-
 4 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 482c2aa..a177017 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1185,9 +1185,7 @@ int sctp_bind_addr_copy(struct sctp_bind_addr *dest,
 			int flags);
 int sctp_add_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
 		       __u8 use_as_src, gfp_t gfp);
-int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
-			void fastcall (*rcu_call)(struct rcu_head *,
-					  void (*func)(struct rcu_head *)));
+int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *);
 int sctp_bind_addr_match(struct sctp_bind_addr *, const union sctp_addr *,
 			 struct sctp_sock *);
 union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index dfffa94..cae95af 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -180,9 +180,7 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
 /* Delete an address from the bind address list in the SCTP_bind_addr
  * structure.
  */
-int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr,
-			void fastcall (*rcu_call)(struct rcu_head *head,
-					 void (*func)(struct rcu_head *head)))
+int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr)
 {
 	struct sctp_sockaddr_entry *addr, *temp;
 
@@ -198,15 +196,10 @@ int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr,
 		}
 	}
 
-	/* Call the rcu callback provided in the args.  This function is
-	 * called by both BH packet processing and user side socket option
-	 * processing, but it works on different lists in those 2 contexts.
-	 * Each context provides it's own callback, whether call_rcu_bh()
-	 * or call_rcu(), to make sure that we wait for an appropriate time.
-	 */
 	if (addr && !addr->valid) {
-		rcu_call(&addr->rcu, sctp_local_addr_free);
+		call_rcu(&addr->rcu, sctp_local_addr_free);
 		SCTP_DBG_OBJCNT_DEC(addr);
+		return 0;
 	}
 
 	return -EINVAL;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 5de4729..c60564d 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2953,13 +2953,17 @@ static int sctp_asconf_param_success(struct sctp_association *asoc,
 		/* This is always done in BH context with a socket lock
 		 * held, so the list can not change.
 		 */
+		local_bh_disable();
 		list_for_each_entry(saddr, &bp->address_list, list) {
 			if (sctp_cmp_addr_exact(&saddr->a, &addr))
 				saddr->use_as_src = 1;
 		}
+		local_bh_enable();
 		break;
 	case SCTP_PARAM_DEL_IP:
-		retval = sctp_del_bind_addr(bp, &addr, call_rcu_bh);
+		local_bh_disable();
+		retval = sctp_del_bind_addr(bp, &addr);
+		local_bh_enable();
 		list_for_each(pos, &asoc->peer.transport_addr_list) {
 			transport = list_entry(pos, struct sctp_transport,
 						 transports);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index a7ecf31..6ce9b49 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -660,7 +660,7 @@ static int sctp_bindx_rem(struct sock *sk, struct sockaddr *addrs, int addrcnt)
 		 * socket routing and failover schemes. Refer to comments in
 		 * sctp_do_bind(). -daisy
 		 */
-		retval = sctp_del_bind_addr(bp, sa_addr, call_rcu);
+		retval = sctp_del_bind_addr(bp, sa_addr);
 
 		addr_buf += af->sockaddr_len;
 err_bindx_rem:
-- 
1.5.2.4

