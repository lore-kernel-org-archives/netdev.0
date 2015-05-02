From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next v3 7/9] ipv6: Create RTF_CACHE clone when FLOWI_FLAG_KNOWN_NH is set
Date: Fri, 1 May 2015 17:26:56 -0700
Message-ID: <1430526418-3132761-8-git-send-email-kafai@fb.com>
References: <1430526418-3132761-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:2100 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751128AbbEBA2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 20:28:23 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t420RDAh015254
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 17:28:22 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u4djf8ues-5
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 17:28:22 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 21ce35ecf06211e49e7b0002c991e86a-9b7e01e0 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 17:28:19 -0700
In-Reply-To: <1430526418-3132761-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch always creates RTF_CACHE clone with DST_NOCACHE
when FLOWI_FLAG_KNOWN_NH is set so that the rt6i_dst is set to
the fl6->daddr.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip6_fib.h |  3 +++
 net/ipv6/route.c      | 59 ++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 52 insertions(+), 10 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index a4bece6..5556111 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -161,6 +161,9 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
 
 static inline u32 rt6_get_cookie(const struct rt6_info *rt)
 {
+	if (unlikely(rt->dst.flags & DST_NOCACHE))
+		rt = (struct rt6_info *)(rt->dst.from);
+
 	return rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b207eca..3302e73 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -901,13 +901,34 @@ redo_rt6_select:
 		}
 	}
 
-	dst_hold(&rt->dst);
+	dst_use(&rt->dst, jiffies);
 	read_unlock_bh(&table->tb6_lock);
 
-	rt6_dst_from_metrics_check(rt);
-	rt->dst.lastuse = jiffies;
-	rt->dst.__use++;
+	if (rt == net->ipv6.ip6_null_entry || (rt->rt6i_flags & RTF_CACHE)) {
+		goto done;
+	} else if (unlikely((fl6->flowi6_flags & FLOWI_FLAG_KNOWN_NH) &&
+			    !(rt->rt6i_flags & RTF_GATEWAY))) {
+		/* Create a RTF_CACHE clone which will not be
+		 * owned by the fib6 tree.  It is for the special case where
+		 * the daddr in the skb during the neighbor look-up is different
+		 * from the fl6->daddr used to look-up route here.
+		 */
+
+		struct rt6_info *uncached_rt;
+
+		uncached_rt = ip6_rt_cache_alloc(rt, &fl6->daddr, NULL);
+		dst_release(&rt->dst);
+
+		if (uncached_rt)
+			uncached_rt->dst.flags |= DST_NOCACHE;
+		else
+			uncached_rt = net->ipv6.ip6_null_entry;
+		dst_hold(&uncached_rt->dst);
+		return uncached_rt;
+	}
 
+done:
+	rt6_dst_from_metrics_check(rt);
 	return rt;
 }
 
@@ -1019,6 +1040,26 @@ static void rt6_dst_from_metrics_check(struct rt6_info *rt)
 		dst_init_metrics(&rt->dst, dst_metrics_ptr(rt->dst.from), true);
 }
 
+static struct dst_entry *rt6_check(struct rt6_info *rt, u32 cookie)
+{
+	if (!rt->rt6i_node || (rt->rt6i_node->fn_sernum != cookie))
+		return NULL;
+
+	if (rt6_check_expired(rt))
+		return NULL;
+
+	return &rt->dst;
+}
+
+static struct dst_entry *rt6_dst_from_check(struct rt6_info *rt, u32 cookie)
+{
+	if (rt->dst.obsolete == DST_OBSOLETE_FORCE_CHK &&
+	    rt6_check((struct rt6_info *)(rt->dst.from), cookie))
+		return &rt->dst;
+	else
+		return NULL;
+}
+
 static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 {
 	struct rt6_info *rt;
@@ -1029,15 +1070,13 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	 * DST_OBSOLETE_FORCE_CHK which forces validation calls down
 	 * into this function always.
 	 */
-	if (!rt->rt6i_node || (rt->rt6i_node->fn_sernum != cookie))
-		return NULL;
-
-	if (rt6_check_expired(rt))
-		return NULL;
 
 	rt6_dst_from_metrics_check(rt);
 
-	return dst;
+	if (unlikely(dst->flags & DST_NOCACHE))
+		return rt6_dst_from_check(rt, cookie);
+	else
+		return rt6_check(rt, cookie);
 }
 
 static struct dst_entry *ip6_negative_advice(struct dst_entry *dst)
-- 
1.8.1
