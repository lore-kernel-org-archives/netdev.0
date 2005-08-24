From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 1/2] Cleanup direct calls into IP stack
Date: Wed, 24 Aug 2005 18:15:23 +0100
Message-ID: <20050824171523.GA8260__781.555070034479$1124904120$gmane$org@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@linux-mips.org, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of the calls to ip_rcv and arp_rcv which were laying violations
anyway.  With those being replaced by netif_rx less parts of AX.25 and
relatives depend on INET support actually being enabled.  This also
will make PF_PACKET sockets work for IP and ARP packets receiver over
AX.25 and for IP packets over NET/ROM.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 net/ax25/ax25_in.c     |   13 +++----------
 net/netrom/af_netrom.c |    5 ++---
 net/netrom/nr_dev.c    |    5 ++---
 3 files changed, 7 insertions(+), 16 deletions(-)

Index: linux-cvs/net/ax25/ax25_in.c
===================================================================
--- linux-cvs.orig/net/ax25/ax25_in.c
+++ linux-cvs/net/ax25/ax25_in.c
@@ -9,7 +9,6 @@
  * Copyright (C) Joerg Reuter DL1BKE (jreuter@yaina.de)
  * Copyright (C) Hans-Joachim Hetscher DD8NE (dd8ne@bnv-bamberg.de)
  */
-#include <linux/config.h>
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/socket.h>
@@ -26,9 +25,7 @@
 #include <linux/skbuff.h>
 #include <linux/netfilter.h>
 #include <net/sock.h>
-#include <net/ip.h>			/* For ip_rcv */
 #include <net/tcp.h>
-#include <net/arp.h>			/* For arp_rcv */
 #include <asm/uaccess.h>
 #include <asm/system.h>
 #include <linux/fcntl.h>
@@ -114,7 +111,6 @@ int ax25_rx_iframe(ax25_cb *ax25, struct
 
 	pid = *skb->data;
 
-#ifdef CONFIG_INET
 	if (pid == AX25_P_IP) {
 		/* working around a TCP bug to keep additional listeners
 		 * happy. TCP re-uses the buffer and destroys the original
@@ -132,10 +128,9 @@ int ax25_rx_iframe(ax25_cb *ax25, struct
 		skb->dev      = ax25->ax25_dev->dev;
 		skb->pkt_type = PACKET_HOST;
 		skb->protocol = htons(ETH_P_IP);
-		ip_rcv(skb, skb->dev, NULL);	/* Wrong ptype */
+		netif_rx(skb);
 		return 1;
 	}
-#endif
 	if (pid == AX25_P_SEGMENT) {
 		skb_pull(skb, 1);	/* Remove PID */
 		return ax25_rx_fragment(ax25, skb);
@@ -250,7 +245,6 @@ static int ax25_rcv(struct sk_buff *skb,
 
 		/* Now we are pointing at the pid byte */
 		switch (skb->data[1]) {
-#ifdef CONFIG_INET
 		case AX25_P_IP:
 			skb_pull(skb,2);		/* drop PID/CTRL */
 			skb->h.raw    = skb->data;
@@ -258,7 +252,7 @@ static int ax25_rcv(struct sk_buff *skb,
 			skb->dev      = dev;
 			skb->pkt_type = PACKET_HOST;
 			skb->protocol = htons(ETH_P_IP);
-			ip_rcv(skb, dev, ptype);	/* Note ptype here is the wrong one, fix me later */
+			netif_rx(skb);
 			break;
 
 		case AX25_P_ARP:
@@ -268,9 +262,8 @@ static int ax25_rcv(struct sk_buff *skb,
 			skb->dev      = dev;
 			skb->pkt_type = PACKET_HOST;
 			skb->protocol = htons(ETH_P_ARP);
-			arp_rcv(skb, dev, ptype);	/* Note ptype here is wrong... */
+			netif_rx(skb);
 			break;
-#endif
 		case AX25_P_TEXT:
 			/* Now find a suitable dgram socket */
 			sk = ax25_get_socket(&dest, &src, SOCK_DGRAM);
Index: linux-cvs/net/netrom/af_netrom.c
===================================================================
--- linux-cvs.orig/net/netrom/af_netrom.c
+++ linux-cvs/net/netrom/af_netrom.c
@@ -858,17 +858,16 @@ int nr_rx_frame(struct sk_buff *skb, str
 	frametype          = skb->data[19] & 0x0F;
 	flags              = skb->data[19] & 0xF0;
 
-#ifdef CONFIG_INET
 	/*
 	 * Check for an incoming IP over NET/ROM frame.
 	 */
-	if (frametype == NR_PROTOEXT && circuit_index == NR_PROTO_IP && circuit_id == NR_PROTO_IP) {
+	if (frametype == NR_PROTOEXT &&
+	    circuit_index == NR_PROTO_IP && circuit_id == NR_PROTO_IP) {
 		skb_pull(skb, NR_NETWORK_LEN + NR_TRANSPORT_LEN);
 		skb->h.raw = skb->data;
 
 		return nr_rx_ip(skb, dev);
 	}
-#endif
 
 	/*
 	 * Find an existing socket connection, based on circuit ID, if it's
Index: linux-cvs/net/netrom/nr_dev.c
===================================================================
--- linux-cvs.orig/net/netrom/nr_dev.c
+++ linux-cvs/net/netrom/nr_dev.c
@@ -38,8 +38,6 @@
 #include <net/ax25.h>
 #include <net/netrom.h>
 
-#ifdef CONFIG_INET
-
 /*
  *	Only allow IP over NET/ROM frames through if the netrom device is up.
  */
@@ -64,11 +62,12 @@ int nr_rx_ip(struct sk_buff *skb, struct
 	skb->nh.raw   = skb->data;
 	skb->pkt_type = PACKET_HOST;
 
-	ip_rcv(skb, skb->dev, NULL);
+	netif_rx(skb);
 
 	return 1;
 }
 
+#ifdef CONFIG_INET
 
 static int nr_rebuild_header(struct sk_buff *skb)
 {
