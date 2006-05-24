From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/5] llc: add multicast support for datagrams
Date: Tue, 23 May 2006 17:04:19 -0700
Message-ID: <20060524000530.686862000@localhost.localdomain>
References: <20060524000414.052569000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8581 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932451AbWEXAFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 20:05:49 -0400
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Content-Disposition: inline; filename=llc-mc-recv.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow mulitcast reception of datagrams (similar to UDP).
All sockets bound to the same SAP receive a clone.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- llc.orig/include/net/llc_if.h
+++ llc/include/net/llc_if.h
@@ -79,6 +79,10 @@ static inline int llc_addrany(const stru
 	return llc_mac_null(addr->mac) && !addr->lsap;
 }
 
+static inline int llc_mac_multicast(const u8 *mac)
+{
+	return is_multicast_ether_addr(mac);
+}
 /**
  *	llc_mac_match - determines if two mac addresses are the same
  *	@mac1: First mac address to compare.
--- br.orig/net/llc/llc_sap.c
+++ br/net/llc/llc_sap.c
@@ -282,7 +282,7 @@ static void llc_sap_rcv(struct llc_sap *
  *	mac, and local sap. Returns pointer for socket found, %NULL otherwise.
  */
 static struct sock *llc_lookup_dgram(struct llc_sap *sap,
-				     struct llc_addr *laddr)
+				     const struct llc_addr *laddr)
 {
 	struct sock *rc;
 	struct hlist_node *node;
@@ -304,19 +304,62 @@ found:
 	return rc;
 }
 
+/**
+ * 	llc_sap_mcast - Deliver multicast PDU's to all matching datagram sockets.
+ *	@sap: SAP
+ *	@laddr: address of local LLC (MAC + SAP)
+ *
+ *	Search socket list of the SAP and finds connections with same sap.
+ *	Deliver clone to each.
+ */
+static void llc_sap_mcast(struct llc_sap *sap,
+			  const struct llc_addr *laddr,
+			  struct sk_buff *skb)
+{
+	struct sock *sk;
+	struct hlist_node *node;
+
+	read_lock_bh(&sap->sk_list.lock);
+	sk_for_each(sk, node, &sap->sk_list.list) {
+		struct llc_sock *llc = llc_sk(sk);
+		struct sk_buff *skb1;
+
+		if (sk->sk_type != SOCK_DGRAM)
+			continue;
+
+		if (llc->laddr.lsap != laddr->lsap)
+			continue;
+
+		skb1 = skb_clone(skb, GFP_ATOMIC);
+		if (!skb1)
+			break;
+
+		sock_hold(sk);
+		skb_set_owner_r(skb1, sk);
+		llc_sap_rcv(sap, skb1);
+		sock_put(sk);
+	}
+	read_unlock_bh(&sap->sk_list.lock);
+}
+
+
 void llc_sap_handler(struct llc_sap *sap, struct sk_buff *skb)
 {
 	struct llc_addr laddr;
-	struct sock *sk;
 
 	llc_pdu_decode_da(skb, laddr.mac);
 	llc_pdu_decode_dsap(skb, &laddr.lsap);
 
-	sk = llc_lookup_dgram(sap, &laddr);
-	if (sk) {
-		skb_set_owner_r(skb, sk);
-		llc_sap_rcv(sap, skb);
-		sock_put(sk);
-	} else
+	if (llc_mac_multicast(laddr.mac)) {
+		llc_sap_mcast(sap, &laddr, skb);
 		kfree_skb(skb);
+	} else {
+		struct sock *sk = llc_lookup_dgram(sap, &laddr);
+		if (sk) {
+			skb_set_owner_r(skb, sk);
+			llc_sap_rcv(sap, skb);
+			sock_put(sk);
+		} else
+			kfree_skb(skb);
+	}
 }

--

