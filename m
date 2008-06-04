From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/6] SCTP: retran_path update bug fix
Date: Wed,  4 Jun 2008 14:25:46 -0400
Message-ID: <1212603951-24932-2-git-send-email-vladislav.yasevich@hp.com>
References: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, davem@davemloft.net,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:45213 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbYFDSZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 14:25:56 -0400
In-Reply-To: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

If the current retran_path is the only active one, it should
update it to the the next inactive one.

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/associola.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index b4cd2b7..5326348 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1203,6 +1203,9 @@ void sctp_assoc_update_retran_path(struct sctp_association *asoc)
 	struct list_head *head = &asoc->peer.transport_addr_list;
 	struct list_head *pos;
 
+	if (asoc->peer.transport_count == 1)
+		return;
+
 	/* Find the next transport in a round-robin fashion. */
 	t = asoc->peer.retran_path;
 	pos = &t->transports;
@@ -1217,6 +1220,15 @@ void sctp_assoc_update_retran_path(struct sctp_association *asoc)
 
 		t = list_entry(pos, struct sctp_transport, transports);
 
+		/* We have exhausted the list, but didn't find any
+		 * other active transports.  If so, use the next
+		 * transport.
+		 */
+		if (t == asoc->peer.retran_path) {
+			t = next;
+			break;
+		}
+
 		/* Try to find an active transport. */
 
 		if ((t->state == SCTP_ACTIVE) ||
@@ -1229,15 +1241,6 @@ void sctp_assoc_update_retran_path(struct sctp_association *asoc)
 			if (!next)
 				next = t;
 		}
-
-		/* We have exhausted the list, but didn't find any
-		 * other active transports.  If so, use the next
-		 * transport.
-		 */
-		if (t == asoc->peer.retran_path) {
-			t = next;
-			break;
-		}
 	}
 
 	asoc->peer.retran_path = t;
-- 
1.5.3.5

