From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 2/7] ss: Replace pktstat struct by new sockstat struct
Date: Fri, 13 Feb 2015 22:13:59 +0200
Message-ID: <1423858444-10158-3-git-send-email-vadim4j@gmail.com>
References: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:63266 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbbBMUZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 15:25:13 -0500
Received: by mail-lb0-f179.google.com with SMTP id w7so17655599lbi.10
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 12:25:11 -0800 (PST)
In-Reply-To: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 33 ++++++++++++---------------------
 1 file changed, 12 insertions(+), 21 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 7e11fc0..f033892 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -692,6 +692,8 @@ static const char *sstate_namel[] = {
 
 struct sockstat
 {
+	uint8_t		    type;
+	uint16_t	    prot;
 	inet_prefix	    local;
 	inet_prefix	    remote;
 	int		    lport;
@@ -2719,29 +2721,18 @@ static int unix_show(struct filter *f)
 	return 0;
 }
 
-struct pktstat {
-	uint8_t  type;
-	uint16_t prot;
-	uint32_t iface;
-	int state;
-	uint32_t rq;
-	uid_t uid;
-	ino_t ino;
-};
-
-static int packet_stats_print(struct pktstat *s, const struct filter *f)
+static int packet_stats_print(struct sockstat *s, const struct filter *f)
 {
 	char *buf = NULL;
 
 	if (f->f) {
-		struct sockstat st;
-		st.local.family = AF_PACKET;
-		st.remote.family = AF_PACKET;
-		st.rport = 0;
-		st.lport = s->iface;
-		st.local.data[0] = s->prot;
-		st.remote.data[0] = 0;
-		if (run_ssfilter(f->f, &st) == 0)
+		s->local.family = AF_PACKET;
+		s->remote.family = AF_PACKET;
+		s->rport = 0;
+		s->lport = s->iface;
+		s->local.data[0] = s->prot;
+		s->remote.data[0] = 0;
+		if (run_ssfilter(f->f, s) == 0)
 			return 1;
 	}
 
@@ -2790,7 +2781,7 @@ static int packet_show_sock(const struct sockaddr_nl *addr,
 	const struct filter *f = arg;
 	struct packet_diag_msg *r = NLMSG_DATA(nlh);
 	struct rtattr *tb[PACKET_DIAG_MAX+1];
-	struct pktstat stat = {};
+	struct sockstat stat = {};
 
 	parse_rtattr(tb, PACKET_DIAG_MAX, (struct rtattr*)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
@@ -2859,7 +2850,7 @@ static int packet_show_netlink(struct filter *f)
 static int packet_show_line(char *buf, const struct filter *f, int fam)
 {
 	unsigned long long sk;
-	struct pktstat stat = {};
+	struct sockstat stat = {};
 	int type, prot, iface, state, rq, uid, ino;
 
 	sscanf(buf, "%llx %*d %d %x %d %d %u %u %u",
-- 
2.2.2
