From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] bridge: avoid ptype_all packet handling
Date: Wed, 28 Feb 2007 17:18:46 -0800
Message-ID: <20070228171846.679d8733@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:50462 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932900AbXCABVf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 20:21:35 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was measuring bridging/routing performance and noticed this.

The current code runs the "all packet" type handlers before calling the
bridge hook.  If an application (like some DHCP clients) is using AF_PACKET,
this means that each received packet gets run through the Berkeley Packet Filter
code in sk_run_filter (slow).

By moving the bridging hook to run first, the packets flowing through
the bridge get filtered out there. This results in a 14%
improvement in performance, but it does mean that some snooping applications
would miss packets if being used on a bridge.  The correct way to see all
packets on a bridge is to set the bridge pseudo-device to promiscuous
mode.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/core/dev.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index cf71614..dc2cda6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1792,6 +1792,10 @@ int netif_receive_skb(struct sk_buff *skb)
 
 	rcu_read_lock();
 
+	if (handle_bridge(&skb, &pt_prev, &ret, orig_dev))
+		goto out;
+
+
 #ifdef CONFIG_NET_CLS_ACT
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
@@ -1826,9 +1830,6 @@ int netif_receive_skb(struct sk_buff *skb)
 ncls:
 #endif
 
-	if (handle_bridge(&skb, &pt_prev, &ret, orig_dev))
-		goto out;
-
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type)&15], list) {
 		if (ptype->type == type &&
-- 
1.4.4.2

