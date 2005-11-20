From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 12/13]: [NETFILTER]: Export ip6_masked_addrcmp,
	don't pass IPv6 addresses on stack
Date: Sun, 20 Nov 2005 17:31:43 +0100
Message-ID: <20051120163143.16666.34704.sendpatchset@localhost.localdomain>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Export ip6_masked_addrcmp, don't pass IPv6 addresses on stack

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 055c50b770e63ced784808ae22ef339724b1a44c
tree b8dc07727bb80b83c5b236f4157ed588927f46da
parent 8b46eb2d8365ab18cc965f37681033162a834fe5
author Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 22:09:28 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 22:09:28 +0100

 include/linux/netfilter_ipv6/ip6_tables.h |    4 ++++
 net/ipv6/netfilter/ip6_tables.c           |   18 ++++++++++--------
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index 2efc046..1e11010 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -476,6 +476,10 @@ extern int ip6t_ext_hdr(u8 nexthdr);
 extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 			 u8 target);
 
+extern int ip6_masked_addrcmp(const struct in6_addr *addr1,
+			      const struct in6_addr *mask,
+			      const struct in6_addr *addr2);
+
 #define IP6T_ALIGN(s) (((s) + (__alignof__(struct ip6t_entry)-1)) & ~(__alignof__(struct ip6t_entry)-1))
 
 #endif /*__KERNEL__*/
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 7d49222..71a80e0 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -128,13 +128,14 @@ static LIST_HEAD(ip6t_tables);
 #define up(x) do { printk("UP:%u:" #x "\n", __LINE__); up(x); } while(0)
 #endif
 
-static int ip6_masked_addrcmp(struct in6_addr addr1, struct in6_addr mask,
-			      struct in6_addr addr2)
+int
+ip6_masked_addrcmp(const struct in6_addr *addr1, const struct in6_addr *mask,
+                   const struct in6_addr *addr2)
 {
 	int i;
 	for( i = 0; i < 16; i++){
-		if((addr1.s6_addr[i] & mask.s6_addr[i]) != 
-		   (addr2.s6_addr[i] & mask.s6_addr[i]))
+		if((addr1->s6_addr[i] & mask->s6_addr[i]) != 
+		   (addr2->s6_addr[i] & mask->s6_addr[i]))
 			return 1;
 	}
 	return 0;
@@ -168,10 +169,10 @@ ip6_packet_match(const struct sk_buff *s
 
 #define FWINV(bool,invflg) ((bool) ^ !!(ip6info->invflags & invflg))
 
-	if (FWINV(ip6_masked_addrcmp(ipv6->saddr,ip6info->smsk,ip6info->src),
-		  IP6T_INV_SRCIP)
-	    || FWINV(ip6_masked_addrcmp(ipv6->daddr,ip6info->dmsk,ip6info->dst),
-		     IP6T_INV_DSTIP)) {
+	if (FWINV(ip6_masked_addrcmp(&ipv6->saddr, &ip6info->smsk,
+	                             &ip6info->src), IP6T_INV_SRCIP)
+	    || FWINV(ip6_masked_addrcmp(&ipv6->daddr, &ip6info->dmsk,
+	                                &ip6info->dst), IP6T_INV_DSTIP)) {
 		dprintf("Source or dest mismatch.\n");
 /*
 		dprintf("SRC: %u. Mask: %u. Target: %u.%s\n", ip->saddr,
@@ -2094,6 +2095,7 @@ EXPORT_SYMBOL(ip6t_register_target);
 EXPORT_SYMBOL(ip6t_unregister_target);
 EXPORT_SYMBOL(ip6t_ext_hdr);
 EXPORT_SYMBOL(ipv6_find_hdr);
+EXPORT_SYMBOL(ip6_masked_addrcmp);
 
 module_init(init);
 module_exit(fini);
