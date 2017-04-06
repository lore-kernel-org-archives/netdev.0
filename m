From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: listen on the sock only when it's state is listening or closed
Date: Thu,  6 Apr 2017 13:10:52 +0800
Message-ID: <19f73778f8e27b05ee9aa25ece57db6b0e73d197.1491455452.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, andreyknvl@google.com
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36572 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbdDFFLB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 01:11:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now sctp doesn't check sock's state before listening on it. It could
even cause changing a sock with any state to become a listening sock
when doing sctp_listen.

This patch is to fix it by checking sock's state in sctp_listen, so
that it will listen on the sock with right state.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/socket.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index c1401f4..d9d4c92 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -7034,6 +7034,9 @@ int sctp_inet_listen(struct socket *sock, int backlog)
 	if (sock->state != SS_UNCONNECTED)
 		goto out;
 
+	if (!sctp_sstate(sk, LISTENING) && !sctp_sstate(sk, CLOSED))
+		goto out;
+
 	/* If backlog is zero, disable listening. */
 	if (!backlog) {
 		if (sctp_sstate(sk, CLOSED))
-- 
2.1.0
