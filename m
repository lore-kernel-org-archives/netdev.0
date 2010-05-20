From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 1/8] caif: Bugfix wait_ev*_timeout returns long.
Date: Thu, 20 May 2010 09:44:01 +0200
Message-ID: <1274341448-14924-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1274341448-14924-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: marcel@holtmann.org, daniel.martensson@stericsson.com,
	linus.walleji@stericsson.com, sjurbren@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:51603 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685Ab0ETHom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 03:44:42 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2P00CCEK616ZD0@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 20 May 2010 09:44:25 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2P008F5K603V20@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 20 May 2010 09:44:25 +0200 (CEST)
In-reply-to: <1274341448-14924-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Discovered problems when testing on 64bit architecture.
Fixed by using long to store result from wait_event_interruptible_timeout.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index c3a70c5..77e9956 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -920,17 +920,17 @@ wait_connect:
 	timeo = sock_sndtimeo(sk, flags & O_NONBLOCK);
 
 	release_sock(sk);
-	err = wait_event_interruptible_timeout(*sk_sleep(sk),
+	err = -ERESTARTSYS;
+	timeo = wait_event_interruptible_timeout(*sk_sleep(sk),
 			sk->sk_state != CAIF_CONNECTING,
 			timeo);
 	lock_sock(sk);
-	if (err < 0)
+	if (timeo < 0)
 		goto out; /* -ERESTARTSYS */
-	if (err == 0 && sk->sk_state != CAIF_CONNECTED) {
-		err = -ETIMEDOUT;
-		goto out;
-	}
 
+	err = -ETIMEDOUT;
+	if (timeo == 0 && sk->sk_state != CAIF_CONNECTED)
+		goto out;
 	if (sk->sk_state != CAIF_CONNECTED) {
 		sock->state = SS_UNCONNECTED;
 		err = sock_error(sk);
@@ -945,7 +945,6 @@ out:
 	return err;
 }
 
-
 /*
  * caif_release() - Disconnect a CAIF Socket
  * Copied and modified af_irda.c:irda_release().
-- 
1.6.3.3

