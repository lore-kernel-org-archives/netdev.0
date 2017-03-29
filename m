From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/8] netfilter: invoke synchronize_rcu after set the _hook_ to NULL
Date: Wed, 29 Mar 2017 14:14:06 +0200
Message-ID: <1490789650-7294-5-git-send-email-pablo@netfilter.org>
References: <1490789650-7294-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43442 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756063AbdC2MPG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 08:15:06 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 49291EBAC3
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 14:15:02 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3812CDA804
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 14:15:02 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 09882DA865
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 14:15:00 +0200 (CEST)
In-Reply-To: <1490789650-7294-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

Otherwise, another CPU may access the invalid pointer. For example:
    CPU0                CPU1
     -              rcu_read_lock();
     -              pfunc = _hook_;
  _hook_ = NULL;          -
  mod unload              -
     -                 pfunc(); // invalid, panic
     -             rcu_read_unlock();

So we must call synchronize_rcu() to wait the rcu reader to finish.

Also note, in nf_nat_snmp_basic_fini, synchronize_rcu() will be invoked
by later nf_conntrack_helper_unregister, but I'm inclined to add a
explicit synchronize_rcu after set the nf_nat_snmp_hook to NULL. Depend
on such obscure assumptions is not a good idea.

Last, in nfnetlink_cttimeout, we use kfree_rcu to free the time object,
so in cttimeout_exit, invoking rcu_barrier() is not necessary at all,
remove it too.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_snmp_basic.c | 1 +
 net/netfilter/nf_conntrack_ecache.c    | 2 ++
 net/netfilter/nf_conntrack_netlink.c   | 1 +
 net/netfilter/nf_nat_core.c            | 2 ++
 net/netfilter/nfnetlink_cttimeout.c    | 2 +-
 5 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index c9b52c361da2..5a8f7c360887 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -1304,6 +1304,7 @@ static int __init nf_nat_snmp_basic_init(void)
 static void __exit nf_nat_snmp_basic_fini(void)
 {
 	RCU_INIT_POINTER(nf_nat_snmp_hook, NULL);
+	synchronize_rcu();
 	nf_conntrack_helper_unregister(&snmp_trap_helper);
 }
 
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index da9df2d56e66..22fc32143e9c 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -290,6 +290,7 @@ void nf_conntrack_unregister_notifier(struct net *net,
 	BUG_ON(notify != new);
 	RCU_INIT_POINTER(net->ct.nf_conntrack_event_cb, NULL);
 	mutex_unlock(&nf_ct_ecache_mutex);
+	/* synchronize_rcu() is called from ctnetlink_exit. */
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_unregister_notifier);
 
@@ -326,6 +327,7 @@ void nf_ct_expect_unregister_notifier(struct net *net,
 	BUG_ON(notify != new);
 	RCU_INIT_POINTER(net->ct.nf_expect_event_cb, NULL);
 	mutex_unlock(&nf_ct_ecache_mutex);
+	/* synchronize_rcu() is called from ctnetlink_exit. */
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_unregister_notifier);
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 6806b5e73567..908d858034e4 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -3442,6 +3442,7 @@ static void __exit ctnetlink_exit(void)
 #ifdef CONFIG_NETFILTER_NETLINK_GLUE_CT
 	RCU_INIT_POINTER(nfnl_ct_hook, NULL);
 #endif
+	synchronize_rcu();
 }
 
 module_init(ctnetlink_init);
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 94b14c5a8b17..82802e4a6640 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -903,6 +903,8 @@ static void __exit nf_nat_cleanup(void)
 #ifdef CONFIG_XFRM
 	RCU_INIT_POINTER(nf_nat_decode_session_hook, NULL);
 #endif
+	synchronize_rcu();
+
 	for (i = 0; i < NFPROTO_NUMPROTO; i++)
 		kfree(nf_nat_l4protos[i]);
 
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 139e0867e56e..47d6656c9119 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -646,8 +646,8 @@ static void __exit cttimeout_exit(void)
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 	RCU_INIT_POINTER(nf_ct_timeout_find_get_hook, NULL);
 	RCU_INIT_POINTER(nf_ct_timeout_put_hook, NULL);
+	synchronize_rcu();
 #endif /* CONFIG_NF_CONNTRACK_TIMEOUT */
-	rcu_barrier();
 }
 
 module_init(cttimeout_init);
-- 
2.1.4
