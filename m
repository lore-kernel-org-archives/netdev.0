From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v3 10/10] llc: fix SAP reference counting w.r.t. socket handling
Date: Sat, 26 Dec 2009 23:51:08 +0200
Message-ID: <1261864268-10460-11-git-send-email-opurdila@ixiacom.com>
References: <1261864268-10460-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:19502 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754046AbZLZVyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 16:54:50 -0500
In-Reply-To: <1261864268-10460-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SAP ref counter gets decremented twice when deleting a socket,
although for all but the first socket of a SAP the SAP ref counter was
incremented only once.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/llc/af_llc.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index f49f3dd..e35d907 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -197,10 +197,8 @@ static int llc_ui_release(struct socket *sock)
 		llc->laddr.lsap, llc->daddr.lsap);
 	if (!llc_send_disc(sk))
 		llc_ui_wait_for_disc(sk, sk->sk_rcvtimeo);
-	if (!sock_flag(sk, SOCK_ZAPPED)) {
-		llc_sap_put(llc->sap);
+	if (!sock_flag(sk, SOCK_ZAPPED))
 		llc_sap_remove_socket(llc->sap, sk);
-	}
 	release_sock(sk);
 	if (llc->dev)
 		dev_put(llc->dev);
@@ -352,7 +350,6 @@ static int llc_ui_bind(struct socket *sock, struct sockaddr *uaddr, int addrlen)
 		rc = -EBUSY; /* some other network layer is using the sap */
 		if (!sap)
 			goto out;
-		llc_sap_hold(sap);
 	} else {
 		struct llc_addr laddr, daddr;
 		struct sock *ask;
-- 
1.5.6.5

