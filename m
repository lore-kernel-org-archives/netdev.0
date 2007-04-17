From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BRIDGE] Unaligned access on IA64 when comparing ethernet
 addresses
Date: Tue, 17 Apr 2007 13:37:23 -0700
Message-ID: <20070417133723.00031f82@mini>
References: <4624B44A.9040509@sw.ru>
	<20070417.123135.56861973.davem@davemloft.net>
	<4625263D.1000709@linux-foundation.org>
	<20070417.130929.59470175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xemul@sw.ru, netdev@vger.kernel.org, bridge@lists.osdl.org,
	devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34501 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752997AbXDQUiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 16:38:06 -0400
In-Reply-To: <20070417.130929.59470175.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The previous patch relied on the bridge id being aligned by
the compiler (which happens as a side effect). So please use
this instead.

compare_ether_addr() implicitly requires that the addresses
passed are 2-bytes aligned in memory.

This is not true for br_stp_change_bridge_id() and
br_stp_recalculate_bridge_id() in which one of the addresses
is unsigned char *, and thus may not be 2-bytes aligned.

Signed-off-by: Evgeny Kravtsunov <emkravts@openvz.org>
Signed-off-by: Kirill Korotaev <dev@openvz.org>
Signed-off-by: Pavel Emelianov <xemul@openvz.org>
Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---

--- linux-2.6.orig/net/bridge/br_stp_if.c	2007-04-16
20:03:04.000000000 -0700 +++ linux-2.6/net/bridge/br_stp_if.c
2007-04-17 13:25:52.000000000 -0700 @@ -126,23 +126,22 @@
 /* called under bridge lock */
 void br_stp_change_bridge_id(struct net_bridge *br, const unsigned
char *addr) {
-	unsigned char oldaddr[6];
+	bridge_id old_id;
 	struct net_bridge_port *p;
 	int wasroot;
 
 	wasroot = br_is_root_bridge(br);
 
-	memcpy(oldaddr, br->bridge_id.addr, ETH_ALEN);
+	old_id = br->bridge_id;
 	memcpy(br->bridge_id.addr, addr, ETH_ALEN);
 	memcpy(br->dev->dev_addr, addr, ETH_ALEN);
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (!compare_ether_addr(p->designated_bridge.addr,
oldaddr))
+		if (!compare_ether_addr(p->designated_bridge.addr,
old_id.addr)) memcpy(p->designated_bridge.addr, addr, ETH_ALEN);
 
-		if (!compare_ether_addr(p->designated_root.addr,
oldaddr))
+		if (!compare_ether_addr(p->designated_root.addr,
old_id.addr)) memcpy(p->designated_root.addr, addr, ETH_ALEN);
-
 	}
 
 	br_configuration_update(br);
@@ -151,19 +150,17 @@
 		br_become_root_bridge(br);
 }
 
-static const unsigned char br_mac_zero[6];
-
 /* called under bridge lock */
 void br_stp_recalculate_bridge_id(struct net_bridge *br)
 {
-	const unsigned char *addr = br_mac_zero;
+	static const bridge_id id_zero;
+	const unsigned char *addr = id_zero.addr;
 	struct net_bridge_port *p;
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (addr == br_mac_zero ||
+		if (addr == id_zero.addr ||
 		    memcmp(p->dev->dev_addr, addr, ETH_ALEN) < 0)
 			addr = p->dev->dev_addr;
-
 	}
 
 	if (compare_ether_addr(br->bridge_id.addr, addr))
--- linux-2.6.orig/net/bridge/br_private.h	2007-04-17
13:26:48.000000000 -0700 +++ linux-2.6/net/bridge/br_private.h
2007-04-17 13:30:29.000000000 -0700 @@ -36,7 +36,7 @@
 {
 	unsigned char	prio[2];
 	unsigned char	addr[6];
-};
+} __attribute__((aligned(8)));
 
 struct mac_addr
 {
