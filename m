From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH v2 2/2] dlm: Do not allocate a fd for peeloff
Date: Thu,  8 Mar 2012 10:55:59 -0500
Message-ID: <1331222159-28980-2-git-send-email-bpoirier@suse.de>
References: <20120308.002447.1062706659978103072.davem@davemloft.net>
 <1331222159-28980-1-git-send-email-bpoirier@suse.de>
Cc: Christine Caulfield <ccaulfie@redhat.com>,
	David Teigland <teigland@redhat.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>, cluster-devel@redhat.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331222159-28980-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

avoids allocating a fd that a) propagates to every kernel thread and
usermodehelper b) is not properly released.

References: http://article.gmane.org/gmane.linux.network.drbd/22529
Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
---
 fs/dlm/lowcomms.c |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 0b3109e..ca0c59a 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -52,6 +52,7 @@
 #include <linux/mutex.h>
 #include <linux/sctp.h>
 #include <linux/slab.h>
+#include <net/sctp/sctp.h>
 #include <net/sctp/user.h>
 #include <net/ipv6.h>
 
@@ -474,9 +475,6 @@ static void process_sctp_notification(struct connection *con,
 			int prim_len, ret;
 			int addr_len;
 			struct connection *new_con;
-			sctp_peeloff_arg_t parg;
-			int parglen = sizeof(parg);
-			int err;
 
 			/*
 			 * We get this before any data for an association.
@@ -525,23 +523,19 @@ static void process_sctp_notification(struct connection *con,
 				return;
 
 			/* Peel off a new sock */
-			parg.associd = sn->sn_assoc_change.sac_assoc_id;
-			ret = kernel_getsockopt(con->sock, IPPROTO_SCTP,
-						SCTP_SOCKOPT_PEELOFF,
-						(void *)&parg, &parglen);
+			sctp_lock_sock(con->sock->sk);
+			ret = sctp_do_peeloff(con->sock->sk,
+				sn->sn_assoc_change.sac_assoc_id,
+				&new_con->sock);
+			sctp_release_sock(con->sock->sk);
 			if (ret < 0) {
 				log_print("Can't peel off a socket for "
 					  "connection %d to node %d: err=%d",
-					  parg.associd, nodeid, ret);
-				return;
-			}
-			new_con->sock = sockfd_lookup(parg.sd, &err);
-			if (!new_con->sock) {
-				log_print("sockfd_lookup error %d", err);
+					  (int)sn->sn_assoc_change.sac_assoc_id,
+					  nodeid, ret);
 				return;
 			}
 			add_sock(new_con->sock, new_con);
-			sockfd_put(new_con->sock);
 
 			log_print("connecting to %d sctp association %d",
 				 nodeid, (int)sn->sn_assoc_change.sac_assoc_id);
-- 
1.7.7
