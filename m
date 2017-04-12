From: gfree.wind@foxmail.com
Subject: [PATCH net-next 1/1] net: ipv4: Refine the ipv4_default_advmss
Date: Wed, 12 Apr 2017 09:36:39 +0800
Message-ID: <1491960999-42794-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpproxy19.qq.com ([184.105.206.84]:49923 "EHLO
        smtpproxy19.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752413AbdDLBg6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 21:36:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

1. Don't get the metric RTAX_ADVMSS of dst.
There are two reasons.
1) Its caller dst_metric_advmss has already invoke dst_metric_advmss
before invoke default_advmss.
2) The ipv4_default_advmss is used to get the default mss, it should
not try to get the metric like ip6_default_advmss.

2. Use sizeof(tcphdr)+sizeof(iphdr) instead of literal 40.

3. Define one new macro IPV4_MAX_PMTU instead of 65535 according to
RFC 2675, section 5.1.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 include/net/ip.h |  2 ++
 net/ipv4/route.c | 11 ++++-------
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index bf264a8..821cedc 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -33,6 +33,8 @@
 #include <net/flow.h>
 #include <net/flow_dissector.h>
 
+#define IPV4_MAX_PMTU		65535U		/* RFC 2675, Section 5.1 */
+
 struct sock;
 
 struct inet_skb_parm {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5e1e605..b4fca1e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1250,14 +1250,11 @@ static void set_class_tag(struct rtable *rt, u32 tag)
 
 static unsigned int ipv4_default_advmss(const struct dst_entry *dst)
 {
-	unsigned int advmss = dst_metric_raw(dst, RTAX_ADVMSS);
+	unsigned int header_size = sizeof(struct tcphdr) + sizeof(struct iphdr);
+	unsigned int advmss = max_t(unsigned int, dst->dev->mtu - header_size,
+				    ip_rt_min_advmss);
 
-	if (advmss == 0) {
-		advmss = max_t(unsigned int, dst->dev->mtu - 40,
-			       ip_rt_min_advmss);
-		if (advmss > 65535 - 40)
-			advmss = 65535 - 40;
-	}
+	advmss = min_t(unsigned int, advmss, IPV4_MAX_PMTU - header_size);
 	return advmss;
 }
 
-- 
1.9.1
