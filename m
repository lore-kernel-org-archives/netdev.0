From: Akinobu Mita <mita@miraclelinux.com>
Subject: call panic if nl_table allocation fails
Date: Wed, 23 Aug 2006 20:37:40 +0900
Message-ID: <20060823113740.GA7834@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:20569 "EHLO
	mail01.miraclelinux.com") by vger.kernel.org with ESMTP
	id S964880AbWHWLhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 07:37:40 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes crash happen if initialization of nl_table fails
in initcalls. It is better than getting use after free crash later.

Cc: Patrick McHardy <kaber@trash.net>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Akinobu Mita <mita@miraclelinux.com>

Index: work-failmalloc/net/netlink/af_netlink.c
===================================================================
--- work-failmalloc.orig/net/netlink/af_netlink.c
+++ work-failmalloc/net/netlink/af_netlink.c
@@ -1273,8 +1273,7 @@ netlink_kernel_create(int unit, unsigned
 	struct netlink_sock *nlk;
 	unsigned long *listeners = NULL;
 
-	if (!nl_table)
-		return NULL;
+	BUG_ON(!nl_table);
 
 	if (unit<0 || unit>=MAX_LINKS)
 		return NULL;
@@ -1745,11 +1744,8 @@ static int __init netlink_proto_init(voi
 		netlink_skb_parms_too_large();
 
 	nl_table = kcalloc(MAX_LINKS, sizeof(*nl_table), GFP_KERNEL);
-	if (!nl_table) {
-enomem:
-		printk(KERN_CRIT "netlink_init: Cannot allocate nl_table\n");
-		return -ENOMEM;
-	}
+	if (!nl_table)
+		goto panic;
 
 	if (num_physpages >= (128 * 1024))
 		max = num_physpages >> (21 - PAGE_SHIFT);
@@ -1769,7 +1765,7 @@ enomem:
 				nl_pid_hash_free(nl_table[i].hash.table,
 						 1 * sizeof(*hash->table));
 			kfree(nl_table);
-			goto enomem;
+			goto panic;
 		}
 		memset(hash->table, 0, 1 * sizeof(*hash->table));
 		hash->max_shift = order;
@@ -1786,6 +1782,8 @@ enomem:
 	rtnetlink_init();
 out:
 	return err;
+panic:
+	panic("netlink_init: Cannot allocate nl_table\n");
 }
 
 core_initcall(netlink_proto_init);
