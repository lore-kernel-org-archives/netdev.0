From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 5/6] tcp_metrics: Rewrite tcp_metrics_flush_all
Date: Fri, 13 Mar 2015 00:07:10 -0500
Message-ID: <874mppxz7l.fsf_-_@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
	<87y4n1xzco.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com,
	Julian Anastasov <ja@ssi.bg>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:56065 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbbCMFKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 01:10:52 -0400
In-Reply-To: <87y4n1xzco.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 13 Mar 2015 00:04:07 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Rewrite tcp_metrics_flush_all so that it can cope with entries from
different network namespaces on it's hash chain.

This is based on the logic in tcp_metrics_nl_cmd_del for deleting
a selection of entries from a tcp metrics hash chain.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/tcp_metrics.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 0d07e14f2ca5..baccb070427d 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1051,18 +1051,19 @@ static void tcp_metrics_flush_all(struct net *net)
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
+			if (net_eq(tm_net(tm), net)) {
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
