From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2 2/2] dlm: avoid using sctp_do_peeloff directly
Date: Tue, 14 Jul 2015 14:13:25 -0300
Message-ID: <3c7c8a7a413146c661ef3df5346becf03f626e32.1436891629.git.marcelo.leitner@gmail.com>
References: <cover.1436891629.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753118AbbGNROA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 13:14:00 -0400
In-Reply-To: <cover.1436891629.git.marcelo.leitner@gmail.com>
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
index d08e079ea5d3aa37cf685cce89eb00122fe7ba02..dd14fe05a69565d9ec061fc2c93671c49d12fdcb 100644
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
