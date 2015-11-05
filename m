From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] decnet: remove macro-local declarations
Date: Thu,  5 Nov 2015 11:18:16 +0100
Message-ID: <1446718696-32505-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lkp@intel.com,
	roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:56908 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031089AbbKEK3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 05:29:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the variable declarations from the for_nexthops macro to the
surrounding context, so that it is clear where these variables are
declared.  This also makes it possible to remove the endfor_nexthops macro.

This change adds new arguments to the macro for_nexthops.  They are ordered
such that a pointer to the referenced object comes first, the index in the
list comes next, and the list itself comes last, roughly in analogy with
the list_for_each macros.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---

This patch takes care of a single file, where the macros are defined
locally.  If the basic transformation looks OK, I will change the other
files that either likewise define their own macros or use the macros in
net/mpls/internal.h.  The potentially affected files are:

net/decnet/dn_fib.c
net/ipv4/fib_semantics.c
net/mpls/af_mpls.c

 net/decnet/dn_table.c |   17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 1540b50..3e20dbb 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -60,11 +60,9 @@ struct dn_hash
 
 #define dz_key_0(key)		((key).datum = 0)
 
-#define for_nexthops(fi) { int nhsel; const struct dn_fib_nh *nh;\
+#define for_nexthops(nh, nhsel, fi) \
 	for(nhsel = 0, nh = (fi)->fib_nh; nhsel < (fi)->fib_nhs; nh++, nhsel++)
 
-#define endfor_nexthops(fi) }
-
 #define DN_MAX_DIVISOR 1024
 #define DN_S_ZOMBIE 1
 #define DN_S_ACCESSED 2
@@ -226,8 +224,9 @@ static struct dn_zone *dn_new_zone(struct dn_hash *table, int z)
 
 static int dn_fib_nh_match(struct rtmsg *r, struct nlmsghdr *nlh, struct nlattr *attrs[], struct dn_fib_info *fi)
 {
+	const struct dn_fib_nh *nh;
 	struct rtnexthop *nhp;
-	int nhlen;
+	int nhlen, nhsel;
 
 	if (attrs[RTA_PRIORITY] &&
 	    nla_get_u32(attrs[RTA_PRIORITY]) != fi->fib_priority)
@@ -246,7 +245,7 @@ static int dn_fib_nh_match(struct rtmsg *r, struct nlmsghdr *nlh, struct nlattr
 	nhp = nla_data(attrs[RTA_MULTIPATH]);
 	nhlen = nla_len(attrs[RTA_MULTIPATH]);
 
-	for_nexthops(fi) {
+	for_nexthops(nh, nhsel, fi) {
 		int attrlen = nhlen - sizeof(struct rtnexthop);
 		__le16 gw;
 
@@ -264,7 +263,7 @@ static int dn_fib_nh_match(struct rtmsg *r, struct nlmsghdr *nlh, struct nlattr
 				return 1;
 		}
 		nhp = RTNH_NEXT(nhp);
-	} endfor_nexthops(fi);
+	}
 
 	return 0;
 }
@@ -345,11 +344,13 @@ static int dn_fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	if (fi->fib_nhs > 1) {
 		struct rtnexthop *nhp;
 		struct nlattr *mp_head;
+		const struct dn_fib_nh *nh;
+		int nhsel;
 
 		if (!(mp_head = nla_nest_start(skb, RTA_MULTIPATH)))
 			goto errout;
 
-		for_nexthops(fi) {
+		for_nexthops(nh, nhsel, fi) {
 			if (!(nhp = nla_reserve_nohdr(skb, sizeof(*nhp))))
 				goto errout;
 
@@ -362,7 +363,7 @@ static int dn_fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 				goto errout;
 
 			nhp->rtnh_len = skb_tail_pointer(skb) - (unsigned char *)nhp;
-		} endfor_nexthops(fi);
+		}
 
 		nla_nest_end(skb, mp_head);
 	}
