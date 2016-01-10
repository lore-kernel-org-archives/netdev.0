From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 1/1] tc: flower no need to specify the ethertype
Date: Sun, 10 Jan 2016 14:56:31 -0500
Message-ID: <1452455791-5833-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35687 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757185AbcAJT4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 14:56:42 -0500
Received: by mail-ig0-f169.google.com with SMTP id t15so83152397igr.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 11:56:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

since all tc classifiers are required to specify ethertype as part of grammar
By not allowing eth_type to be specified we remove contradiction for 
example when a user specifies:
tc filter add ... priority xxx protocol ip flower eth_type ipv6
This patch removes that contradiction

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/f_flower.c | 55 +++++++++++++++++--------------------------------------
 1 file changed, 17 insertions(+), 38 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index a9b2c4d..db9cc29 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -31,7 +31,7 @@ static void explain(void)
 	fprintf(stderr, "       MATCH      := { indev DEV-NAME | \n");
 	fprintf(stderr, "                       dst_mac MAC-ADDR | \n");
 	fprintf(stderr, "                       src_mac MAC-ADDR | \n");
-	fprintf(stderr, "                       eth_type [ipv4 | ipv6 | ETH-TYPE ] | \n");
+	fprintf(stderr, "                       [ipv4 | ipv6 ] | \n");
 	fprintf(stderr, "                       ip_proto [tcp | udp | IP-PROTO ] | \n");
 	fprintf(stderr, "                       dst_ip [ IPV4-ADDR | IPV6-ADDR ] | \n");
 	fprintf(stderr, "                       src_ip [ IPV4-ADDR | IPV6-ADDR ] | \n");
@@ -60,29 +60,6 @@ static int flower_parse_eth_addr(char *str, int addr_type, int mask_type,
 	return 0;
 }
 
-static int flower_parse_eth_type(char *str, int type, __be16 *p_eth_type,
-				 struct nlmsghdr *n)
-{
-	int ret;
-	__be16 eth_type;
-
-	if (matches(str, "ipv4") == 0) {
-		eth_type = htons(ETH_P_IP);
-	} else if (matches(str, "ipv6") == 0) {
-		eth_type = htons(ETH_P_IPV6);
-	} else {
-		__u16 tmp;
-
-		ret = get_u16(&tmp, str, 16);
-		if (ret)
-			return -1;
-		eth_type = htons(tmp);
-	}
-	addattr16(n, MAX_MSG, type, eth_type);
-	*p_eth_type = eth_type;
-	return 0;
-}
-
 static int flower_parse_ip_proto(char *str, __be16 eth_type, int type,
 				 __u8 *p_ip_proto, struct nlmsghdr *n)
 {
@@ -188,12 +165,9 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 	int ret;
 	struct tcmsg *t = NLMSG_DATA(n);
 	struct rtattr *tail;
-	__be16 eth_type = 0;
+	__be16 eth_type = TC_H_MIN(t->tcm_info);
 	__u8 ip_proto = 0xff;
 
-	if (argc == 0)
-		return 0;
-
 	if (handle) {
 		ret = get_u32(&t->tcm_handle, handle, 0);
 		if (ret) {
@@ -205,6 +179,11 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 	tail = (struct rtattr *) (((void *) n) + NLMSG_ALIGN(n->nlmsg_len));
 	addattr_l(n, MAX_MSG, TCA_OPTIONS, NULL, 0);
 
+	if (argc == 0) {
+		/*at minimal we will match all ethertype packets */
+		goto parse_done;
+	}
+
 	while (argc > 0) {
 		if (matches(*argv, "classid") == 0 ||
 		    matches(*argv, "flowid") == 0) {
@@ -244,15 +223,6 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 				fprintf(stderr, "Illegal \"src_mac\"\n");
 				return -1;
 			}
-		} else if (matches(*argv, "eth_type") == 0) {
-			NEXT_ARG();
-			ret = flower_parse_eth_type(*argv,
-						    TCA_FLOWER_KEY_ETH_TYPE,
-						    &eth_type, n);
-			if (ret < 0) {
-				fprintf(stderr, "Illegal \"eth_type\"\n");
-				return -1;
-			}
 		} else if (matches(*argv, "ip_proto") == 0) {
 			NEXT_ARG();
 			ret = flower_parse_ip_proto(*argv, eth_type,
@@ -323,6 +293,14 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 		argc--; argv++;
 	}
 
+parse_done:
+	ret = addattr16(n, MAX_MSG, TCA_FLOWER_KEY_ETH_TYPE, eth_type);
+	if (ret) {
+		fprintf(stderr, "Illegal \"eth_type\"(0x%x)\n",
+			ntohs(eth_type));
+		return -1;
+	}
+
 	tail->rta_len = (((void*)n)+n->nlmsg_len) - (void*)tail;
 
 	return 0;
@@ -489,7 +467,8 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	if (tb[TCA_FLOWER_CLASSID]) {
 		SPRINT_BUF(b1);
 		fprintf(f, "classid %s ",
-			sprint_tc_classid(rta_getattr_u32(tb[TCA_FLOWER_CLASSID]), b1));
+			sprint_tc_classid(rta_getattr_u32(tb[TCA_FLOWER_CLASSID]),
+					  b1));
 	}
 
 	if (tb[TCA_FLOWER_INDEV]) {
-- 
1.9.1
