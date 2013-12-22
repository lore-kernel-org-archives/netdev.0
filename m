From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] net: rose: restore old recvmsg behavior
Date: Mon, 23 Dec 2013 00:32:31 +0100
Message-ID: <1387755151-9653-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43882 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756189Ab3LVXfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:35:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

recvmsg handler in net/rose/af_rose.c performs size-check ->msg_namelen.

After commit f3d3342602f8bcbf37d7c46641cb9bca7618eb1c
(net: rework recvmsg handler msg_name and msg_namelen logic), we now
always take the else branch due to namelen being initialized to 0.

Digging in netdev-vger-cvs git repo shows that msg_namelen was
initialized with a fixed-size since at least 1995, so the else branch
was never taken.

Compile tested only.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/rose/af_rose.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 33af772..62ced65 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1253,6 +1253,7 @@ static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	if (msg->msg_name) {
 		struct sockaddr_rose *srose;
+		struct full_sockaddr_rose *full_srose = msg->msg_name;
 
 		memset(msg->msg_name, 0, sizeof(struct full_sockaddr_rose));
 		srose = msg->msg_name;
@@ -1260,18 +1261,9 @@ static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
 		srose->srose_addr   = rose->dest_addr;
 		srose->srose_call   = rose->dest_call;
 		srose->srose_ndigis = rose->dest_ndigis;
-		if (msg->msg_namelen >= sizeof(struct full_sockaddr_rose)) {
-			struct full_sockaddr_rose *full_srose = (struct full_sockaddr_rose *)msg->msg_name;
-			for (n = 0 ; n < rose->dest_ndigis ; n++)
-				full_srose->srose_digis[n] = rose->dest_digis[n];
-			msg->msg_namelen = sizeof(struct full_sockaddr_rose);
-		} else {
-			if (rose->dest_ndigis >= 1) {
-				srose->srose_ndigis = 1;
-				srose->srose_digi = rose->dest_digis[0];
-			}
-			msg->msg_namelen = sizeof(struct sockaddr_rose);
-		}
+		for (n = 0 ; n < rose->dest_ndigis ; n++)
+			full_srose->srose_digis[n] = rose->dest_digis[n];
+		msg->msg_namelen = sizeof(struct full_sockaddr_rose);
 	}
 
 	skb_free_datagram(sk, skb);
-- 
1.8.1.5
