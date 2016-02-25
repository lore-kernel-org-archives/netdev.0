From: Deepa Dinamani <deepa.kernel@gmail.com>
Subject: [PATCH 2/4] net: ipv4: Use y2038 safe functions and data structures
Date: Wed, 24 Feb 2016 23:07:09 -0800
Message-ID: <1456384031-29244-3-git-send-email-deepa.kernel@gmail.com>
References: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com>
Cc: arnd@arndb.de, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org, y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35710 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759377AbcBYHJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 02:09:20 -0500
Received: by mail-pf0-f194.google.com with SMTP id w128so2336199pfb.2
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 23:09:20 -0800 (PST)
In-Reply-To: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ICMP timestamp messages and IP source route options require
timestamps to be in milliseconds modulo 24 hours from
midnight UT format.

Timestamps are calculated from realtime by making a call
to getnstimeofday() which uses struct timespec.
timespec is not y2038 safe.
Replace the above calls with y2038 safe current_nw_time() to
obtain network timestamps which uses y2038 safe struct timespec64.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/icmp.c       |  5 +----
 net/ipv4/ip_options.c | 13 +++++--------
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 36e2697..e43dfa3 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -931,7 +931,6 @@ static bool icmp_echo(struct sk_buff *skb)
  */
 static bool icmp_timestamp(struct sk_buff *skb)
 {
-	struct timespec tv;
 	struct icmp_bxm icmp_param;
 	/*
 	 *	Too short.
@@ -942,9 +941,7 @@ static bool icmp_timestamp(struct sk_buff *skb)
 	/*
 	 *	Fill in the current time as ms since midnight UT:
 	 */
-	getnstimeofday(&tv);
-	icmp_param.data.times[1] = htonl((tv.tv_sec % 86400) * MSEC_PER_SEC +
-					 tv.tv_nsec / NSEC_PER_MSEC);
+	icmp_param.data.times[1] = current_nw_timestamp();
 	icmp_param.data.times[2] = icmp_param.data.times[1];
 	if (skb_copy_bits(skb, 0, &icmp_param.data.times[0], 4))
 		BUG();
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index bd24679..6958e7c 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -58,10 +58,8 @@ void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
 		if (opt->ts_needaddr)
 			ip_rt_get_source(iph+opt->ts+iph[opt->ts+2]-9, skb, rt);
 		if (opt->ts_needtime) {
-			struct timespec tv;
 			__be32 midtime;
-			getnstimeofday(&tv);
-			midtime = htonl((tv.tv_sec % 86400) * MSEC_PER_SEC + tv.tv_nsec / NSEC_PER_MSEC);
+			midtime = current_nw_timestamp();
 			memcpy(iph+opt->ts+iph[opt->ts+2]-5, &midtime, 4);
 		}
 		return;
@@ -415,11 +413,10 @@ int ip_options_compile(struct net *net,
 					break;
 				}
 				if (timeptr) {
-					struct timespec tv;
-					u32  midtime;
-					getnstimeofday(&tv);
-					midtime = (tv.tv_sec % 86400) * MSEC_PER_SEC + tv.tv_nsec / NSEC_PER_MSEC;
-					put_unaligned_be32(midtime, timeptr);
+					__be32  midtime;
+
+					midtime = current_nw_timestamp();
+					memcpy(timeptr, &midtime, 4);
 					opt->is_changed = 1;
 				}
 			} else if ((optptr[3]&0xF) != IPOPT_TS_PRESPEC) {
-- 
1.9.1
