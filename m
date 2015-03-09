From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 5/6] tcp_metrics: Rewrite tcp_metrics_flush_all
Date: Mon, 09 Mar 2015 13:30:40 -0500
Message-ID: <87bnk2yqen.fsf_-_@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45332 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbbCISeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 14:34:19 -0400
In-Reply-To: <87h9tu114z.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Mon, 09 Mar 2015 13:22:52 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Rewrite tcp_metrics_flush_all so that it can cope with entries from
different network namespaces on it's hash chain.

This is based on the logic in tcp_metrics_nl_cmd_del for deleting a
selection of entries from a tcp metrics hash chain.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/tcp_metrics.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index e98c6e9770c1..b85e0c79895f 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1046,18 +1046,19 @@ static void tcp_metrics_flush_all(struct net *net)
 	unsigned int row;
 
 	for (row = 0; row < max_rows; row++, hb++) {
+		struct tcp_metrics_block __rcu **pp;
 		spin_lock_bh(&tcp_metrics_lock);
-		tm = deref_locked_genl(hb->chain);
-		if (tm)
-			hb->chain = NULL;
-		spin_unlock_bh(&tcp_metrics_lock);
-		while (tm) {
-			struct tcp_metrics_block *next;
-
-			next = deref_genl(tm->tcpm_next);
-			kfree_rcu(tm, rcu_head);
-			tm = next;
+		pp = &hb->chain;
+		for (tm = deref_locked_genl(*pp); tm;
+		     tm = deref_locked_genl(*pp)) {
+			if (tm->tcpm_net == net) {
+				*pp = tm->tcpm_next;
+				kfree_rcu(tm, rcu_head);
+			} else {
+				pp = &tm->tcpm_next;
+			}
 		}
+		spin_unlock_bh(&tcp_metrics_lock);
 	}
 }
 
-- 
2.2.1
