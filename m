From: Akinobu Mita <mita@miraclelinux.com>
Subject: [PATCH] fix use after free in netlink_kernel_create()
Date: Sun, 13 Aug 2006 18:15:35 +0800
Message-ID: <20060813101535.GA8703@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:31585 "EHLO
	mail01.miraclelinux.com") by vger.kernel.org with ESMTP
	id S1750895AbWHMKPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 06:15:41 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch invalidates nl_table by setting NULL when netlink
initialization failed. Otherwise netlink_kernel_create() would
access nl_table which has already been freed.

CC: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Akinobu Mita <mita@miraclelinux.com>

 net/netlink/af_netlink.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

Index: work-failmalloc/net/netlink/af_netlink.c
===================================================================
--- work-failmalloc.orig/net/netlink/af_netlink.c
+++ work-failmalloc/net/netlink/af_netlink.c
@@ -1745,11 +1745,8 @@ static int __init netlink_proto_init(voi
 		netlink_skb_parms_too_large();
 
 	nl_table = kcalloc(MAX_LINKS, sizeof(*nl_table), GFP_KERNEL);
-	if (!nl_table) {
-enomem:
-		printk(KERN_CRIT "netlink_init: Cannot allocate nl_table\n");
-		return -ENOMEM;
-	}
+	if (!nl_table)
+		goto enomem;
 
 	if (num_physpages >= (128 * 1024))
 		max = num_physpages >> (21 - PAGE_SHIFT);
@@ -1769,6 +1766,7 @@ enomem:
 				nl_pid_hash_free(nl_table[i].hash.table,
 						 1 * sizeof(*hash->table));
 			kfree(nl_table);
+			nl_table = NULL;
 			goto enomem;
 		}
 		memset(hash->table, 0, 1 * sizeof(*hash->table));
@@ -1786,6 +1784,9 @@ enomem:
 	rtnetlink_init();
 out:
 	return err;
+enomem:
+	printk(KERN_CRIT "netlink_init: Cannot allocate nl_table\n");
+	return -ENOMEM;
 }
 
 core_initcall(netlink_proto_init);
