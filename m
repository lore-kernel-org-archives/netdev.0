From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: fix a lockdep splat
Date: Tue, 02 Feb 2016 17:55:01 -0800
Message-ID: <1454464501.7627.210.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160202195933.GA6302@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34180 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932130AbcBCBzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 20:55:04 -0500
Received: by mail-pa0-f42.google.com with SMTP id uo6so4257063pac.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 17:55:03 -0800 (PST)
In-Reply-To: <20160202195933.GA6302@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Silence lockdep false positive about rcu_dereference() being
used in the wrong context.

First one should use rcu_dereference_protected() as we own the spinlock.

Second one should be a normal assignation, as no barrier is needed.

Fixes: 18367681a10bd ("ipv6 flowlabel: Convert np->ipv6_fl_list to RCU.")
Reported-by: Dave Jones <davej@codemonkey.org.uk>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_flowlabel.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 1f9ebe3cbb4a..dc2db4f7b182 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -540,12 +540,13 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 		}
 		spin_lock_bh(&ip6_sk_fl_lock);
 		for (sflp = &np->ipv6_fl_list;
-		     (sfl = rcu_dereference(*sflp)) != NULL;
+		     (sfl = rcu_dereference_protected(*sflp,
+						      lockdep_is_held(&ip6_sk_fl_lock))) != NULL;
 		     sflp = &sfl->next) {
 			if (sfl->fl->label == freq.flr_label) {
 				if (freq.flr_label == (np->flow_label&IPV6_FLOWLABEL_MASK))
 					np->flow_label &= ~IPV6_FLOWLABEL_MASK;
-				*sflp = rcu_dereference(sfl->next);
+				*sflp = sfl->next;
 				spin_unlock_bh(&ip6_sk_fl_lock);
 				fl_release(sfl->fl);
 				kfree_rcu(sfl, rcu);
