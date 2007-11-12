From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 06/14] SCTP: Allow ADD_IP to work with AUTH for backward compatibility.
Date: Mon, 12 Nov 2007 11:38:21 -0500
Message-ID: <1194885514247-git-send-email-vladislav.yasevich@hp.com>
References: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:59039 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753942AbXKLQig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 11:38:36 -0500
In-Reply-To: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a tunable that will allow ADD_IP to work without
AUTH for backward compatibility.  The default value is off since
the default value for ADD_IP is off as well.  People who need
to use ADD-IP with older implementations take risks of connection
hijacking and should consider upgrading or turning this tunable on.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    2 ++
 net/sctp/associola.c       |    8 ++++++--
 net/sctp/protocol.c        |    1 +
 net/sctp/sm_make_chunk.c   |    4 +++-
 net/sctp/sysctl.c          |    9 +++++++++
 5 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 41f1039..44f2672 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -212,6 +212,7 @@ extern struct sctp_globals {
 	
 	/* Flag to indicate if addip is enabled. */
 	int addip_enable;
+	int addip_noauth_enable;
 
 	/* Flag to indicate if PR-SCTP is enabled. */
 	int prsctp_enable;
@@ -249,6 +250,7 @@ extern struct sctp_globals {
 #define sctp_local_addr_list		(sctp_globals.local_addr_list)
 #define sctp_local_addr_lock		(sctp_globals.addr_list_lock)
 #define sctp_addip_enable		(sctp_globals.addip_enable)
+#define sctp_addip_noauth		(sctp_globals.addip_noauth_enable)
 #define sctp_prsctp_enable		(sctp_globals.prsctp_enable)
 #define sctp_auth_enable		(sctp_globals.auth_enable)
 
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index eaad5c5..013e3d3 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -262,10 +262,14 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	 */
 	asoc->peer.sack_needed = 1;
 
-	/* Assume that the peer recongizes ASCONF until reported otherwise
-	 * via an ERROR chunk.
+	/* Assume that the peer will tell us if he recognizes ASCONF
+	 * as part of INIT exchange.
+	 * The sctp_addip_noauth option is there for backward compatibilty
+	 * and will revert old behavior.
 	 */
 	asoc->peer.asconf_capable = 0;
+	if (sctp_addip_noauth)
+		asoc->peer.asconf_capable = 1;
 
 	/* Create an input queue.  */
 	sctp_inq_init(&asoc->base.inqueue);
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 40c1a47..ecfab03 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1179,6 +1179,7 @@ SCTP_STATIC __init int sctp_init(void)
 
 	/* Disable ADDIP by default. */
 	sctp_addip_enable = 0;
+	sctp_addip_noauth = 0;
 
 	/* Enable PR-SCTP by default. */
 	sctp_prsctp_enable = 1;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 2ff3a3d..43e8de1 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2137,8 +2137,10 @@ int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
 
 	/* If the peer claims support for ADD-IP without support
 	 * for AUTH, disable support for ADD-IP.
+	 * Do this only if backward compatible mode is turned off.
 	 */
-	if (asoc->peer.asconf_capable && !asoc->peer.auth_capable) {
+	if (!sctp_addip_noauth &&
+	     (asoc->peer.asconf_capable && !asoc->peer.auth_capable)) {
 		asoc->peer.addip_disabled_mask |= (SCTP_PARAM_ADD_IP |
 						  SCTP_PARAM_DEL_IP |
 						  SCTP_PARAM_SET_PRIMARY);
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 0669778..da4f157 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -263,6 +263,15 @@ static ctl_table sctp_table[] = {
 		.proc_handler	= &proc_dointvec,
 		.strategy	= &sysctl_intvec
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "addip_noauth_enable",
+		.data		= &sctp_addip_noauth,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec
+	},
 	{ .ctl_name = 0 }
 };
 
-- 
1.5.2.4

