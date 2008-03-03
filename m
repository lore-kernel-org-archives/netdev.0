From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/4 net-2.6.26] [IPV4]: Cleanup ip_options_compile.
Date: Mon,  3 Mar 2008 18:48:41 +0300
Message-ID: <1204559323-19953-2-git-send-email-den@openvz.org>
References: <1204559323-19953-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:50277 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756320AbYCCPsj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 10:48:39 -0500
In-Reply-To: <1204559323-19953-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now ip_options_compile is called twice as (NULL, skb) and (opt, NULL).
So, let's move opt initialization into caller and remove this initialization
branch.

Additionally, the field ip_options->is_data becomes not needed. All decisions
should be made by the real skb availability.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/inet_sock.h |    4 +---
 net/ipv4/ip_input.c     |    5 +++--
 net/ipv4/ip_options.c   |   24 +++++++-----------------
 3 files changed, 11 insertions(+), 22 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 70013c5..e63714d 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -29,7 +29,6 @@
 /** struct ip_options - IP Options
  *
  * @faddr - Saved first hop address
- * @is_data - Options in __data, rather than skb
  * @is_strictroute - Strict source route
  * @srr_is_hit - Packet destination addr was our one
  * @is_changed - IP checksum more not valid
@@ -43,8 +42,7 @@ struct ip_options {
 	unsigned char	srr;
 	unsigned char	rr;
 	unsigned char	ts;
-	unsigned char	is_data:1,
-			is_strictroute:1,
+	unsigned char	is_strictroute:1,
 			srr_is_hit:1,
 			is_changed:1,
 			rr_needaddr:1,
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 6563139..3dbdb0c 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -284,12 +284,13 @@ static inline int ip_rcv_options(struct sk_buff *skb)
 
 	iph = ip_hdr(skb);
 
-	if (ip_options_compile(NULL, skb)) {
+	opt = &(IPCB(skb)->opt);
+	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
+	if (ip_options_compile(opt, skb)) {
 		IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
 		goto drop;
 	}
 
-	opt = &(IPCB(skb)->opt);
 	if (unlikely(opt->srr)) {
 		struct in_device *in_dev = in_dev_get(dev);
 		if (in_dev) {
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index baaedd9..c49aa79 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -45,7 +45,6 @@ void ip_options_build(struct sk_buff * skb, struct ip_options * opt,
 	memcpy(&(IPCB(skb)->opt), opt, sizeof(struct ip_options));
 	memcpy(iph+sizeof(struct iphdr), opt->__data, opt->optlen);
 	opt = &(IPCB(skb)->opt);
-	opt->is_data = 0;
 
 	if (opt->srr)
 		memcpy(iph+opt->srr+iph[opt->srr+1]-4, &daddr, 4);
@@ -95,8 +94,6 @@ int ip_options_echo(struct ip_options * dopt, struct sk_buff * skb)
 
 	memset(dopt, 0, sizeof(struct ip_options));
 
-	dopt->is_data = 1;
-
 	sopt = &(IPCB(skb)->opt);
 
 	if (sopt->optlen == 0) {
@@ -248,7 +245,6 @@ void ip_options_fragment(struct sk_buff * skb)
 /*
  * Verify options and fill pointers in struct options.
  * Caller should clear *opt, and set opt->data.
- * If opt == NULL, then skb->data should point to IP header.
  */
 
 int ip_options_compile(struct ip_options * opt, struct sk_buff * skb)
@@ -258,19 +254,14 @@ int ip_options_compile(struct ip_options * opt, struct sk_buff * skb)
 	unsigned char * optptr;
 	int optlen;
 	unsigned char * pp_ptr = NULL;
-	struct rtable *rt = skb ? (struct rtable*)skb->dst : NULL;
-
-	if (!opt) {
-		opt = &(IPCB(skb)->opt);
-		iph = skb_network_header(skb);
-		opt->optlen = ((struct iphdr *)iph)->ihl*4 - sizeof(struct iphdr);
-		optptr = iph + sizeof(struct iphdr);
-		opt->is_data = 0;
-	} else {
-		optptr = opt->is_data ? opt->__data :
-					(unsigned char *)&(ip_hdr(skb)[1]);
-		iph = optptr - sizeof(struct iphdr);
+	struct rtable *rt = NULL;
+
+	optptr = opt->__data;
+	if (skb != NULL) {
+		rt = (struct rtable*)skb->dst;
+		optptr = (unsigned char *)&(ip_hdr(skb)[1]);
 	}
+	iph = optptr - sizeof(struct iphdr);
 
 	for (l = opt->optlen; l > 0; ) {
 		switch (*optptr) {
@@ -520,7 +511,6 @@ static int ip_options_get_finish(struct ip_options **optp,
 	while (optlen & 3)
 		opt->__data[optlen++] = IPOPT_END;
 	opt->optlen = optlen;
-	opt->is_data = 1;
 	if (optlen && ip_options_compile(opt, NULL)) {
 		kfree(opt);
 		return -EINVAL;
-- 
1.5.3.rc5

