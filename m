From: Tobias Klauser <klto@zhaw.ch>
Subject: [PATCH v2] netfilter: ebtables: Use %pM conversion specifier
Date: Thu, 16 Jul 2009 09:25:51 +0200
Message-ID: <1247729151-6210-1-git-send-email-klto@zhaw.ch>
References: <1247655306-21337-1-git-send-email-klto@zhaw.ch>
Cc: netdev@vger.kernel.org, Tobias Klauser <klto@zhaw.ch>
To: bart.de.schuymer@pandora.be, shemminger@linux-foundation.org,
	kaber@trash.net, davem@davemloft.net,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:37271 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbZGPHZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 03:25:52 -0400
In-Reply-To: <1247655306-21337-1-git-send-email-klto@zhaw.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebt_log uses its own implementation of print_mac to print MAC addresses.
This patch converts it to use the %pM conversion specifier for printk.

Signed-off-by: Tobias Klauser <klto@zhaw.ch>
---
 net/bridge/netfilter/ebt_log.c |   29 +++++++----------------------
 1 files changed, 7 insertions(+), 22 deletions(-)

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index a94f3cc..e4ea3fd 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -50,14 +50,6 @@ struct arppayload
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
@@ -88,14 +80,11 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 	unsigned int bitmask;
 
 	spin_lock_bh(&ebt_log_lock);
-	printk("<%c>%s IN=%s OUT=%s MAC source = ", '0' + loginfo->u.log.level,
-	       prefix, in ? in->name : "", out ? out->name : "");
-
-	print_MAC(eth_hdr(skb)->h_source);
-	printk("MAC dest = ");
-	print_MAC(eth_hdr(skb)->h_dest);
-
-	printk("proto = 0x%04x", ntohs(eth_hdr(skb)->h_proto));
+	printk("<%c>%s IN=%s OUT=%s MAC source = %pM MAC dest = %pM proto = 0x%04x",
+	       '0' + loginfo->u.log.level, prefix,
+	       in ? in->name : "", out ? out->name : "",
+	       eth_hdr(skb)->h_source, eth_hdr(skb)->h_dest,
+	       ntohs(eth_hdr(skb)->h_proto));
 
 	if (loginfo->type == NF_LOG_TYPE_LOG)
 		bitmask = loginfo->u.log.logflags;
@@ -171,12 +160,8 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 				printk(" INCOMPLETE ARP payload");
 				goto out;
 			}
-			printk(" ARP MAC SRC=");
-			print_MAC(ap->mac_src);
-			printk(" ARP IP SRC=%pI4", ap->ip_src);
-			printk(" ARP MAC DST=");
-			print_MAC(ap->mac_dst);
-			printk(" ARP IP DST=%pI4", ap->ip_dst);
+			printk(" ARP MAC SRC=%pM ARP IP SRC=%pI4 ARP MAC DST=%pM ARP IP DST=%pI4",
+					ap->mac_src, ap->ip_src, ap->mac_dst, ap->ip_dst);
 		}
 	}
 out:
-- 
1.6.0.4

