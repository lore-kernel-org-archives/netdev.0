From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: allow receiving msg when TCP-style sk is in CLOSED state
Date: Sat, 30 Jul 2016 14:14:41 +0800
Message-ID: <d108342f2f89cfdf7f9abc529a746a032e236b78.1469859281.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33524 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbcG3GOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 02:14:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 141ddefce7c8 ("sctp: change sk state to CLOSED instead of
CLOSING in sctp_sock_migrate") changed sk state to CLOSED if the
assoc is closed when sctp_accept clones a new sk.

If there is still data in sk receive queue, users will not be able
to read it any more, as sctp_recvmsg returns directly if sk state
is CLOSED.

This patch is to add CLOSED state check in sctp_recvmsg to allow
reading data from TCP-style sk with CLOSED state as what TCP does.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 8812e1b..9fc417a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2079,7 +2079,7 @@ static int sctp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	lock_sock(sk);
 
 	if (sctp_style(sk, TCP) && !sctp_sstate(sk, ESTABLISHED) &&
-	    !sctp_sstate(sk, CLOSING)) {
+	    !sctp_sstate(sk, CLOSING) && !sctp_sstate(sk, CLOSED)) {
 		err = -ENOTCONN;
 		goto out;
 	}
-- 
2.1.0
