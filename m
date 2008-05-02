From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 6/6] net: use get/put_unaligned_* helpers
Date: Thu, 01 May 2008 22:19:34 -0700
Message-ID: <1209705574.22362.43.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:55872 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756768AbYEBFTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 01:19:22 -0400
Received: by py-out-1112.google.com with SMTP id u52so2047921pyb.10
        for <netdev@vger.kernel.org>; Thu, 01 May 2008 22:19:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 net/bridge/br_stp_bpdu.c |    4 ++--
 net/core/filter.c        |    4 ++--
 net/ipv4/cipso_ipv4.c    |   18 ++++++++----------
 net/ipv4/tcp_input.c     |   18 +++++++++---------
 4 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 8deab64..ddeb6e5 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -58,12 +58,12 @@ static inline void br_set_ticks(unsigned char *dest, int j)
 {
 	unsigned long ticks = (STP_HZ * j)/ HZ;
 
-	put_unaligned(htons(ticks), (__be16 *)dest);
+	put_unaligned_be16(ticks, dest);
 }
 
 static inline int br_get_ticks(const unsigned char *src)
 {
-	unsigned long ticks = ntohs(get_unaligned((__be16 *)src));
+	unsigned long ticks = get_unaligned_be16(src);
 
 	return DIV_ROUND_UP(ticks * HZ, STP_HZ);
 }
diff --git a/net/core/filter.c b/net/core/filter.c
index f5f3cf6..4f83697 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -213,7 +213,7 @@ unsigned int sk_run_filter(struct sk_buff *skb, struct sock_filter *filter, int
 load_w:
 			ptr = load_pointer(skb, k, 4, &tmp);
 			if (ptr != NULL) {
-				A = ntohl(get_unaligned((__be32 *)ptr));
+				A = get_unaligned_be32(ptr);
 				continue;
 			}
 			break;
@@ -222,7 +222,7 @@ load_w:
 load_h:
 			ptr = load_pointer(skb, k, 2, &tmp);
 			if (ptr != NULL) {
-				A = ntohs(get_unaligned((__be16 *)ptr));
+				A = get_unaligned_be16(ptr);
 				continue;
 			}
 			break;
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 4637ded..05afb57 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -983,7 +983,7 @@ static int cipso_v4_map_cat_enum_valid(const struct cipso_v4_doi *doi_def,
 		return -EFAULT;
 
 	for (iter = 0; iter < enumcat_len; iter += 2) {
-		cat = ntohs(get_unaligned((__be16 *)&enumcat[iter]));
+		cat = get_unaligned_be16(&enumcat[iter]);
 		if (cat <= cat_prev)
 			return -EFAULT;
 		cat_prev = cat;
@@ -1052,7 +1052,7 @@ static int cipso_v4_map_cat_enum_ntoh(const struct cipso_v4_doi *doi_def,
 
 	for (iter = 0; iter < net_cat_len; iter += 2) {
 		ret_val = netlbl_secattr_catmap_setbit(secattr->attr.mls.cat,
-				ntohs(get_unaligned((__be16 *)&net_cat[iter])),
+				get_unaligned_be16(&net_cat[iter]),
 				GFP_ATOMIC);
 		if (ret_val != 0)
 			return ret_val;
@@ -1086,10 +1086,9 @@ static int cipso_v4_map_cat_rng_valid(const struct cipso_v4_doi *doi_def,
 		return -EFAULT;
 
 	for (iter = 0; iter < rngcat_len; iter += 4) {
-		cat_high = ntohs(get_unaligned((__be16 *)&rngcat[iter]));
+		cat_high = get_unaligned_be16(&rngcat[iter]);
 		if ((iter + 4) <= rngcat_len)
-			cat_low = ntohs(
-				get_unaligned((__be16 *)&rngcat[iter + 2]));
+			cat_low = get_unaligned_be16(&rngcat[iter + 2]);
 		else
 			cat_low = 0;
 
@@ -1188,10 +1187,9 @@ static int cipso_v4_map_cat_rng_ntoh(const struct cipso_v4_doi *doi_def,
 	u16 cat_high;
 
 	for (net_iter = 0; net_iter < net_cat_len; net_iter += 4) {
-		cat_high = ntohs(get_unaligned((__be16 *)&net_cat[net_iter]));
+		cat_high = get_unaligned_be16(&net_cat[net_iter]);
 		if ((net_iter + 4) <= net_cat_len)
-			cat_low = ntohs(
-			      get_unaligned((__be16 *)&net_cat[net_iter + 2]));
+			cat_low = get_unaligned_be16(&net_cat[net_iter + 2]);
 		else
 			cat_low = 0;
 
@@ -1562,7 +1560,7 @@ int cipso_v4_validate(unsigned char **option)
 	}
 
 	rcu_read_lock();
-	doi_def = cipso_v4_doi_search(ntohl(get_unaligned((__be32 *)&opt[2])));
+	doi_def = cipso_v4_doi_search(get_unaligned_be32(&opt[2]));
 	if (doi_def == NULL) {
 		err_offset = 2;
 		goto validate_return_locked;
@@ -1843,7 +1841,7 @@ static int cipso_v4_getattr(const unsigned char *cipso,
 	if (cipso_v4_cache_check(cipso, cipso[1], secattr) == 0)
 		return 0;
 
-	doi = ntohl(get_unaligned((__be32 *)&cipso[2]));
+	doi = get_unaligned_be32(&cipso[2]);
 	rcu_read_lock();
 	doi_def = cipso_v4_doi_search(doi);
 	if (doi_def == NULL)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0298f80..eda4f4a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1172,8 +1172,8 @@ static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_skb,
 			   struct tcp_sack_block_wire *sp, int num_sacks,
 			   u32 prior_snd_una)
 {
-	u32 start_seq_0 = ntohl(get_unaligned(&sp[0].start_seq));
-	u32 end_seq_0 = ntohl(get_unaligned(&sp[0].end_seq));
+	u32 start_seq_0 = get_unaligned_be32(&sp[0].start_seq);
+	u32 end_seq_0 = get_unaligned_be32(&sp[0].end_seq);
 	int dup_sack = 0;
 
 	if (before(start_seq_0, TCP_SKB_CB(ack_skb)->ack_seq)) {
@@ -1181,8 +1181,8 @@ static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_skb,
 		tcp_dsack_seen(tp);
 		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
 	} else if (num_sacks > 1) {
-		u32 end_seq_1 = ntohl(get_unaligned(&sp[1].end_seq));
-		u32 start_seq_1 = ntohl(get_unaligned(&sp[1].start_seq));
+		u32 end_seq_1 = get_unaligned_be32(&sp[1].end_seq);
+		u32 start_seq_1 = get_unaligned_be32(&sp[1].start_seq);
 
 		if (!after(end_seq_0, end_seq_1) &&
 		    !before(start_seq_0, start_seq_1)) {
@@ -1453,8 +1453,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 	for (i = 0; i < num_sacks; i++) {
 		int dup_sack = !i && found_dup_sack;
 
-		sp[used_sacks].start_seq = ntohl(get_unaligned(&sp_wire[i].start_seq));
-		sp[used_sacks].end_seq = ntohl(get_unaligned(&sp_wire[i].end_seq));
+		sp[used_sacks].start_seq = get_unaligned_be32(&sp_wire[i].start_seq);
+		sp[used_sacks].end_seq = get_unaligned_be32(&sp_wire[i].end_seq);
 
 		if (!tcp_is_sackblock_valid(tp, dup_sack,
 					    sp[used_sacks].start_seq,
@@ -3340,7 +3340,7 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 			switch (opcode) {
 			case TCPOPT_MSS:
 				if (opsize == TCPOLEN_MSS && th->syn && !estab) {
-					u16 in_mss = ntohs(get_unaligned((__be16 *)ptr));
+					u16 in_mss = get_unaligned_be16(ptr);
 					if (in_mss) {
 						if (opt_rx->user_mss &&
 						    opt_rx->user_mss < in_mss)
@@ -3369,8 +3369,8 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 				    ((estab && opt_rx->tstamp_ok) ||
 				     (!estab && sysctl_tcp_timestamps))) {
 					opt_rx->saw_tstamp = 1;
-					opt_rx->rcv_tsval = ntohl(get_unaligned((__be32 *)ptr));
-					opt_rx->rcv_tsecr = ntohl(get_unaligned((__be32 *)(ptr+4)));
+					opt_rx->rcv_tsval = get_unaligned_be32(ptr);
+					opt_rx->rcv_tsecr = get_unaligned_be32(ptr + 4);
 				}
 				break;
 			case TCPOPT_SACK_PERM:
-- 
1.5.5.1.350.gbbbf

