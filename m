From: Michael Richardson <mcr@xelerance.com>
Subject: [PATCH 02/02] add mask options to fwmark masking code
Date: Mon, 20 Feb 2006 11:26:53 -0500
Message-ID: <23140.1140452813@sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org,
	netfilter-devel <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Jamal Hadi Salim <hadi@cyberus.ca>, kuznet@ms2.inr.ac.ru
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

--=-=-=


[PATCH] This patch introduces a mask to the fwmark test cases in the advanced
routing. This let's one test individual bits of the fwmark to determine
how things should be routed (pick a routing table). This patch retains
compatibility with tests that do not set the mask by assuming a mask
of 0 is equivalent to a mask of 0xffffffff.

Sign-off-by: Michael Richardson <mcr@xelerance.com>


---

 include/linux/rtnetlink.h |    1 +
 net/ipv4/fib_rules.c      |   19 +++++++++++++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

bcdda64a16d4dfda6d95452bbf8541999121831a
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 27fd17e..a5b55c2 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -266,6 +266,7 @@ enum rtattr_type_t
 };
 
 #define RTA_FWMARK      RTA_PROTOINFO
+#define RTA_FWMARK_MASK RTA_CACHEINFO
 
 #define RTA_MAX (__RTA_MAX - 1)
 
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index de327b3..69eed89 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -68,6 +68,7 @@ struct fib_rule
 	u8		r_tos;
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	u32		r_fwmark;
+        u32             r_fwmark_mask;
 #endif
 	int		r_ifindex;
 #ifdef CONFIG_NET_CLS_ROUTE
@@ -117,6 +118,7 @@ int inet_rtm_delrule(struct sk_buff *skb
 		    rtm->rtm_tos == r->r_tos &&
 #ifdef CONFIG_IP_ROUTE_FWMARK
 		    (!rta[RTA_FWMARK-1] || memcmp(RTA_DATA(rta[RTA_FWMARK-1]), &r->r_fwmark, 4) == 0) &&
+		    (!rta[RTA_FWMARK_MASK-1] || memcmp(RTA_DATA(rta[RTA_FWMARK_MASK-1]), &r->r_fwmark_mask, 4) == 0) &&
 #endif
 		    (!rtm->rtm_type || rtm->rtm_type == r->r_action) &&
 		    (!rta[RTA_PRIORITY-1] || memcmp(RTA_DATA(rta[RTA_PRIORITY-1]), &r->r_preference, 4) == 0) &&
@@ -202,6 +204,17 @@ int inet_rtm_newrule(struct sk_buff *skb
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	if (rta[RTA_FWMARK-1]) 
 		memcpy(&new_r->r_fwmark,      RTA_DATA(rta[RTA_FWMARK-1]), 4);
+	if (rta[RTA_FWMARK_MASK-1]) 
+		memcpy(&new_r->r_fwmark_mask, RTA_DATA(rta[RTA_FWMARK_MASK-1]), 4);
+	/*
+	 * if the user doesn't set a mask, then set it to care about
+	 * all bits. This retains compatibility. Note it is impossible
+	 * to match SOMETHING & 0xMASK == 0, because fwmark==0 means
+	 * do not match fwmark at all.
+	 */
+	if(new_r->r_fwmark_mask == 0) {
+		new_r->r_fwmark_mask = 0xffffffff;
+	}
 #endif
 	new_r->r_action = rtm->rtm_type;
 	new_r->r_flags = rtm->rtm_flags;
@@ -298,7 +311,7 @@ FRprintk("Lookup: %u.%u.%u.%u <- %u.%u.%
 		    ((daddr^r->r_dst) & r->r_dstmask) ||
 		    (r->r_tos && r->r_tos != flp->fl4_tos) ||
 #ifdef CONFIG_IP_ROUTE_FWMARK
-		    (r->r_fwmark && r->r_fwmark != flp->fl4_fwmark) ||
+		    (r->r_fwmark && r->r_fwmark != (flp->fl4_fwmark & r->r_fwmark_mask)) ||
 #endif
 		    (r->r_ifindex && r->r_ifindex != flp->iif))
 			continue;
@@ -382,8 +395,10 @@ static __inline__ int inet_fill_rule(str
 	rtm->rtm_src_len = r->r_src_len;
 	rtm->rtm_tos = r->r_tos;
 #ifdef CONFIG_IP_ROUTE_FWMARK
-	if (r->r_fwmark) 
+	if (r->r_fwmark) {
 		RTA_PUT(skb, RTA_FWMARK, 4, &r->r_fwmark);
+		RTA_PUT(skb, RTA_FWMARK_MASK, 4, &r->r_fwmark_mask);
+	}
 #endif
 	rtm->rtm_table = r->r_table;
 	rtm->rtm_protocol = 0;
-- 





--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iQEVAwUAQ/ntzYCLcPvd0N1lAQLqbAf/d0ZoX70OFZNAqK3fukKOZbuZ7f3Skni2
FFSsn4FYbHuyjZqIbR1ZNaPh+Wi1Z6ATZV5fYe8NWYFLsMk9xrEuWfMzade7pK7U
CFszPqiYdlAsehfa55WPWQ7GV9FEEeQHsOZy3i+os1m4dUFcHS3dTim1CPzzLo6X
0sgHz+G0aocSUr2KgwSpAQJtyHmrsC7k/1NB69rbKThJhccYw8ec3cjP1+7sD+hX
+3NIKkALYxiKEjYR9pH0bXFJVqxUrRqPSNv7rdVr5zcP5b4egS6mNXGQkIddRqLv
YF3dGmwIg8KgObX8hay++8wOO2f4t2ql+vrCH41fypw82apnuF9fng==
=1XFm
-----END PGP SIGNATURE-----
--=-=-=--
