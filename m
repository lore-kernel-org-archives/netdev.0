From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/5] llc: use more efficient ether address routines
Date: Tue, 23 May 2006 17:04:18 -0700
Message-ID: <20060524000530.478027000@localhost.localdomain>
References: <20060524000414.052569000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:7301 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932113AbWEXAFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 20:05:48 -0400
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Content-Disposition: inline; filename=llc-ether-routines.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use more cache efficient Ethernet address manipulation functions
in etherdevice.h.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- llc.orig/include/net/llc_if.h
+++ llc/include/net/llc_if.h
@@ -16,6 +16,7 @@
 #include <linux/if.h>
 #include <linux/if_arp.h>
 #include <linux/llc.h>
+#include <linux/etherdevice.h>
 #include <net/llc.h>
 
 #define LLC_DATAUNIT_PRIM	1
@@ -61,8 +62,6 @@
 #define LLC_STATUS_CONFLICT	7 /* disconnect conn */
 #define LLC_STATUS_RESET_DONE	8 /*  */
 
-extern u8 llc_mac_null_var[IFHWADDRLEN];
-
 /**
  *      llc_mac_null - determines if a address is a null mac address
  *      @mac: Mac address to test if null.
@@ -70,12 +69,12 @@ extern u8 llc_mac_null_var[IFHWADDRLEN];
  *      Determines if a given address is a null mac address.  Returns 0 if the
  *      address is not a null mac, 1 if the address is a null mac.
  */
-static __inline__ int llc_mac_null(u8 *mac)
+static inline int llc_mac_null(const u8 *mac)
 {
-	return !memcmp(mac, llc_mac_null_var, IFHWADDRLEN);
+	return is_zero_ether_addr(mac);
 }
 
-static __inline__ int llc_addrany(struct llc_addr *addr)
+static inline int llc_addrany(const struct llc_addr *addr)
 {
 	return llc_mac_null(addr->mac) && !addr->lsap;
 }
@@ -89,9 +88,9 @@ static __inline__ int llc_addrany(struct
  *	is not a complete match up to len, 1 if a complete match up to len is
  *	found.
  */
-static __inline__ int llc_mac_match(u8 *mac1, u8 *mac2)
+static inline int llc_mac_match(const u8 *mac1, const u8 *mac2)
 {
-	return !memcmp(mac1, mac2, IFHWADDRLEN);
+	return !compare_ether_addr(mac1, mac2);
 }
 
 extern int llc_establish_connection(struct sock *sk, u8 *lmac,
--- br.orig/net/llc/llc_if.c
+++ br/net/llc/llc_if.c
@@ -26,8 +26,6 @@
 #include <net/llc_c_st.h>
 #include <net/tcp_states.h>
 
-u8 llc_mac_null_var[IFHWADDRLEN];
-
 /**
  *	llc_build_and_send_pkt - Connection data sending for upper layers.
  *	@sk: connection

--

