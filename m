From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 3/5] [SCTP]: Fix compiler warning about const qualifiers
Date: Thu, 10 Apr 2008 14:18:32 -0400
Message-ID: <1207851513-17021-4-git-send-email-vladislav.yasevich@hp.com>
References: <1207851513-17021-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:39554 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756884AbYDJSSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 14:18:43 -0400
In-Reply-To: <1207851513-17021-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix 3 warnings about discarding const qualifiers:

net/sctp/ulpevent.c:862: warning: passing argument 1 of 'sctp_event2skb' discards qualifiers from pointer target type
net/sctp/sm_statefuns.c:4393: warning: passing argument 1 of 'SCTP_ASOC' discards qualifiers from pointer target type
net/sctp/socket.c:5874: warning: passing argument 1 of 'cmsg_nxthdr' discards qualifiers from pointer target type

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/ulpevent.h |    2 +-
 net/sctp/sm_statefuns.c     |    5 +++--
 net/sctp/socket.c           |    5 +++--
 net/sctp/ulpevent.c         |    2 +-
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 9bcfc12..7ea12e8 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -67,7 +67,7 @@ struct sctp_ulpevent {
 };
 
 /* Retrieve the skb this event sits inside of. */
-static inline struct sk_buff *sctp_event2skb(struct sctp_ulpevent *ev)
+static inline struct sk_buff *sctp_event2skb(const struct sctp_ulpevent *ev)
 {
 	return container_of((void *)ev, struct sk_buff, cb);
 }
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 3ef9749..07194c2 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4367,6 +4367,7 @@ sctp_disposition_t sctp_sf_do_prm_asoc(const struct sctp_endpoint *ep,
 				       sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *repl;
+	struct sctp_association* my_asoc;
 
 	/* The comment below says that we enter COOKIE-WAIT AFTER
 	 * sending the INIT, but that doesn't actually work in our
@@ -4390,8 +4391,8 @@ sctp_disposition_t sctp_sf_do_prm_asoc(const struct sctp_endpoint *ep,
 	/* Cast away the const modifier, as we want to just
 	 * rerun it through as a sideffect.
 	 */
-	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_ASOC,
-			SCTP_ASOC((struct sctp_association *) asoc));
+	my_asoc = (struct sctp_association *)asoc;
+	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_ASOC, SCTP_ASOC(my_asoc));
 
 	/* Choose transport for INIT. */
 	sctp_add_cmd_sf(commands, SCTP_CMD_INIT_CHOOSE_TRANSPORT,
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d994d82..998e63a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5868,11 +5868,12 @@ SCTP_STATIC int sctp_msghdr_parse(const struct msghdr *msg,
 				  sctp_cmsgs_t *cmsgs)
 {
 	struct cmsghdr *cmsg;
+	struct msghdr *my_msg = (struct msghdr *)msg;
 
 	for (cmsg = CMSG_FIRSTHDR(msg);
 	     cmsg != NULL;
-	     cmsg = CMSG_NXTHDR((struct msghdr*)msg, cmsg)) {
-		if (!CMSG_OK(msg, cmsg))
+	     cmsg = CMSG_NXTHDR(my_msg, cmsg)) {
+		if (!CMSG_OK(my_msg, cmsg))
 			return -EINVAL;
 
 		/* Should we parse this header or ignore?  */
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index b43f1f1..ce6cda6 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -859,7 +859,7 @@ __u16 sctp_ulpevent_get_notification_type(const struct sctp_ulpevent *event)
 	union sctp_notification *notification;
 	struct sk_buff *skb;
 
-	skb = sctp_event2skb((struct sctp_ulpevent *)event);
+	skb = sctp_event2skb(event);
 	notification = (union sctp_notification *) skb->data;
 	return notification->sn_header.sn_type;
 }
-- 
1.5.3.5

