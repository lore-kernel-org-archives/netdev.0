From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 1/4] net: sctp: sideeffect: throw BUG if primary_path is NULL
Date: Fri, 14 Jun 2013 18:24:04 +0200
Message-ID: <1371227047-16852-2-git-send-email-dborkman@redhat.com>
References: <1371227047-16852-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45454 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753204Ab3FNQYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jun 2013 12:24:11 -0400
In-Reply-To: <1371227047-16852-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This clearly states a BUG somewhere in the SCTP code as e.g. fixed once
in f28156335 ("sctp: Use correct sideffect command in duplicate cookie
handling"). If this ever happens, throw a trace in the sideeffect engine
where assocs clearly must have a primary_path assigned.

When in sctp_seq_dump_local_addrs() also throw a WARN and bail out since
we do not need to panic for printing this one asterisk. Also, it will
avoid the not so obvious case when primary != NULL test passes and at a
later point in time triggering a NULL ptr dereference caused by primary.
While at it, also fix up the white space.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/proc.c          | 12 +++++++++---
 net/sctp/sm_sideeffect.c |  5 ++++-
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 4e45ee3..47fff5f 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -134,9 +134,15 @@ static void sctp_seq_dump_local_addrs(struct seq_file *seq, struct sctp_ep_commo
 	struct sctp_af *af;
 
 	if (epb->type == SCTP_EP_TYPE_ASSOCIATION) {
-	    asoc = sctp_assoc(epb);
-	    peer = asoc->peer.primary_path;
-	    primary = &peer->saddr;
+		asoc = sctp_assoc(epb);
+
+		peer = asoc->peer.primary_path;
+		if (unlikely(peer == NULL)) {
+			WARN(1, "Association %p with NULL primary path!", asoc);
+			return;
+		}
+
+		primary = &peer->saddr;
 	}
 
 	rcu_read_lock();
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 8aab894..ff91f47 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -864,6 +864,7 @@ static void sctp_cmd_delete_tcb(sctp_cmd_seq_t *cmds,
 	    (!asoc->temp) && (sk->sk_shutdown != SHUTDOWN_MASK))
 		return;
 
+	BUG_ON(asoc->peer.primary_path == NULL);
 	sctp_unhash_established(asoc);
 	sctp_association_free(asoc);
 }
@@ -1274,8 +1275,10 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 				sctp_outq_uncork(&asoc->outqueue);
 				local_cork = 0;
 			}
-			asoc = cmd->obj.asoc;
+
 			/* Register with the endpoint.  */
+			asoc = cmd->obj.asoc;
+			BUG_ON(asoc->peer.primary_path == NULL);
 			sctp_endpoint_add_asoc(ep, asoc);
 			sctp_hash_established(asoc);
 			break;
-- 
1.7.11.7
