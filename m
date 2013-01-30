From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 1/4] ipv6 flowlabel: Ensure to take lock when modifying
 np->ip6_sk_fl_list.
Date: Thu, 31 Jan 2013 04:26:42 +0900
Message-ID: <510973F2.3080400@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56111 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755388Ab3A3T0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 14:26:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ip6_flowlabel.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 29124b7..5d767f1 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -255,10 +255,19 @@ void fl6_free_socklist(struct sock *sk)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_fl_socklist *sfl;
 
-	while ((sfl = np->ipv6_fl_list) != NULL) {
-		np->ipv6_fl_list = sfl->next;
+	if (!np->ipv6_fl_list)
+		return;
+
+	write_lock_bh(&ipv6_sk_fl_lock);
+	sfl = np->ipv6_fl_list;
+	np->ipv6_fl_list = NULL;
+	write_unlock_bh(&ipv6_sk_fl_lock);
+
+	while (sfl) {
+		struct ipv6_fl_socklist *next = sfl->next;
 		fl_release(sfl->fl);
 		kfree(sfl);
+		sfl = next;
 	}
 }
 
-- 
1.7.9.5
