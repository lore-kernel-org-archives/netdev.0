From: "David S. Miller" <davem@redhat.com>
Subject: PPPOE skb leak
Date: Mon, 24 Nov 2003 19:54:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124195453.0e438915.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mostrows@speakeasy.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


PPPOE packet reception does not check the return value of
sock_queue_rcv_skb() and therefore can leak packets.

Here is the fix I've installed.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1486  -> 1.1487 
#	 drivers/net/pppoe.c	1.35    -> 1.36   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/24	davem@nuts.ninka.net	1.1487
# [PPPOE]: Do not leak SKB if sock_queue_rcv_skb() fails.
# --------------------------------------------
#
diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	Mon Nov 24 19:50:44 2003
+++ b/drivers/net/pppoe.c	Mon Nov 24 19:50:44 2003
@@ -352,7 +352,8 @@
 		if (!__pppoe_xmit( relay_po->sk, skb))
 			goto abort_put;
 	} else {
-		sock_queue_rcv_skb(sk, skb);
+		if (sock_queue_rcv_skb(sk, skb))
+			goto abort_kfree;
 	}
 
 	return NET_RX_SUCCESS;
