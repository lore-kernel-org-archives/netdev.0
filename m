From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/4] net: sctp: sctp_seq_dump_local_addrs: throw BUG if primary_path is NULL
Date: Thu, 13 Jun 2013 18:04:20 +0200
Message-ID: <1371139463-12512-2-git-send-email-dborkman@redhat.com>
References: <1371139463-12512-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15196 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752081Ab3FMQE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 12:04:27 -0400
In-Reply-To: <1371139463-12512-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This clearly states a BUG somewhere in the SCTP code as e.g. fixed once
in f28156335 ("sctp: Use correct sideffect command in duplicate cookie
handling"). If this ever comes up again, throw a BUG and add a comment
why this is the case since it is not too obvious when primary != NULL
test passes and at a later point in time triggering a NULL ptr dereference
caused by primary. While at it, also fix up the white space.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/proc.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 4e45ee3..f171366 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -134,9 +134,18 @@ static void sctp_seq_dump_local_addrs(struct seq_file *seq, struct sctp_ep_commo
 	struct sctp_af *af;
 
 	if (epb->type == SCTP_EP_TYPE_ASSOCIATION) {
-	    asoc = sctp_assoc(epb);
-	    peer = asoc->peer.primary_path;
-	    primary = &peer->saddr;
+		asoc = sctp_assoc(epb);
+		peer = asoc->peer.primary_path;
+
+		/* There must be no such case where an association is linked
+		 * into sctp_assoc_hashtable that does not have a primary
+		 * path! This means either sctp_association_free() was called
+		 * without sctp_unhash_established(), or somewhere in the
+		 * interpreter SCTP_CMD_ASOC_NEW was called on a non-fully
+		 * set up association. So do hara-kiri until this is fixed.
+		 */
+		BUG_ON(peer == NULL);
+		primary = &peer->saddr;
 	}
 
 	rcu_read_lock();
-- 
1.7.11.7
