From: Guo-Fu Tseng <cooldavid@cooldavid.org>
Subject: [PATCH net-2.6 6/7] jme: Tuning rxsum function
Date: Wed, 1 Jul 2009 05:14:30 +0800
Message-ID: <20090702183224.1175D5D2DB@cooldavid.org>
Cc: "netdev" <netdev@vger.kernel.org>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:49278 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751538AbZGBSpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 14:45:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Use more efficient way to determine flag status.
2. Hardware dose not mark fragment bit against IPv6 packets,
   print TCP/UDP checksum warning message for IPv4 packets only.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 29cd5f4..e7068c7 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -880,27 +880,27 @@ jme_rxsum_ok(struct jme_adapter *jme, u16 flags)
 	if (!(flags & (RXWBFLAG_TCPON | RXWBFLAG_UDPON | RXWBFLAG_IPV4)))
 		return false;
 
-	if (unlikely(!(flags & RXWBFLAG_MF) &&
-	(flags & RXWBFLAG_TCPON) && !(flags & RXWBFLAG_TCPCS))) {
-		msg_rx_err(jme, "TCP Checksum error.\n");
-		goto out_sumerr;
+	if (unlikely((flags & (RXWBFLAG_MF | RXWBFLAG_TCPON | RXWBFLAG_TCPCS))
+			== RXWBFLAG_TCPON)) {
+		if (flags & RXWBFLAG_IPV4)
+			msg_rx_err(jme, "TCP Checksum error\n");
+		return false;
 	}
 
-	if (unlikely(!(flags & RXWBFLAG_MF) &&
-	(flags & RXWBFLAG_UDPON) && !(flags & RXWBFLAG_UDPCS))) {
-		msg_rx_err(jme, "UDP Checksum error.\n");
-		goto out_sumerr;
+	if (unlikely((flags & (RXWBFLAG_MF | RXWBFLAG_UDPON | RXWBFLAG_UDPCS))
+			== RXWBFLAG_UDPON)) {
+		if (flags & RXWBFLAG_IPV4)
+			msg_rx_err(jme, "UDP Checksum error.\n");
+		return false;
 	}
 
-	if (unlikely((flags & RXWBFLAG_IPV4) && !(flags & RXWBFLAG_IPCS))) {
+	if (unlikely((flags & (RXWBFLAG_IPV4 | RXWBFLAG_IPCS))
+			== RXWBFLAG_IPV4)) {
 		msg_rx_err(jme, "IPv4 Checksum error.\n");
-		goto out_sumerr;
+		return false;
 	}
 
 	return true;
-
-out_sumerr:
-	return false;
 }
 
 static void
-- 
1.6.0.6

