From: chavey@google.com
Subject: [PATCH] netfilter: Fix compiler warning.
Date: Wed, 09 Dec 2009 17:25:00 -0800
Message-ID: <pvmhbrzboyb.fsf@chavey.mtv.corp.google.com>
Cc: netdev@vger.kernel.org, chavey@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:35961 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759342AbZLJBZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 20:25:00 -0500
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id nBA1P6iI001037
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 01:25:06 GMT
Received: from gxk3 (gxk3.prod.google.com [10.202.11.3])
	by wpaz13.hot.corp.google.com with ESMTP id nBA1P3ia006328
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 17:25:04 -0800
Received: by gxk3 with SMTP id 3so686152gxk.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2009 17:25:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix compiler warning "discards qualifiers from pointer target type".
The function prototype defines parameters as pointer to a constant.
Such parameters should not have their content modified in the
function.

Signed-off-by: Laurent Chavey <chavey@google.com>
---
 net/ipv4/netfilter/ipt_ULOG.c |    6 ++++--
 net/netfilter/xt_time.c       |    6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index d32cc4b..8490f9f 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -166,6 +166,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
 	size_t size, copy_len;
 	struct nlmsghdr *nlh;
 	struct timeval tv;
+	ktime_t	tstamp;
 
 	/* ffs == find first bit set, necessary because userspace
 	 * is already shifting groupnumber, but we need unshifted.
@@ -208,13 +209,14 @@ static void ipt_ulog_packet(unsigned int hooknum,
 
 	pm = NLMSG_DATA(nlh);
 
+	tstamp = skb->tstamp;
 	/* We might not have a timestamp, get one */
 	if (skb->tstamp.tv64 == 0)
-		__net_timestamp((struct sk_buff *)skb);
+		tstamp = ktime_get_real();
 
 	/* copy hook, prefix, timestamp, payload, etc. */
 	pm->data_len = copy_len;
-	tv = ktime_to_timeval(skb->tstamp);
+	tv = ktime_to_timeval(tstamp);
 	put_unaligned(tv.tv_sec, &pm->timestamp_sec);
 	put_unaligned(tv.tv_usec, &pm->timestamp_usec);
 	put_unaligned(skb->mark, &pm->mark);
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index 93acaa5..66e2a75 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -159,6 +159,7 @@ time_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	unsigned int packet_time;
 	struct xtm current_time;
 	s64 stamp;
+	ktime_t	tstamp;
 
 	/*
 	 * We cannot use get_seconds() instead of __net_timestamp() here.
@@ -169,10 +170,11 @@ time_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	 * may happen that the same packet matches both rules if
 	 * it arrived at the right moment before 13:00.
 	 */
+	tstamp = skb->tstamp;
 	if (skb->tstamp.tv64 == 0)
-		__net_timestamp((struct sk_buff *)skb);
+		tstamp = ktime_get_real();
 
-	stamp = ktime_to_ns(skb->tstamp);
+	stamp = ktime_to_ns(tstamp);
 	stamp = div_s64(stamp, NSEC_PER_SEC);
 
 	if (info->flags & XT_TIME_LOCAL_TZ)
