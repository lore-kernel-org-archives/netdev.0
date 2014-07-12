From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 6/6] net: sctp: deprecate rfc6458, 5.3.2. SCTP_SNDRCV support
Date: Sat, 12 Jul 2014 20:30:40 +0200
Message-ID: <1405189840-31171-7-git-send-email-dborkman@redhat.com>
References: <1405189840-31171-1-git-send-email-dborkman@redhat.com>
Cc: geirola@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752686AbaGLSbA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jul 2014 14:31:00 -0400
In-Reply-To: <1405189840-31171-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With support of SCTP_SNDINFO/SCTP_RCVINFO as described in RFC6458,
5.3.4/5.3.5, we can now deprecate SCTP_SNDRCV. The RFC already
declares it as deprecated:

  This structure mixes the send and receive path. SCTP_SNDINFO
  (described in Section 5.3.4) and SCTP_RCVINFO (described in
  Section 5.3.5) split this information. These structures should
  be used, when possible, since SCTP_SNDRCV is deprecated.

So whenever a user tries to subscribe to sctp_data_io_event via
setsockopt(2) which triggers inclusion of SCTP_SNDRCV cmsg_type,
issue a warning in the log.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/socket.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d95a50c..743308f 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2205,8 +2205,13 @@ static int sctp_setsockopt_events(struct sock *sk, char __user *optval,
 	if (copy_from_user(&sctp_sk(sk)->subscribe, optval, optlen))
 		return -EFAULT;
 
-	/*
-	 * At the time when a user app subscribes to SCTP_SENDER_DRY_EVENT,
+	if (sctp_sk(sk)->subscribe.sctp_data_io_event)
+		pr_warn_ratelimited(DEPRECATED "%s (pid %d) "
+				    "Requested SCTP_SNDRCVINFO event.\n"
+				    "Use SCTP_RCVINFO through SCTP_RECVRCVINFO option instead.\n",
+				    current->comm, task_pid_nr(current));
+
+	/* At the time when a user app subscribes to SCTP_SENDER_DRY_EVENT,
 	 * if there is no data to be sent or retransmit, the stack will
 	 * immediately send up this notification.
 	 */
-- 
1.7.11.7
