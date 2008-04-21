From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV4]: Convert do_gettimeofday() to getnstimeofday().
Date: Mon, 21 Apr 2008 16:22:21 +0900 (JST)
Message-ID: <20080421.162221.11408096.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34215 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbYDUHU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 03:20:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What do_gettimeofday() does is to call getnstimeofday() and
to convert the result from timespec{} to timeval{}.
After that, these callers convert the result again to msec.
Use getnstimeofday() and convert the units at once.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f064031..0e8ed5d 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -847,7 +847,7 @@ static void icmp_echo(struct sk_buff *skb)
  */
 static void icmp_timestamp(struct sk_buff *skb)
 {
-	struct timeval tv;
+	struct timespec tv;
 	struct icmp_bxm icmp_param;
 	/*
 	 *	Too short.
@@ -858,9 +858,9 @@ static void icmp_timestamp(struct sk_buff *skb)
 	/*
 	 *	Fill in the current time as ms since midnight UT:
 	 */
-	do_gettimeofday(&tv);
-	icmp_param.data.times[1] = htonl((tv.tv_sec % 86400) * 1000 +
-					 tv.tv_usec / 1000);
+	getnstimeofday(&tv);
+	icmp_param.data.times[1] = htonl((tv.tv_sec % 86400) * MSEC_PER_SEC +
+					 tv.tv_nsec / NSEC_PER_MSEC);
 	icmp_param.data.times[2] = icmp_param.data.times[1];
 	if (skb_copy_bits(skb, 0, &icmp_param.data.times[0], 4))
 		BUG();
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index d107543..005e548 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -55,10 +55,10 @@ void ip_options_build(struct sk_buff * skb, struct ip_options * opt,
 		if (opt->ts_needaddr)
 			ip_rt_get_source(iph+opt->ts+iph[opt->ts+2]-9, rt);
 		if (opt->ts_needtime) {
-			struct timeval tv;
+			struct timespec tv;
 			__be32 midtime;
-			do_gettimeofday(&tv);
-			midtime = htonl((tv.tv_sec % 86400) * 1000 + tv.tv_usec / 1000);
+			getnstimeofday(&tv);
+			midtime = htonl((tv.tv_sec % 86400) * MSEC_PER_SEC + tv.tv_nsec / NSEC_PER_MSEC);
 			memcpy(iph+opt->ts+iph[opt->ts+2]-5, &midtime, 4);
 		}
 		return;
@@ -406,10 +406,10 @@ int ip_options_compile(struct net *net,
 					break;
 				}
 				if (timeptr) {
-					struct timeval tv;
+					struct timespec tv;
 					__be32  midtime;
-					do_gettimeofday(&tv);
-					midtime = htonl((tv.tv_sec % 86400) * 1000 + tv.tv_usec / 1000);
+					getnstimeofday(&tv);
+					midtime = htonl((tv.tv_sec % 86400) * MSEC_PER_SEC + tv.tv_nsec / NSEC_PER_MSEC);
 					memcpy(timeptr, &midtime, sizeof(__be32));
 					opt->is_changed = 1;
 				}

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
