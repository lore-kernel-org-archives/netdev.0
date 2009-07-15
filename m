From: Tobias Klauser <klto@zhaw.ch>
Subject: [PATCH] netfilter: ebtables: Use print_mac instead of own function
Date: Wed, 15 Jul 2009 12:55:06 +0200
Message-ID: <1247655306-21337-1-git-send-email-klto@zhaw.ch>
Cc: netdev@vger.kernel.org, Tobias Klauser <klto@zhaw.ch>
To: bart.de.schuymer@pandora.be, shemminger@linux-foundation.org,
	kaber@trash.net, davem@davemloft.net,
	ebtables-devel@lists.sourceforge.net,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:50186 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754069AbZGOKzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2009 06:55:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebt_log uses its own implementation of print_mac to print MAC addresses.
This patch converts it to use print_mac from linux/if_ether.h

Signed-off-by: Tobias Klauser <klto@zhaw.ch>
---
 net/bridge/netfilter/ebt_log.c |   31 +++++++++++--------------------
 1 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index a94f3cc..70fd072 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -12,6 +12,7 @@
 #include <linux/ip.h>
 #include <linux/in.h>
 #include <linux/if_arp.h>
+#include <linux/if_ether.h>
 #include <linux/spinlock.h>
 #include <net/netfilter/nf_log.h>
 #include <linux/ipv6.h>
@@ -50,14 +51,6 @@ struct arppayload
 	unsigned char ip_dst[4];
 };
 
-static void print_MAC(const unsigned char *p)
-{
-	int i;
-
-	for (i = 0; i < ETH_ALEN; i++, p++)
-		printk("%02x%c", *p, i == ETH_ALEN - 1 ? ' ':':');
-}
-
 static void
 print_ports(const struct sk_buff *skb, uint8_t protocol, int offset)
 {
@@ -86,16 +79,16 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
    const char *prefix)
 {
 	unsigned int bitmask;
+	DECLARE_MAC_BUF(macbuf);
 
 	spin_lock_bh(&ebt_log_lock);
-	printk("<%c>%s IN=%s OUT=%s MAC source = ", '0' + loginfo->u.log.level,
-	       prefix, in ? in->name : "", out ? out->name : "");
-
-	print_MAC(eth_hdr(skb)->h_source);
-	printk("MAC dest = ");
-	print_MAC(eth_hdr(skb)->h_dest);
-
-	printk("proto = 0x%04x", ntohs(eth_hdr(skb)->h_proto));
+	printk("<%c>%s IN=%s OUT=%s MAC source = %s",
+	       '0' + loginfo->u.log.level, prefix,
+	       in ? in->name : "", out ? out->name : "",
+	       print_mac(macbuf, eth_hdr(skb)->h_source));
+	printk(" MAC dest = %s proto = 0x%04x",
+	       print_mac(macbuf, eth_hdr(skb)->h_dest),
+	       ntohs(eth_hdr(skb)->h_proto));
 
 	if (loginfo->type == NF_LOG_TYPE_LOG)
 		bitmask = loginfo->u.log.logflags;
@@ -171,11 +164,9 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 				printk(" INCOMPLETE ARP payload");
 				goto out;
 			}
-			printk(" ARP MAC SRC=");
-			print_MAC(ap->mac_src);
+			printk(" ARP MAC SRC=%s", print_mac(macbuf, ap->mac_src));
 			printk(" ARP IP SRC=%pI4", ap->ip_src);
-			printk(" ARP MAC DST=");
-			print_MAC(ap->mac_dst);
+			printk(" ARP MAC DST=%s", print_mac(macbuf, ap->mac_dst));
 			printk(" ARP IP DST=%pI4", ap->ip_dst);
 		}
 	}
-- 
1.6.0.4

