From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH] fib_info_hashfn leads to long hash chains
Date: Sun, 29 Apr 2007 11:03:36 -0400
Message-ID: <20070429150336.GC10824@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:35921 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753930AbXD2PDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Apr 2007 11:03:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

The patch below fixes a case where fib_find_info() is consume excessive 
amounts of CPU during the creation of 10000 PPP interfaces.  In access 
servers, each point to point link has the same local address, but a different 
destination and interface.  Because the device is not included in the hash 
calculation, the chain grows excessively large and we end up spinning the 
CPU walking the list.  As near as I can tell, this shouldn't have any negative 
sideeffects, but someone with a better understanding of fib_semantics.c will 
need to check over it.  Cheers,

		-ben

Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit 
mask of 0x00 (No unit mask) count 20000
samples  %        image name       app name                 symbol name
2469220  47.8872  vmlinux          vmlinux                  fib_find_info
576393   11.1784  vmlinux          vmlinux                  fn_trie_delete
559561   10.8519  vmlinux          vmlinux                  fn_trie_insert
518975   10.0648  vmlinux          vmlinux                  rt_run_flush
284646    5.5203  vmlinux          vmlinux                  local_bh_enable_ip
52469     1.0176  vmlinux          vmlinux                  local_bh_disable
47638     0.9239  vmlinux          vmlinux                  fib_nh_match
20588     0.3993  oprofiled        oprofiled                sfile_find
16074     0.3117  oprofiled        oprofiled                odb_update_node
13957     0.2707  ahci             ahci                     (no symbols)
13648     0.2647  vmlinux          vmlinux                  rtl8169_interrupt
13206     0.2561  vmlinux          vmlinux                  register_netdevice

After:

Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit 
mask of 0x00 (No unit mask) count 20000
512204   26.1316  vmlinux          vmlinux                  rt_run_flush
289378   14.7635  vmlinux          vmlinux                  local_bh_enable_ip
267266   13.6354  vmlinux          vmlinux                  fn_trie_delete
253438   12.9299  vmlinux          vmlinux                  fn_trie_insert
53329     2.7207  vmlinux          vmlinux                  local_bh_disable
21864     1.1155  vmlinux          vmlinux                  fib_nh_match
15105     0.7706  ahci             ahci                     (no symbols)
12332     0.6292  vmlinux          vmlinux                  rtl8169_interrupt
9504      0.4849  vmlinux          vmlinux                  ehci_irq
8436      0.4304  vmlinux          vmlinux                  journal_clean_one_cp_list
7645      0.3900  oprofiled        oprofiled                odb_update_node
7462      0.3807  oprofiled        oprofiled                sfile_find
6366      0.3248  babylond         babylond                 memset


Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3dad12e..e790842 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -197,11 +197,23 @@ static __inline__ int nh_comp(const struct fib_info *fi, const struct fib_info *
 	return 0;
 }
 
+static inline unsigned int fib_devindex_hashfn(unsigned int val)
+{
+	unsigned int mask = DEVINDEX_HASHSIZE - 1;
+
+	return (val ^
+		(val >> DEVINDEX_HASHBITS) ^
+		(val >> (DEVINDEX_HASHBITS * 2))) & mask;
+}
+
 static inline unsigned int fib_info_hashfn(const struct fib_info *fi)
 {
 	unsigned int mask = (fib_hash_size - 1);
 	unsigned int val = fi->fib_nhs;
 
+	if (val)
+		val ^= fib_devindex_hashfn(fi->fib_dev->ifindex);
+
 	val ^= fi->fib_protocol;
 	val ^= (__force u32)fi->fib_prefsrc;
 	val ^= fi->fib_priority;
@@ -235,15 +247,6 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
 	return NULL;
 }
 
-static inline unsigned int fib_devindex_hashfn(unsigned int val)
-{
-	unsigned int mask = DEVINDEX_HASHSIZE - 1;
-
-	return (val ^
-		(val >> DEVINDEX_HASHBITS) ^
-		(val >> (DEVINDEX_HASHBITS * 2))) & mask;
-}
-
 /* Check, that the gateway is already configured.
    Used only by redirect accept routine.
  */
