From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] sctp: not send SCTP_PEER_ADDR_CHANGE notifications with failed probe
Date: Thu, 20 Nov 2014 14:04:40 +0800
Message-ID: <1416463480-29036-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, w@1wt.eu, zyjzyj2000@gmail.com,
	khandelwal.deepak.1987@gmail.com, vyasevich@gmail.com,
	tuexen@fh-muenster.de, dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:57997 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbaKTGFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 01:05:01 -0500
Received: by mail-pd0-f180.google.com with SMTP id p10so2399327pdj.25
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 22:05:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.x kernels require a similar logic change as commit 2c0d6ac894a
[sctp: not send SCTP_PEER_ADDR_CHANGE notifications with failed probe] 
introduces for newer kernels.

Since the transport has always been in state SCTP_UNCONFIRMED, it
therefore wasn't active before and hasn't been used before, and it
always has been, so it is unnecessary to bug the user with a
notification.

Reported-by: Deepak Khandelwal <khandelwal.deepak.1987@gmail.com>
Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
Suggested-by: Michael Tuexen <tuexen@fh-muenster.de>
Suggested-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Acked-by: Vlad Yasevich <vyasevich@gmail.com>
Acked-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

---
 net/sctp/associola.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 7eed77a..0f63396 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -824,6 +824,7 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 	struct sctp_ulpevent *event;
 	struct sockaddr_storage addr;
 	int spc_state = 0;
+	bool ulp_notify = true;
 
 	/* Record the transition on the transport.  */
 	switch (command) {
@@ -850,6 +851,7 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 		else {
 			dst_release(transport->dst);
 			transport->dst = NULL;
+			ulp_notify = false;
 		}
 
 		spc_state = SCTP_ADDR_UNREACHABLE;
@@ -862,12 +864,14 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 	/* Generate and send a SCTP_PEER_ADDR_CHANGE notification to the
 	 * user.
 	 */
-	memset(&addr, 0, sizeof(struct sockaddr_storage));
-	memcpy(&addr, &transport->ipaddr, transport->af_specific->sockaddr_len);
-	event = sctp_ulpevent_make_peer_addr_change(asoc, &addr,
+	if (ulp_notify) {
+		memset(&addr, 0, sizeof(struct sockaddr_storage));
+		memcpy(&addr, &transport->ipaddr, transport->af_specific->sockaddr_len);
+		event = sctp_ulpevent_make_peer_addr_change(asoc, &addr,
 				0, spc_state, error, GFP_ATOMIC);
-	if (event)
-		sctp_ulpq_tail_event(&asoc->ulpq, event);
+		if (event)
+			sctp_ulpq_tail_event(&asoc->ulpq, event);
+	}
 
 	/* Select new active and retran paths. */
 
-- 
1.9.1
