From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next 4/4] ipv6: protect flow label renew against GC
Date: Tue,  5 Nov 2013 15:28:58 +0100
Message-ID: <1383661738-6083-4-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1383661738-6083-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:40713 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755157Ab3KEO3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 09:29:15 -0500
In-Reply-To: <1383661738-6083-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take ip6_fl_lock before to read and update a
label. It prevents race condition if GC is
running.

Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv6/ip6_flowlabel.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 41ced9c..1d2fc48 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -540,11 +540,13 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 		return -ESRCH;
 
 	case IPV6_FL_A_RENEW:
+		spin_lock_bh(&ip6_fl_lock);
 		rcu_read_lock_bh();
 		for_each_sk_fl_rcu(np, sfl) {
 			if (sfl->fl->label == freq.flr_label) {
 				err = fl6_renew(sfl->fl, freq.flr_linger, freq.flr_expires);
 				rcu_read_unlock_bh();
+				spin_unlock_bh(&ip6_fl_lock);
 				return err;
 			}
 		}
@@ -555,10 +557,12 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 			fl = fl_lookup(net, freq.flr_label);
 			if (fl) {
 				err = fl6_renew(fl, freq.flr_linger, freq.flr_expires);
+				spin_unlock_bh(&ip6_fl_lock);
 				fl_release(fl);
 				return err;
 			}
 		}
+		spin_unlock_bh(&ip6_fl_lock);
 		return -ESRCH;
 
 	case IPV6_FL_A_GET:
-- 
1.8.4.rc3
