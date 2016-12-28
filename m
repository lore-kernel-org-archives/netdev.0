From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next] sctp: add pr_debug for tracking asocs not found
Date: Wed, 28 Dec 2016 09:51:56 -0200
Message-ID: <2e7482596bbf75efb56e313e33179f9e1c0e6996.1482924698.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Xin Long <lucien.xin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33239 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751384AbcL1MAm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:00:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pr_debug may help identify why the system is generating some
Aborts. It's not something a sysadmin would be expected to use.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/input.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 458e506ef84bae3c53c239d6cf89a9349faafb11..704ad19c1565fe5d8a8aad8e73be124f4c21e0f1 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -1229,13 +1229,26 @@ static struct sctp_association *__sctp_rcv_lookup(struct net *net,
 	struct sctp_association *asoc;
 
 	asoc = __sctp_lookup_association(net, laddr, paddr, transportp);
+	if (asoc)
+		goto out;
 
 	/* Further lookup for INIT/INIT-ACK packets.
 	 * SCTP Implementors Guide, 2.18 Handling of address
 	 * parameters within the INIT or INIT-ACK.
 	 */
-	if (!asoc)
-		asoc = __sctp_rcv_lookup_harder(net, skb, laddr, transportp);
+	asoc = __sctp_rcv_lookup_harder(net, skb, laddr, transportp);
+	if (asoc)
+		goto out;
 
+	if (paddr->sa.sa_family == AF_INET)
+		pr_debug("sctp: asoc not found for src:%pI4:%d dst:%pI4:%d\n",
+			 &laddr->v4.sin_addr, ntohs(laddr->v4.sin_port),
+			 &paddr->v4.sin_addr, ntohs(paddr->v4.sin_port));
+	else
+		pr_debug("sctp: asoc not found for src:%pI6:%d dst:%pI6:%d\n",
+			 &laddr->v6.sin6_addr, ntohs(laddr->v6.sin6_port),
+			 &paddr->v6.sin6_addr, ntohs(paddr->v6.sin6_port));
+
+out:
 	return asoc;
 }
-- 
2.9.3
