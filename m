From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/3) llc - need to may_pull header
Date: Fri, 29 Aug 2003 10:47:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829104713.1ae98328.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
   "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

LLC needs to call may_pull before overlaying the header
data structure.  Otherwise there is no guarantee that the data
isn't sitting in fragments.

diff -Nru a/net/llc/llc_mac.c b/net/llc/llc_mac.c
--- a/net/llc/llc_mac.c	Fri Aug 29 09:02:19 2003
+++ b/net/llc/llc_mac.c	Fri Aug 29 09:02:19 2003
@@ -35,7 +35,7 @@
 
 u8 llc_mac_null_var[IFHWADDRLEN];
 
-static void fix_up_incoming_skb(struct sk_buff *skb);
+static int fix_up_incoming_skb(struct sk_buff *skb);
 static void llc_station_rcv(struct sk_buff *skb);
 static void llc_sap_rcv(struct llc_sap *sap, struct sk_buff *skb);
 
@@ -69,7 +69,8 @@
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (!skb)
 		goto out;
-	fix_up_incoming_skb(skb);
+	if (!fix_up_incoming_skb(skb))
+		goto drop;
 	pdu = llc_pdu_sn_hdr(skb);
 	if (!pdu->dsap) { /* NULL DSAP, refer to station */
 		dprintk("%s: calling llc_station_rcv!\n", __FUNCTION__);
@@ -172,11 +173,15 @@
  *	by looking at the two lowest-order bits of the first control field
  *	byte; field is either 3 or 4 bytes long.
  */
-static void fix_up_incoming_skb(struct sk_buff *skb)
+static int fix_up_incoming_skb(struct sk_buff *skb)
 {
 	u8 llc_len = 2;
-	struct llc_pdu_sn *pdu = (struct llc_pdu_sn *)skb->data;
+	struct llc_pdu_sn *pdu;
+
+	if (!pskb_may_pull(skb, sizeof(*pdu)))
+		return 0;
 
+	pdu = (struct llc_pdu_sn *)skb->data;
 	if ((pdu->ctrl_1 & LLC_PDU_TYPE_MASK) == LLC_PDU_TYPE_U)
 		llc_len = 1;
 	llc_len += 2;
@@ -188,6 +193,7 @@
 
 		skb_trim(skb, data_size);
 	}
+	return 1;
 }
 
 /*
