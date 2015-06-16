From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [RFC PATCH 2/2] dlm: avoid using sctp_do_peeloff directly
Date: Tue, 16 Jun 2015 19:42:33 -0300
Message-ID: <4a1e9e2f82a49135a5bd16cfe92a242572979cd6.1434492495.git.marcelo.leitner@gmail.com>
References: <cover.1434492495.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754418AbbFPWmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 18:42:43 -0400
In-Reply-To: <cover.1434492495.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reverts 2f2d76cc3e93 ("dlm: Do not allocate a fd for
peeloff") but also makes use of a new sockopt:
SCTP_SOCKOPT_PEELOFF_KERNEL, which avoids allocating file descriptors
while doing this operation.

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
index 754fd6c0b7470bab272b071e6ca6e4969e4e4209..aa50131e51ceaf2d56cc2252fe6c0c17b80af769 100644
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
+			sctp_peeloff_kernel_arg_t parg;
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
+						SCTP_SOCKOPT_PEELOFF_KERNEL,
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
+			add_sock(parg.socket, new_con);
 
 			linger.l_onoff = 1;
 			linger.l_linger = 0;
-- 
2.4.1
