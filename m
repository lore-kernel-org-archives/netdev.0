From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 2/2] dlm: avoid using sctp_do_peeloff directly
Date: Thu,  9 Jul 2015 11:15:20 -0300
Message-ID: <a5b66c7f050a17cd2b8f0f4d6bbb3a5837d593f5.1434645734.git.marcelo.leitner@gmail.com>
References: <4dfd0ee7ac0aac0791812217e990e2ae7ff86955.1434645734.git.marcelo.leitner@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44399 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751298AbbGIOPb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 10:15:31 -0400
In-Reply-To: <4dfd0ee7ac0aac0791812217e990e2ae7ff86955.1434645734.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reverts 2f2d76cc3e93 ("dlm: Do not allocate a fd for
peeloff") but also takes benefit on an updated sockopt
SCTP_SOCKOPT_PEELOFF, which now avoids allocating file descriptors for
kernel users.

By this we avoid creating a direct dependency from dlm to sctp module,
which can then be left unloaded if dlm is not really using it.

Note that this was preferred other than a module split as it once was
split and was merged back in 2007 by commit 6ed7257b4670 ("[DLM]
Consolidate transport protocols") so that we don't revert it.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 fs/dlm/lowcomms.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 754fd6c0b7470bab272b071e6ca6e4969e4e4209..fb094b5ab0347a7b8659c2dc6cc3b32638d63638 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -52,7 +52,6 @@
 #include <linux/mutex.h>
 #include <linux/sctp.h>
 #include <linux/slab.h>
-#include <net/sctp/sctp.h>
 #include <net/ipv6.h>
 
 #include "dlm_internal.h"
@@ -671,6 +670,8 @@ static void process_sctp_notification(struct connection *con,
 			int prim_len, ret;
 			int addr_len;
 			struct connection *new_con;
+			sctp_peeloff_arg_t parg;
+			int parglen = sizeof(parg);
 
 			/*
 			 * We get this before any data for an association.
@@ -719,19 +720,17 @@ static void process_sctp_notification(struct connection *con,
 				return;
 
 			/* Peel off a new sock */
-			lock_sock(con->sock->sk);
-			ret = sctp_do_peeloff(con->sock->sk,
-				sn->sn_assoc_change.sac_assoc_id,
-				&new_con->sock);
-			release_sock(con->sock->sk);
+			parg.associd = sn->sn_assoc_change.sac_assoc_id;
+			ret = kernel_getsockopt(con->sock, IPPROTO_SCTP,
+						SCTP_SOCKOPT_PEELOFF,
+						(void *)&parg, &parglen);
 			if (ret < 0) {
 				log_print("Can't peel off a socket for "
 					  "connection %d to node %d: err=%d",
-					  (int)sn->sn_assoc_change.sac_assoc_id,
-					  nodeid, ret);
+					  parg.associd, nodeid, ret);
 				return;
 			}
-			add_sock(new_con->sock, new_con);
+			add_sock(parg.sock, new_con);
 
 			linger.l_onoff = 1;
 			linger.l_linger = 0;
-- 
2.4.1
