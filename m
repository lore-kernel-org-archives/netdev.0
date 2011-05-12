From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] iproute2: use IFLA_TXQLEN when it is available
Date: Thu, 12 May 2011 10:47:31 +0800
Message-ID: <1305168451-14491-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	Changli Gao <xiaosuo@gmail.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:43057 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627Ab1ELCsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 22:48:13 -0400
Received: by pzk9 with SMTP id 9so519063pzk.19
        for <netdev@vger.kernel.org>; Wed, 11 May 2011 19:48:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use IFLA_TXQLEN when it is available, to avoid additional system calls.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 ip/ipaddress.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index a1f78b9..59afafd 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -285,8 +285,16 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (tb[IFLA_OPERSTATE])
 		print_operstate(fp, *(__u8 *)RTA_DATA(tb[IFLA_OPERSTATE]));
 		
-	if (filter.showqueue)
-		print_queuelen(fp, (char*)RTA_DATA(tb[IFLA_IFNAME]));
+	if (filter.showqueue) {
+		if (tb[IFLA_TXQLEN]) {
+			__u32 txqlen = *(__u32 *)RTA_DATA(tb[IFLA_TXQLEN]);
+
+			if (txqlen)
+				fprintf(fp, "qlen %u", txqlen);
+		} else {
+			print_queuelen(fp, (char*)RTA_DATA(tb[IFLA_IFNAME]));
+		}
+	}
 
 	if (!filter.family || filter.family == AF_PACKET) {
 		SPRINT_BUF(b1);
