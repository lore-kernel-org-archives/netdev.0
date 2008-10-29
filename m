From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] udp: calculate udp_mem based on low memory instead of all
 memory
Date: Wed, 29 Oct 2008 10:22:16 +0100
Message-ID: <49082B48.2030905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000901080204090702070001"
Cc: Linux Netdev List <netdev@vger.kernel.org>, miquels@cistron.nl
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:33233 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbYJ2JW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 05:22:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000901080204090702070001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

While working on UDP, I found a comment in udp_init() was outdated.

This patch could help some 32bit machines, and restore comment validity :)

No hurry, so I based it on top of my previous patch (net-next-2.6)

Thanks

[PATCH] udp: calculate udp_mem based on low memory instead of all memory

This patch mimics commit 57413ebc4e0f1e471a3b4db4aff9a85c083d090e
(tcp: calculate tcp_mem based on low memory instead of all memory)

The udp_mem array which contains limits on the total amount of memory
used by UDP sockets is calculated based on nr_all_pages.  On a 32 bits
x86 system, we should base this on the number of lowmem pages.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------000901080204090702070001
Content-Type: text/plain;
 name="udp_mem.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp_mem.patch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5c1cbe1..eab6b36 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -81,6 +81,8 @@
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 #include <linux/bootmem.h>
+#include <linux/highmem.h>
+#include <linux/swap.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
 #include <linux/module.h>
@@ -1751,15 +1753,16 @@ void __init udp_table_init(struct udp_table *table)
 
 void __init udp_init(void)
 {
-	unsigned long limit;
+	unsigned long nr_pages, limit;
 
 	udp_table_init(&udp_table);
 	/* Set the pressure threshold up by the same strategy of TCP. It is a
 	 * fraction of global memory that is up to 1/2 at 256 MB, decreasing
 	 * toward zero with the amount of memory, with a floor of 128 pages.
 	 */
-	limit = min(nr_all_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
-	limit = (limit * (nr_all_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
+	nr_pages = totalram_pages - totalhigh_pages;
+	limit = min(nr_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
+	limit = (limit * (nr_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
 	limit = max(limit, 128UL);
 	sysctl_udp_mem[0] = limit / 4 * 3;
 	sysctl_udp_mem[1] = limit;

--------------000901080204090702070001--
