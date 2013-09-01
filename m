From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] llc: Use normal etherdevice.h tests
Date: Sun, 01 Sep 2013 13:11:55 -0700
Message-ID: <1378066315.1953.23.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the llc_<foo> static inlines to the
equivalents from etherdevice.h and remove
the llc_<foo> static inline functions.

llc_mac_null -> is_zero_ether_addr
llc_mac_multicast -> is_multicast_ether_addr
llc_mac_match -> ether_addr_equal

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/llc_if.h | 30 ------------------------------
 net/llc/af_llc.c     |  6 +++---
 net/llc/llc_conn.c   |  6 +++---
 net/llc/llc_sap.c    |  4 ++--
 4 files changed, 8 insertions(+), 38 deletions(-)

diff --git a/include/net/llc_if.h b/include/net/llc_if.h
index b595a00..f0cb909 100644
--- a/include/net/llc_if.h
+++ b/include/net/llc_if.h
@@ -62,36 +62,6 @@
 #define LLC_STATUS_CONFLICT	7 /* disconnect conn */
 #define LLC_STATUS_RESET_DONE	8 /*  */
 
-/**
- *      llc_mac_null - determines if a address is a null mac address
- *      @mac: Mac address to test if null.
- *
- *      Determines if a given address is a null mac address.  Returns 0 if the
- *      address is not a null mac, 1 if the address is a null mac.
- */
-static inline int llc_mac_null(const u8 *mac)
-{
-	return is_zero_ether_addr(mac);
-}
-
-static inline int llc_mac_multicast(const u8 *mac)
-{
-	return is_multicast_ether_addr(mac);
-}
-/**
- *	llc_mac_match - determines if two mac addresses are the same
- *	@mac1: First mac address to compare.
- *	@mac2: Second mac address to compare.
- *
- *	Determines if two given mac address are the same.  Returns 0 if there
- *	is not a complete match up to len, 1 if a complete match up to len is
- *	found.
- */
-static inline int llc_mac_match(const u8 *mac1, const u8 *mac2)
-{
-	return !compare_ether_addr(mac1, mac2);
-}
-
 extern int llc_establish_connection(struct sock *sk, u8 *lmac,
 				    u8 *dmac, u8 dsap);
 extern int llc_build_and_send_pkt(struct sock *sk, struct sk_buff *skb);
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 48aaa89..6cba486 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -321,12 +321,12 @@ static int llc_ui_bind(struct socket *sock, struct sockaddr *uaddr, int addrlen)
 		if (llc->dev) {
 			if (!addr->sllc_arphrd)
 				addr->sllc_arphrd = llc->dev->type;
-			if (llc_mac_null(addr->sllc_mac))
+			if (is_zero_ether_addr(addr->sllc_mac))
 				memcpy(addr->sllc_mac, llc->dev->dev_addr,
 				       IFHWADDRLEN);
 			if (addr->sllc_arphrd != llc->dev->type ||
-			    !llc_mac_match(addr->sllc_mac,
-					   llc->dev->dev_addr)) {
+			    !ether_addr_equal(addr->sllc_mac,
+					      llc->dev->dev_addr)) {
 				rc = -EINVAL;
 				llc->dev = NULL;
 			}
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 0d0d416..cd87241 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -478,8 +478,8 @@ static inline bool llc_estab_match(const struct llc_sap *sap,
 
 	return llc->laddr.lsap == laddr->lsap &&
 		llc->daddr.lsap == daddr->lsap &&
-		llc_mac_match(llc->laddr.mac, laddr->mac) &&
-		llc_mac_match(llc->daddr.mac, daddr->mac);
+		ether_addr_equal(llc->laddr.mac, laddr->mac) &&
+		ether_addr_equal(llc->daddr.mac, daddr->mac);
 }
 
 /**
@@ -550,7 +550,7 @@ static inline bool llc_listener_match(const struct llc_sap *sap,
 
 	return sk->sk_type == SOCK_STREAM && sk->sk_state == TCP_LISTEN &&
 		llc->laddr.lsap == laddr->lsap &&
-		llc_mac_match(llc->laddr.mac, laddr->mac);
+		ether_addr_equal(llc->laddr.mac, laddr->mac);
 }
 
 static struct sock *__llc_lookup_listener(struct llc_sap *sap,
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index 78be45c..e585069 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -302,7 +302,7 @@ static inline bool llc_dgram_match(const struct llc_sap *sap,
 
      return sk->sk_type == SOCK_DGRAM &&
 	  llc->laddr.lsap == laddr->lsap &&
-	  llc_mac_match(llc->laddr.mac, laddr->mac);
+	  ether_addr_equal(llc->laddr.mac, laddr->mac);
 }
 
 /**
@@ -425,7 +425,7 @@ void llc_sap_handler(struct llc_sap *sap, struct sk_buff *skb)
 	llc_pdu_decode_da(skb, laddr.mac);
 	llc_pdu_decode_dsap(skb, &laddr.lsap);
 
-	if (llc_mac_multicast(laddr.mac)) {
+	if (is_multicast_ether_addr(laddr.mac)) {
 		llc_sap_mcast(sap, &laddr, skb);
 		kfree_skb(skb);
 	} else {
