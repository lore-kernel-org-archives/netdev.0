From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.12-rc1-bk1] multipath: early use of inlined function
Date: Mon, 21 Mar 2005 22:34:09 +0100
Message-ID: <20050321213409.GA28998@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Early use of inlined function

$ grep -n compare_keys net/ipv4/route.c
151:static inline int compare_keys(struct flowi *fl1, struct flowi *fl2);
                                                                       ^^^
541:                compare_keys(&(*rthp)->fl, &expentry->fl)) {
861:static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
890:                compare_keys(&rth->fl, &rt->fl)) {
892:            if (compare_keys(&rth->fl, &rt->fl)) {

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN net/ipv4/route.c~netdev-10 net/ipv4/route.c
--- linux-2.6.12-rcX/net/ipv4/route.c~netdev-10	2005-03-21 22:24:16.639836385 +0100
+++ linux-2.6.12-rcX-fr/net/ipv4/route.c	2005-03-21 22:30:05.904038902 +0100
@@ -148,7 +148,6 @@ static struct dst_entry *ipv4_negative_a
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 static int rt_garbage_collect(void);
-static inline int compare_keys(struct flowi *fl1, struct flowi *fl2);
 
 
 static struct dst_ops ipv4_dst_ops = {
@@ -520,6 +519,13 @@ static inline u32 rt_score(struct rtable
 	return score;
 }
 
+static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
+{
+	return memcmp(&fl1->nl_u.ip4_u, &fl2->nl_u.ip4_u, sizeof(fl1->nl_u.ip4_u)) == 0 &&
+	       fl1->oif     == fl2->oif &&
+	       fl1->iif     == fl2->iif;
+}
+
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 static struct rtable **rt_remove_balanced_route(struct rtable **chain_head,
 						struct rtable *expentry,
@@ -858,13 +864,6 @@ work_done:
 out:	return 0;
 }
 
-static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
-{
-	return memcmp(&fl1->nl_u.ip4_u, &fl2->nl_u.ip4_u, sizeof(fl1->nl_u.ip4_u)) == 0 &&
-	       fl1->oif     == fl2->oif &&
-	       fl1->iif     == fl2->iif;
-}
-
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
 {
 	struct rtable	*rth, **rthp;

_
