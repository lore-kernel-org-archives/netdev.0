From: "David S. Miller" <davem@redhat.com>
Subject: ECONET skb leak fix
Date: Mon, 24 Nov 2003 20:04:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124200447.7696f2c5.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Econet had one spot where it could leak SKBs due to a missing
return value check.

Nobody really maintains this thing anymore so I did not CC: any
maintainer :)

Also return NET_RX_DROP as appropriate.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1487  -> 1.1488 
#	net/econet/af_econet.c	1.27    -> 1.28   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/24	davem@nuts.ninka.net	1.1488
# [ECONET]: Do not leak SKBs if ec_queue_packet() fails.
# 
# Also, make sure NET_RX_DROP is returned if we did not accept the
# packet.
# --------------------------------------------
#
diff -Nru a/net/econet/af_econet.c b/net/econet/af_econet.c
--- a/net/econet/af_econet.c	Mon Nov 24 20:01:24 2003
+++ b/net/econet/af_econet.c	Mon Nov 24 20:01:24 2003
@@ -1041,12 +1041,15 @@
 	if (!sk)
 		goto drop;
 
-	return ec_queue_packet(sk, skb, edev->net, hdr->src_stn, hdr->cb, 
-			       hdr->port);
+	if (ec_queue_packet(sk, skb, edev->net, hdr->src_stn, hdr->cb,
+			    hdr->port))
+		goto drop;
+
+	return 0;
 
 drop:
 	kfree_skb(skb);
-	return 0;
+	return NET_RX_DROP;
 }
 
 static struct packet_type econet_packet_type = {
