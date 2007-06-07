From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH 2/2] fix several unaligned kernel accesses in the CIPSO engine
Date: Thu, 07 Jun 2007 11:32:28 -0400
Message-ID: <20070607153610.888828690@hp.com>
References: <20070607153226.524778346@hp.com>
Cc: Paul Moore <paul.moore@hp.com>
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:49980 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760090AbXFGPgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 11:36:47 -0400
Content-Disposition: inline; filename=cipso-unaligned_fix
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPv4 options are not very well aligned within the packet and the format of a
CIPSO option is even worse.  The result is that the CIPSO engine in the kernel
does a few unaligned accesses when parsing and validating incoming packets with
CIPSO options attached which generate error messages on certain alignment
sensitive platforms.  This patch fixes this by marking these unaligned accesses
with the get_unaliagned() macro.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/ipv4/cipso_ipv4.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

Index: net-2.6_cleanup/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6_cleanup.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6_cleanup/net/ipv4/cipso_ipv4.c
@@ -45,6 +45,7 @@
 #include <net/cipso_ipv4.h>
 #include <asm/atomic.h>
 #include <asm/bug.h>
+#include <asm/unaligned.h>
 
 struct cipso_v4_domhsh_entry {
 	char *domain;
@@ -1000,7 +1001,7 @@ static int cipso_v4_map_cat_enum_valid(c
 		return -EFAULT;
 
 	for (iter = 0; iter < enumcat_len; iter += 2) {
-		cat = ntohs(*((__be16 *)&enumcat[iter]));
+		cat = ntohs(get_unaligned((__be16 *)&enumcat[iter]));
 		if (cat <= cat_prev)
 			return -EFAULT;
 		cat_prev = cat;
@@ -1068,8 +1069,8 @@ static int cipso_v4_map_cat_enum_ntoh(co
 
 	for (iter = 0; iter < net_cat_len; iter += 2) {
 		ret_val = netlbl_secattr_catmap_setbit(secattr->mls_cat,
-					    ntohs(*((__be16 *)&net_cat[iter])),
-					    GFP_ATOMIC);
+				ntohs(get_unaligned((__be16 *)&net_cat[iter])),
+				GFP_ATOMIC);
 		if (ret_val != 0)
 			return ret_val;
 	}
@@ -1102,9 +1103,10 @@ static int cipso_v4_map_cat_rng_valid(co
 		return -EFAULT;
 
 	for (iter = 0; iter < rngcat_len; iter += 4) {
-		cat_high = ntohs(*((__be16 *)&rngcat[iter]));
+		cat_high = ntohs(get_unaligned((__be16 *)&rngcat[iter]));
 		if ((iter + 4) <= rngcat_len)
-			cat_low = ntohs(*((__be16 *)&rngcat[iter + 2]));
+			cat_low = ntohs(
+				get_unaligned((__be16 *)&rngcat[iter + 2]));
 		else
 			cat_low = 0;
 
@@ -1201,9 +1203,10 @@ static int cipso_v4_map_cat_rng_ntoh(con
 	u16 cat_high;
 
 	for (net_iter = 0; net_iter < net_cat_len; net_iter += 4) {
-		cat_high = ntohs(*((__be16 *)&net_cat[net_iter]));
+		cat_high = ntohs(get_unaligned((__be16 *)&net_cat[net_iter]));
 		if ((net_iter + 4) <= net_cat_len)
-			cat_low = ntohs(*((__be16 *)&net_cat[net_iter + 2]));
+			cat_low = ntohs(
+			      get_unaligned((__be16 *)&net_cat[net_iter + 2]));
 		else
 			cat_low = 0;
 
@@ -1565,7 +1568,7 @@ int cipso_v4_validate(unsigned char **op
 	}
 
 	rcu_read_lock();
-	doi_def = cipso_v4_doi_search(ntohl(*((__be32 *)&opt[2])));
+	doi_def = cipso_v4_doi_search(ntohl(get_unaligned((__be32 *)&opt[2])));
 	if (doi_def == NULL) {
 		err_offset = 2;
 		goto validate_return_locked;
@@ -1856,7 +1859,7 @@ int cipso_v4_sock_getattr(struct sock *s
 	if (ret_val == 0)
 		return ret_val;
 
-	doi = ntohl(*(__be32 *)&cipso_ptr[2]);
+	doi = ntohl(get_unaligned((__be32 *)&cipso_ptr[2]));
 	rcu_read_lock();
 	doi_def = cipso_v4_doi_search(doi);
 	if (doi_def == NULL) {
@@ -1911,7 +1914,7 @@ int cipso_v4_skbuff_getattr(const struct
 	if (cipso_v4_cache_check(cipso_ptr, cipso_ptr[1], secattr) == 0)
 		return 0;
 
-	doi = ntohl(*(__be32 *)&cipso_ptr[2]);
+	doi = ntohl(get_unaligned((__be32 *)&cipso_ptr[2]));
 	rcu_read_lock();
 	doi_def = cipso_v4_doi_search(doi);
 	if (doi_def == NULL)

-- 
paul moore
linux security @ hp
