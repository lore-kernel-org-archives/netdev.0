From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ip: Support IFLA_TXQLEN in ip link command
Date: Thu, 22 Oct 2009 16:15:07 +0200
Message-ID: <4AE068EB.70005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Benjamin LaHaise <bcrl@lhnet.ca>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40991 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755554AbZJVOPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 10:15:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently use an expensive ioctl() to get device txqueuelen, while
rtnetlink gave it to us for free. This patch speeds up ip link operation
when many devices are registered.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 267ecb3..f06a3f7 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -252,9 +252,12 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (tb[IFLA_OPERSTATE])
 		print_operstate(fp, *(__u8 *)RTA_DATA(tb[IFLA_OPERSTATE]));
 		
-	if (filter.showqueue)
-		print_queuelen(fp, (char*)RTA_DATA(tb[IFLA_IFNAME]));
-
+	if (filter.showqueue) {
+		if (tb[IFLA_TXQLEN])
+			fprintf(fp, "qlen %d ", *(int *)RTA_DATA(tb[IFLA_TXQLEN]));
+		else
+			print_queuelen(fp, (char *)RTA_DATA(tb[IFLA_IFNAME]));
+	}
 	if (!filter.family || filter.family == AF_PACKET) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "%s", _SL_);
