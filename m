From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: eliminate obsolete socket locking policy description
Date: Sat, 19 Nov 2016 14:47:07 -0500
Message-ID: <1479584827-21772-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
        Paul Gortmaker <paul.gortmaker@windriver.com>,
        parthasarathy.bhuvaragan@ericsson.com, ying.xue@windriver.com,
        maloy@donjonn.com, tipc-discussion@lists.sourceforge.net,
        Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:39059 "EHLO
        smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753220AbcKSTrO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 14:47:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The comment block in socket.c describing the locking policy is
obsolete, and does not reflect current reality. We remove it in this
commit.

Since the current locking policy is much simpler and follows a
mainstream approach, we see no need to add a new description.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 48 +-----------------------------------------------
 1 file changed, 1 insertion(+), 47 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 22d92f0..4916d8f 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/socket.c: TIPC socket API
  *
- * Copyright (c) 2001-2007, 2012-2015, Ericsson AB
+ * Copyright (c) 2001-2007, 2012-2016, Ericsson AB
  * Copyright (c) 2004-2008, 2010-2013, Wind River Systems
  * All rights reserved.
  *
@@ -127,54 +127,8 @@ static const struct proto_ops packet_ops;
 static const struct proto_ops stream_ops;
 static const struct proto_ops msg_ops;
 static struct proto tipc_proto;
-
 static const struct rhashtable_params tsk_rht_params;
 
-/*
- * Revised TIPC socket locking policy:
- *
- * Most socket operations take the standard socket lock when they start
- * and hold it until they finish (or until they need to sleep).  Acquiring
- * this lock grants the owner exclusive access to the fields of the socket
- * data structures, with the exception of the backlog queue.  A few socket
- * operations can be done without taking the socket lock because they only
- * read socket information that never changes during the life of the socket.
- *
- * Socket operations may acquire the lock for the associated TIPC port if they
- * need to perform an operation on the port.  If any routine needs to acquire
- * both the socket lock and the port lock it must take the socket lock first
- * to avoid the risk of deadlock.
- *
- * The dispatcher handling incoming messages cannot grab the socket lock in
- * the standard fashion, since invoked it runs at the BH level and cannot block.
- * Instead, it checks to see if the socket lock is currently owned by someone,
- * and either handles the message itself or adds it to the socket's backlog
- * queue; in the latter case the queued message is processed once the process
- * owning the socket lock releases it.
- *
- * NOTE: Releasing the socket lock while an operation is sleeping overcomes
- * the problem of a blocked socket operation preventing any other operations
- * from occurring.  However, applications must be careful if they have
- * multiple threads trying to send (or receive) on the same socket, as these
- * operations might interfere with each other.  For example, doing a connect
- * and a receive at the same time might allow the receive to consume the
- * ACK message meant for the connect.  While additional work could be done
- * to try and overcome this, it doesn't seem to be worthwhile at the present.
- *
- * NOTE: Releasing the socket lock while an operation is sleeping also ensures
- * that another operation that must be performed in a non-blocking manner is
- * not delayed for very long because the lock has already been taken.
- *
- * NOTE: This code assumes that certain fields of a port/socket pair are
- * constant over its lifetime; such fields can be examined without taking
- * the socket lock and/or port lock, and do not need to be re-read even
- * after resuming processing after waiting.  These fields include:
- *   - socket type
- *   - pointer to socket sk structure (aka tipc_sock structure)
- *   - pointer to port structure
- *   - port reference
- */
-
 static u32 tsk_own_node(struct tipc_sock *tsk)
 {
 	return msg_prevnode(&tsk->phdr);
-- 
2.7.4
