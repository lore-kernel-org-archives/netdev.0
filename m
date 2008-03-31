From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 6/13 net-2.6.26] [SCTP]: Replace socket with sock for SCTP control socket.
Date: Mon, 31 Mar 2008 17:16:46 +0400
Message-ID: <1206969413-12096-6-git-send-email-den@openvz.org>
References: <1206969367.10660.16.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:21346 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756854AbYCaNRc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 09:17:32 -0400
In-Reply-To: <1206969367.10660.16.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/sctp/protocol.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 6a3be58..ac0833c 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -74,7 +74,7 @@ DEFINE_SPINLOCK(sctp_assocs_id_lock);
  * the Out-of-the-blue (OOTB) packets.  A control sock will be created
  * for this socket at the initialization time.
  */
-static struct socket *sctp_ctl_socket;
+static struct sock *sctp_ctl_sock;
 
 static struct sctp_pf *sctp_pf_inet6_specific;
 static struct sctp_pf *sctp_pf_inet_specific;
@@ -91,7 +91,7 @@ int sysctl_sctp_wmem[3];
 /* Return the address of the control sock. */
 struct sock *sctp_get_ctl_sock(void)
 {
-	return sctp_ctl_socket->sk;
+	return sctp_ctl_sock;
 }
 
 /* Set up the proc fs entry for the SCTP protocol. */
@@ -674,19 +674,21 @@ static int sctp_ctl_sock_init(void)
 {
 	int err;
 	sa_family_t family;
+	struct socket *socket;
 
 	if (sctp_get_pf_specific(PF_INET6))
 		family = PF_INET6;
 	else
 		family = PF_INET;
 
-	err = inet_ctl_sock_create(&sctp_ctl_socket, family,
+	err = inet_ctl_sock_create(&socket, family,
 				   SOCK_SEQPACKET, IPPROTO_SCTP);
 	if (err < 0) {
 		printk(KERN_ERR
 		       "SCTP: Failed to create the SCTP control socket.\n");
 		return err;
 	}
+	sctp_ctl_sock = socket->sk;
 	return 0;
 }
 
@@ -1284,7 +1286,7 @@ err_v6_add_protocol:
 	sctp_v6_del_protocol();
 err_add_protocol:
 	sctp_v4_del_protocol();
-	sock_release(sctp_ctl_socket);
+	sock_release(sctp_ctl_sock->sk_socket);
 err_ctl_sock_init:
 	sctp_v6_protosw_exit();
 err_v6_protosw_init:
@@ -1328,7 +1330,7 @@ SCTP_STATIC __exit void sctp_exit(void)
 	sctp_v4_del_protocol();
 
 	/* Free the control endpoint.  */
-	sock_release(sctp_ctl_socket);
+	sock_release(sctp_ctl_sock->sk_socket);
 
 	/* Free protosw registrations */
 	sctp_v6_protosw_exit();
-- 
1.5.3.rc5

