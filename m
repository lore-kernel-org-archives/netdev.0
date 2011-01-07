From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjurbren@stericsson.com>
Subject: [PATCH] CAIF: Fix IPv6 support in receive path for GPRS/3G
Date: Fri, 07 Jan 2011 12:57:08 +0100
Message-ID: <1294401428-2085-1-git-send-email-sjurbren@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: Kumar Sanghvi <kumar.sanghvi@stericsson.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:54951 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911Ab1AGM5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 07:57:42 -0500
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LEN00EN5IJN6E60@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Fri, 07 Jan 2011 12:57:23 +0100 (CET)
Received: from localhost.localdomain ([80.203.137.56])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LEN0009PIJMSA50@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Fri, 07 Jan 2011 12:57:23 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumar.sanghvi@stericsson.com>

Checks version field of IP in the receive path for GPRS/3G data
and appropriately sets the value of skb->protocol.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/chnl_net.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 84a422c..fa9dab3 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -76,6 +76,8 @@ static int chnl_recv_cb(struct cflayer *layr, struct cfpkt *pkt)
 	struct chnl_net *priv  = container_of(layr, struct chnl_net, chnl);
 	int pktlen;
 	int err = 0;
+	const u8 *ip_version;
+	u8 buf;
 
 	priv = container_of(layr, struct chnl_net, chnl);
 
@@ -90,7 +92,21 @@ static int chnl_recv_cb(struct cflayer *layr, struct cfpkt *pkt)
 	 * send the packet to the net stack.
 	 */
 	skb->dev = priv->netdev;
-	skb->protocol = htons(ETH_P_IP);
+
+	/* check the version of IP */
+	ip_version = skb_header_pointer(skb, 0, 1, &buf);
+	if (!ip_version)
+		return -EINVAL;
+	switch (*ip_version >> 4) {
+	case 4:
+		skb->protocol = htons(ETH_P_IP);
+		break;
+	case 6:
+		skb->protocol = htons(ETH_P_IPV6);
+		break;
+	default:
+		return -EINVAL;
+	}
 
 	/* If we change the header in loop mode, the checksum is corrupted. */
 	if (priv->conn_req.protocol == CAIFPROTO_DATAGRAM_LOOP)
-- 
1.7.0.4

