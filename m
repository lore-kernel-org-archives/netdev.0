From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next] net: fix sparse warnings in SNMP_UPD_PO_STATS(_BH)
Date: Wed, 17 Sep 2014 23:23:12 +0200
Message-ID: <20140917212312.GA13866@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:47563 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756521AbaIQVXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2014 17:23:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ptr used to be a non __percpu pointer (result of a this_cpu_ptr
assignment, 7d720c3e4f0c4 ("percpu: add __percpu sparse annotations to
net")). Since d25398df59b56 ("net: avoid reloads in SNMP_UPD_PO_STATS"),
that's no longer the case, SNMP_UPD_PO_STATS uses this_cpu_add and ptr
is now __percpu.

Silence sparse warnings by preserving the original type and
annotation, and remove the out-of-date comment.

warning: incorrect type in initializer (different address spaces)
   expected unsigned long long *ptr
   got unsigned long long [noderef] <asn:3>*<noident>
warning: incorrect type in initializer (different address spaces)
   expected void const [noderef] <asn:3>*__vpp_verify
   got unsigned long long *<noident>
warning: incorrect type in initializer (different address spaces)
   expected void const [noderef] <asn:3>*__vpp_verify
   got unsigned long long *<noident>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 include/net/snmp.h | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/net/snmp.h b/include/net/snmp.h
index f1f27fdbb0d5..8fd2f498782e 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -146,19 +146,15 @@ struct linux_xfrm_mib {
 
 #define SNMP_ADD_STATS(mib, field, addend)	\
 			this_cpu_add(mib->mibs[field], addend)
-/*
- * Use "__typeof__(*mib) *ptr" instead of "__typeof__(mib) ptr"
- * to make @ptr a non-percpu pointer.
- */
 #define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
 	do { \
-		__typeof__(*mib->mibs) *ptr = mib->mibs;	\
+		__typeof__((mib->mibs) + 0) ptr = mib->mibs;	\
 		this_cpu_inc(ptr[basefield##PKTS]);		\
 		this_cpu_add(ptr[basefield##OCTETS], addend);	\
 	} while (0)
 #define SNMP_UPD_PO_STATS_BH(mib, basefield, addend)	\
 	do { \
-		__typeof__(*mib->mibs) *ptr = mib->mibs;	\
+		__typeof__((mib->mibs) + 0) ptr = mib->mibs;	\
 		__this_cpu_inc(ptr[basefield##PKTS]);		\
 		__this_cpu_add(ptr[basefield##OCTETS], addend);	\
 	} while (0)
-- 
2.1.0
