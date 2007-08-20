From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 3/4 - rev 2] Initilize and populate age field
Date: Mon, 20 Aug 2007 13:46:17 +0530
Message-ID: <20070820134617.1226c97b.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com,
	varuncha@in.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:38351 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbXHTIPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 04:15:43 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7K8FgIW007054
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 04:15:42 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7K8Fgrw262672
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 02:15:42 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7K8FfDd003585
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 02:15:42 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The age field is filled with the current time at the time of creation of the route. When the routes are dumped
then the age value stored in the route structure is subtracted from the current time value and the difference is the age expressed in secs.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 net/ipv4/fib_hash.c      |    3 +++
 net/ipv4/fib_lookup.h    |    3 ++-
 net/ipv4/fib_semantics.c |   16 +++++++++++++---
 net/ipv4/fib_trie.c      |    1 +
 4 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 9ad1d9f..228ab27 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -448,6 +448,7 @@ static int fn_hash_insert(struct fib_tab
 			fa->fa_info = fi;
 			fa->fa_type = cfg->fc_type;
 			fa->fa_scope = cfg->fc_scope;
+			fa->fa_age = 0;
 			state = fa->fa_state;
 			fa->fa_state &= ~FA_S_ACCESSED;
 			fib_hash_genid++;
@@ -507,6 +508,7 @@ static int fn_hash_insert(struct fib_tab
 	new_fa->fa_type = cfg->fc_type;
 	new_fa->fa_scope = cfg->fc_scope;
 	new_fa->fa_state = 0;
+	new_fa->fa_age = 0;
 
 	/*
 	 * Insert new entry to the list.
@@ -697,6 +699,7 @@ fn_hash_dump_bucket(struct sk_buff *skb,
 					  f->fn_key,
 					  fz->fz_order,
 					  fa->fa_tos,
+					  &fa->fa_age,
 					  fa->fa_info,
 					  NLM_F_MULTI) < 0) {
 				cb->args[4] = i;
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index eef9eec..c9145b5 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -13,6 +13,7 @@ struct fib_alias {
 	u8			fa_type;
 	u8			fa_scope;
 	u8			fa_state;
+	time_t			fa_age;
 };
 
 #define FA_S_ACCESSED	0x01
@@ -27,7 +28,7 @@ extern struct fib_info *fib_create_info(
 extern int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
 extern int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 			 u32 tb_id, u8 type, u8 scope, __be32 dst,
-			 int dst_len, u8 tos, struct fib_info *fi,
+			 int dst_len, u8 tos, time_t *age, struct fib_info *fi,
 			 unsigned int);
 extern void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
 		      int dst_len, u32 tb_id, struct nl_info *info,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index c434119..1822d92 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -278,7 +278,8 @@ static inline size_t fib_nlmsg_size(stru
 			 + nla_total_size(4) /* RTA_TABLE */
 			 + nla_total_size(4) /* RTA_DST */
 			 + nla_total_size(4) /* RTA_PRIORITY */
-			 + nla_total_size(4); /* RTA_PREFSRC */
+			 + nla_total_size(4) /* RTA_PREFSRC */
+			 + nla_total_size(4); /*RTA_AGE*/
 
 	/* space for nested metrics */
 	payload += nla_total_size((RTAX_MAX * nla_total_size(4)));
@@ -313,7 +314,7 @@ void rtmsg_fib(int event, __be32 key, st
 
 	err = fib_dump_info(skb, info->pid, seq, event, tb_id,
 			    fa->fa_type, fa->fa_scope, key, dst_len,
-			    fa->fa_tos, fa->fa_info, nlm_flags);
+			    fa->fa_tos, &fa->fa_age, fa->fa_info, nlm_flags);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in fib_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -940,11 +941,12 @@ __be32 __fib_res_prefsrc(struct fib_resu
 }
 
 int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-		  u32 tb_id, u8 type, u8 scope, __be32 dst, int dst_len, u8 tos,
+		  u32 tb_id, u8 type, u8 scope, __be32 dst, int dst_len, u8 tos, time_t *age,
 		  struct fib_info *fi, unsigned int flags)
 {
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
+	struct timeval tv;
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*rtm), flags);
 	if (nlh == NULL)
@@ -985,6 +987,14 @@ int fib_dump_info(struct sk_buff *skb, u
 			NLA_PUT_U32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid);
 #endif
 	}
+
+	do_gettimeofday(&tv);
+	if (!*age) {
+		*age = timeval_to_sec(&tv);
+		NLA_PUT_U32(skb, RTA_AGE, *age);
+	} else {
+		NLA_PUT_U32(skb, RTA_AGE, timeval_to_sec(&tv) - *age);
+	}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (fi->fib_nhs > 1) {
 		struct rtnexthop *rtnh;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 52b2891..82a8bac 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1892,6 +1892,7 @@ static int fn_trie_dump_fa(t_key key, in
 				  xkey,
 				  plen,
 				  fa->fa_tos,
+				  &fa->fa_age,
 				  fa->fa_info, 0) < 0) {
 			cb->args[4] = i;
 			return -1;
-- 
1.4.3.4

