From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/3 net-2.6.26] [IPV4]: Always pass ip_options pointer into ip_options_compile.
Date: Wed, 19 Mar 2008 15:42:47 +0300
Message-ID: <1205930567-30956-3-git-send-email-den@openvz.org>
References: <1205930508.24116.14.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:63469 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752939AbYCTGkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 02:40:18 -0400
In-Reply-To: <1205930508.24116.14.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes code a bit more uniform and straigthforward.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/ip_input.c   |    5 +++--
 net/ipv4/ip_options.c |   17 +++++++----------
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index d36e310..e3a0c78 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -283,13 +283,14 @@ static inline int ip_rcv_options(struct sk_buff *skb)
 	}
 
 	iph = ip_hdr(skb);
+	opt = &(IPCB(skb)->opt);
+	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
 
-	if (ip_options_compile(NULL, skb)) {
+	if (ip_options_compile(opt, skb)) {
 		IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
 		goto drop;
 	}
 
-	opt = &(IPCB(skb)->opt);
 	if (unlikely(opt->srr)) {
 		struct in_device *in_dev = in_dev_get(dev);
 		if (in_dev) {
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 2fa4113..aeed4e5 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -255,17 +255,14 @@ int ip_options_compile(struct ip_options * opt, struct sk_buff * skb)
 	unsigned char * optptr;
 	int optlen;
 	unsigned char * pp_ptr = NULL;
-	struct rtable *rt = skb ? skb->rtable : NULL;
-
-	if (!opt) {
-		opt = &(IPCB(skb)->opt);
-		iph = skb_network_header(skb);
-		opt->optlen = ((struct iphdr *)iph)->ihl*4 - sizeof(struct iphdr);
-		optptr = iph + sizeof(struct iphdr);
-	} else {
+	struct rtable *rt = NULL;
+
+	if (skb != NULL) {
+		rt = skb->rtable;
+		optptr = (unsigned char *)&(ip_hdr(skb)[1]);
+	} else
 		optptr = opt->__data;
-		iph = optptr - sizeof(struct iphdr);
-	}
+	iph = optptr - sizeof(struct iphdr);
 
 	for (l = opt->optlen; l > 0; ) {
 		switch (*optptr) {
-- 
1.5.3.rc5

