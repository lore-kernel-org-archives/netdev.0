From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH iproute2] htb: Move direct_qlen code part to
 htb_parse_opt().
Date: Sat, 8 Mar 2014 22:10:03 +0900
Message-ID: <20140308221003.72fed9349831ff54a9cb83dc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:39832 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbaCHNKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 08:10:06 -0500
Received: by mail-pa0-f53.google.com with SMTP id ld10so5327871pab.12
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 05:10:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The direct_qlen command option is used with qdisc operation.
It happened to be implemented in htb_parse_class_opt() which is called
with class operation.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
When I read the commit b43f3318280a ("htb: add support for direct_qlen attribute")
I supposed to direct_qlen option is for htb leaf qdisc. But
TCA_HTB_DIRECT_QLEN is parsed in htb_init() and also according
to the command help of htb, I thought direct_qlen was accidentally
implemented in htb_parse_class_opt().
Sorry if I miss something.

 tc/q_htb.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/tc/q_htb.c b/tc/q_htb.c
index 1d8c56f2bf07..7075a4c00c22 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -62,6 +62,7 @@ static void explain1(char *arg)
 
 static int htb_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
+	unsigned int direct_qlen = ~0U;
 	struct tc_htb_glob opt;
 	struct rtattr *tail;
 	unsigned i; char *p;
@@ -86,6 +87,11 @@ static int htb_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				if (*p<'0' || *p>'3') break;
 				opt.debug |= (*p-'0')<<(2*i);
 			}
+		} else if (matches(*argv, "direct_qlen") == 0) {
+			NEXT_ARG();
+			if (get_u32(&direct_qlen, *argv, 10)) {
+				explain1("direct_qlen"); return -1;
+			}
 		} else {
 			fprintf(stderr, "What is \"%s\"?\n", *argv);
 			explain();
@@ -96,6 +102,9 @@ static int htb_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
 	addattr_l(n, 2024, TCA_HTB_INIT, &opt, NLMSG_ALIGN(sizeof(opt)));
+	if (direct_qlen != ~0U)
+		addattr_l(n, 2024, TCA_HTB_DIRECT_QLEN,
+			  &direct_qlen, sizeof(direct_qlen));
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
@@ -110,7 +119,6 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	unsigned mtu;
 	unsigned short mpu = 0;
 	unsigned short overhead = 0;
-	unsigned int direct_qlen = ~0U;
 	unsigned int linklayer  = LINKLAYER_ETHERNET; /* Assume ethernet */
 	struct rtattr *tail;
 	__u64 ceil64 = 0, rate64 = 0;
@@ -129,11 +137,6 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 			if (get_u32(&mtu, *argv, 10)) {
 				explain1("mtu"); return -1;
 			}
-		} else if (matches(*argv, "direct_qlen") == 0) {
-			NEXT_ARG();
-			if (get_u32(&direct_qlen, *argv, 10)) {
-				explain1("direct_qlen"); return -1;
-			}
 		} else if (matches(*argv, "mpu") == 0) {
 			NEXT_ARG();
 			if (get_u16(&mpu, *argv, 10)) {
@@ -245,9 +248,6 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	opt.cbuffer = tc_calc_xmittime(ceil64, cbuffer);
 
 	tail = NLMSG_TAIL(n);
-	if (direct_qlen != ~0U)
-		addattr_l(n, 1024, TCA_HTB_DIRECT_QLEN,
-			  &direct_qlen, sizeof(direct_qlen));
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
 
 	if (rate64 >= (1ULL << 32))
-- 
1.8.3.2
