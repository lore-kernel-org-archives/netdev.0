From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: [PATCH] net/tipc: initialize security state for new connection socket
Date: Tue,  7 Jul 2015 09:43:45 -0400
Message-ID: <1436276625-3325-1-git-send-email-sds@tycho.nsa.gov>
Cc: paul@paul-moore.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>
To: jon.maloy@ericsson.com, ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emvm-gh1-uea08.nsa.gov ([63.239.67.9]:62331 "EHLO
	emvm-gh1-uea08.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757369AbbGGNpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 09:45:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling connect() with an AF_TIPC socket would trigger a series
of error messages from SELinux along the lines of:
SELinux: Invalid class 0
type=AVC msg=audit(1434126658.487:34500): avc:  denied  { <unprintable> }
  for pid=292 comm="kworker/u16:5" scontext=system_u:system_r:kernel_t:s0
  tcontext=system_u:object_r:unlabeled_t:s0 tclass=<unprintable>
  permissive=0

This was due to a failure to initialize the security state of the new
connection sock by the tipc code, leaving it with junk in the security
class field and an unlabeled secid.  Add a call to security_sk_clone()
to inherit the security state from the parent socket.

Reported-by: Tim Shearer <tim.shearer@overturenetworks.com>
Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
Acked-by: Paul Moore <paul@paul-moore.com>
---
 net/tipc/socket.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 46b6ed5..3a7567f 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2007,6 +2007,7 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 	res = tipc_sk_create(sock_net(sock->sk), new_sock, 0, 1);
 	if (res)
 		goto exit;
+	security_sk_clone(sock->sk, new_sock->sk);
 
 	new_sk = new_sock->sk;
 	new_tsock = tipc_sk(new_sk);
-- 
2.1.0
