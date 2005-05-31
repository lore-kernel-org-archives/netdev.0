From: Atkinson Stephen-G19998 <satkinson@motorola.com>
Subject: Patch for "ETH_P_ALL_NO_NIT"
Date: Tue, 31 May 2005 11:38:11 -0500
Message-ID: <5D454811D0A1D711A12A00065BF36FAD1A0E93A4@il06exm11>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I would like to be able to receive all packets (regardless of type) on 
a given net_device. One way to do this would be to use ETH_P_ALL
however, ETH_P_ALL has two meanings, 1) receive all packets and 2) behave 
as a "NIT" (Network Interface Tap?). The NIT functionality causes packets
transmitted on the net_device in question to be "received" by an ETH_P_ALL
socket, unless the packet was sent by that socket.

So, I'd like to propose a new ethernet type (ETH_P_ALL_NO_NIT) which 
would behave like ETH_P_ALL without the side effects of NIT.

I've included a patch for ETH_P_ALL_NO_NIT below.

Comments?

Signed-off-by: Steve Atkinson <satkinson@motorola.com>

--- linux-2.6.9_orig/include/linux/if_ether.h	2004-10-18 17:54:37.000000000 -0400
+++ linux-2.6.9/include/linux/if_ether.h	2005-05-31 10:32:50.000000000 -0400
@@ -91,6 +91,7 @@
 #define ETH_P_IRDA	0x0017		/* Linux-IrDA			*/
 #define ETH_P_ECONET	0x0018		/* Acorn Econet			*/
 #define ETH_P_HDLC	0x0019		/* HDLC frames			*/
+#define ETH_P_ALL_NO_NIT	0x0020	/* Every packet but DON'T ENABLE netdev_nit */
 
 /*
  *	This is an Ethernet frame header.
--- linux-2.6.9_orig/net/core/dev.c	2004-10-18 17:54:08.000000000 -0400
+++ linux-2.6.9/net/core/dev.c	2005-05-31 10:56:50.000000000 -0400
@@ -276,7 +276,10 @@
 	if (pt->type == htons(ETH_P_ALL)) {
 		netdev_nit++;
 		list_add_rcu(&pt->list, &ptype_all);
-	} else {
+	} else if(pt->type == htons(ETH_P_ALL_NO_NIT)) {
+		list_add_rcu(&pt->list, &ptype_all);
+	}
+	else {
 		hash = ntohs(pt->type) & 15;
 		list_add_rcu(&pt->list, &ptype_base[hash]);
 	}
@@ -310,9 +313,11 @@
 	if (pt->type == htons(ETH_P_ALL)) {
 		netdev_nit--;
 		head = &ptype_all;
-	} else
+	} else if (pt->type == htons(ETH_P_ALL_NO_NIT)) {
+		head = &ptype_all;
+	} else {
 		head = &ptype_base[ntohs(pt->type) & 15];
-
+	}
 	list_for_each_entry(pt1, head, list) {
 		if (pt == pt1) {
 			list_del_rcu(&pt->list);
@@ -1072,9 +1077,10 @@
 		/* Never send packets back to the socket
 		 * they originated from - MvS (miquels@drinkel.ow.org)
 		 */
-		if ((ptype->dev == dev || !ptype->dev) &&
-		    (ptype->af_packet_priv == NULL ||
-		     (struct sock *)ptype->af_packet_priv != skb->sk)) {
+		if ( (ptype->type != ETH_P_ALL_NO_NIT)  &&
+			  (ptype->dev == dev || !ptype->dev) &&
+			  (ptype->af_packet_priv == NULL ||
+				(struct sock *)ptype->af_packet_priv != skb->sk)) {
 			struct sk_buff *skb2= skb_clone(skb, GFP_ATOMIC);
 			if (!skb2)
 				break;
