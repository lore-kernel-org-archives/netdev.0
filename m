From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] bridge: only provide proxy ARP when CONFIG_INET is enabled
Date: Tue, 13 Jan 2015 15:10:27 +0100
Message-ID: <56868207.rHBDZL3pbk@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, Kyeyoon Park <kyeyoonp@codeaurora.org>,
	bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:56334 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbbAMOKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 09:10:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When IPV4 support is disabled, we cannot call arp_send from
the bridge code, which would result in a kernel link error:

net/built-in.o: In function `br_handle_frame_finish':
:(.text+0x59914): undefined reference to `arp_send'
:(.text+0x59a50): undefined reference to `arp_tbl'

This makes the newly added proxy ARP support in the bridge
code depend on the CONFIG_INET symbol and lets the compiler
optimize the code out to avoid the link error.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 958501163ddd ("bridge: Add support for IEEE 802.11 Proxy ARP")
Cc: Kyeyoon Park <kyeyoonp@codeaurora.org>

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 1f1de715197c..e2aa7be3a847 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -154,7 +154,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	dst = NULL;
 
 	if (is_broadcast_ether_addr(dest)) {
-		if (p->flags & BR_PROXYARP &&
+		if (IS_ENABLED(CONFIG_INET) &&
+		    p->flags & BR_PROXYARP &&
 		    skb->protocol == htons(ETH_P_ARP))
 			br_do_proxy_arp(skb, br, vid);
 
