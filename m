From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 11/10]: [NETFILTER]: Export ip6_masked_addrcmp, don't pass
 IPv6 addresses on stack
Date: Fri, 11 Nov 2005 06:25:38 +0100
Message-ID: <43742B52.6060905@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060803050306050803020902"
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
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

This is a multi-part message in MIME format.
--------------060803050306050803020902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

For completeness, the next two patches contain the policy match.

--------------060803050306050803020902
Content-Type: text/x-patch;
 name="11.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="11.diff"

[NETFILTER]: Export ip6_masked_addrcmp, don't pass IPv6 addresses on stack

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f12c4452cdb1b7d0d33a00120145e301507458e4
tree 4762d9addca1746390024fcf437c73759b90955c
parent 5365555b302ffc8a31170833ca33636e9e66ff9a
author Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 06:14:09 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 06:14:09 +0100

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

--------------060803050306050803020902--
