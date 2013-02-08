From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] ipv6: fix a RCU warning in net/ipv6/ip6_flowlabel.c
Date: Fri,  8 Feb 2013 09:52:40 +0800
Message-ID: <1360288360-20385-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758909Ab3BHBww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 20:52:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following RCU warning:

[   51.680236] ===============================
[   51.681914] [ INFO: suspicious RCU usage. ]
[   51.683610] 3.8.0-rc6-next-20130206-sasha-00028-g83214f7-dirty #276 Tainted: G        W
[   51.686703] -------------------------------
[   51.688281] net/ipv6/ip6_flowlabel.c:671 suspicious rcu_dereference_check() usage!

we should use rcu_dereference_bh() when we hold rcu_read_lock_bh().

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index ea42bf4..a7da2f4 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -65,13 +65,13 @@ static DEFINE_SPINLOCK(ip6_fl_lock);
 static DEFINE_SPINLOCK(ip6_sk_fl_lock);
 
 #define for_each_fl_rcu(hash, fl)				\
-	for (fl = rcu_dereference(fl_ht[(hash)]);		\
+	for (fl = rcu_dereference_bh(fl_ht[(hash)]);		\
 	     fl != NULL;					\
-	     fl = rcu_dereference(fl->next))
+	     fl = rcu_dereference_bh(fl->next))
 #define for_each_fl_continue_rcu(fl)				\
-	for (fl = rcu_dereference(fl->next);			\
+	for (fl = rcu_dereference_bh(fl->next);			\
 	     fl != NULL;					\
-	     fl = rcu_dereference(fl->next))
+	     fl = rcu_dereference_bh(fl->next))
 
 #define for_each_sk_fl_rcu(np, sfl)				\
 	for (sfl = rcu_dereference_bh(np->ipv6_fl_list);	\
