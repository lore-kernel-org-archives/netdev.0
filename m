From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] netlink: use blocking notifier
Date: Fri,  9 Dec 2016 21:10:59 -0800
Message-ID: <1481346661-25380-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34720 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751986AbcLJFLM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 00:11:12 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so4325153pgc.1
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 21:11:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netlink_chain is called in ->release(), which is apparently
a process context, so we don't have to use an atomic notifier
here.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/netlink/af_netlink.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 246f29d..801d474 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -113,7 +113,7 @@ static atomic_t nl_table_users = ATOMIC_INIT(0);
 
 #define nl_deref_protected(X) rcu_dereference_protected(X, lockdep_is_held(&nl_table_lock));
 
-static ATOMIC_NOTIFIER_HEAD(netlink_chain);
+static BLOCKING_NOTIFIER_HEAD(netlink_chain);
 
 static DEFINE_SPINLOCK(netlink_tap_lock);
 static struct list_head netlink_tap_all __read_mostly;
@@ -711,7 +711,7 @@ static int netlink_release(struct socket *sock)
 						.protocol = sk->sk_protocol,
 						.portid = nlk->portid,
 					  };
-		atomic_notifier_call_chain(&netlink_chain,
+		blocking_notifier_call_chain(&netlink_chain,
 				NETLINK_URELEASE, &n);
 	}
 
@@ -2504,13 +2504,13 @@ static const struct file_operations netlink_seq_fops = {
 
 int netlink_register_notifier(struct notifier_block *nb)
 {
-	return atomic_notifier_chain_register(&netlink_chain, nb);
+	return blocking_notifier_chain_register(&netlink_chain, nb);
 }
 EXPORT_SYMBOL(netlink_register_notifier);
 
 int netlink_unregister_notifier(struct notifier_block *nb)
 {
-	return atomic_notifier_chain_unregister(&netlink_chain, nb);
+	return blocking_notifier_chain_unregister(&netlink_chain, nb);
 }
 EXPORT_SYMBOL(netlink_unregister_notifier);
 
-- 
2.5.5
