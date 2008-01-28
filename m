From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6.25] [IPV6] ADDRLABEL: Fix double free on label
 deletion.
Date: Mon, 28 Jan 2008 21:02:22 +0900 (JST)
Message-ID: <20080128.210222.07062540.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, mitch@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39650 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019AbYA1MCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 07:02:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an entry is being deleted because it has only one reference, 
we immediately delete it and blindly register the rcu handler for it,
This results in oops by double freeing that object.

This patch fixes it by consolidating the code paths for the deletion;
let its rcu handler delete the object if it has no more reference.

Bug was found by Mitsuru Chinen <mitch@linux.vnet.ibm.com>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 6f1ca60..7a706c4 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -106,6 +106,11 @@ static inline void ip6addrlbl_free(struct ip6addrlbl_entry *p)
 	kfree(p);
 }
 
+static void ip6addrlbl_free_rcu(struct rcu_head *h)
+{
+	ip6addrlbl_free(container_of(h, struct ip6addrlbl_entry, rcu));
+}
+
 static inline int ip6addrlbl_hold(struct ip6addrlbl_entry *p)
 {
 	return atomic_inc_not_zero(&p->refcnt);
@@ -114,12 +119,7 @@ static inline int ip6addrlbl_hold(struct ip6addrlbl_entry *p)
 static inline void ip6addrlbl_put(struct ip6addrlbl_entry *p)
 {
 	if (atomic_dec_and_test(&p->refcnt))
-		ip6addrlbl_free(p);
-}
-
-static void ip6addrlbl_free_rcu(struct rcu_head *h)
-{
-	ip6addrlbl_free(container_of(h, struct ip6addrlbl_entry, rcu));
+		call_rcu(&p->rcu, ip6addrlbl_free_rcu);
 }
 
 /* Find label */
@@ -240,7 +240,6 @@ int __ip6addrlbl_add(struct ip6addrlbl_entry *newp, int replace)
 				}
 				hlist_replace_rcu(&p->list, &newp->list);
 				ip6addrlbl_put(p);
-				call_rcu(&p->rcu, ip6addrlbl_free_rcu);
 				goto out;
 			} else if ((p->prefixlen == newp->prefixlen && !p->ifindex) ||
 				   (p->prefixlen < newp->prefixlen)) {
@@ -300,7 +299,6 @@ int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
 		    ipv6_addr_equal(&p->prefix, prefix)) {
 			hlist_del_rcu(&p->list);
 			ip6addrlbl_put(p);
-			call_rcu(&p->rcu, ip6addrlbl_free_rcu);
 			ret = 0;
 			break;
 		}

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
