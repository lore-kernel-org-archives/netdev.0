From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/9] ipv4: fib_rules: Add notifier info to FIB rules notifications
Date: Wed, 15 Mar 2017 12:05:05 +0100
Message-ID: <1489575912-6469-3-git-send-email-jiri@resnulli.us>
References: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35233 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752980AbdCOLFT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 07:05:19 -0400
Received: by mail-wm0-f68.google.com with SMTP id z63so4071376wmg.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 04:05:17 -0700 (PDT)
In-Reply-To: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Whenever a FIB rule is added or removed, a notification is sent in the
FIB notification chain. However, listeners don't have a way to tell
which rule was added or removed.

This is problematic as we would like to give listeners the ability to
decide which action to execute based on the notified rule. Specifically,
offloading drivers should be able to determine if they support the
reflection of the notified FIB rule and flush their LPM tables in case
they don't.

Do that by adding a notifier info to these notifications and embed the
common FIB rule struct in it.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip_fib.h |  5 +++++
 net/ipv4/fib_rules.c | 13 ++++++++-----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index ec03e0f..319de77 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -213,6 +213,11 @@ struct fib_entry_notifier_info {
 	u32 tb_id;
 };
 
+struct fib_rule_notifier_info {
+	struct fib_notifier_info info; /* must be first */
+	struct fib_rule *rule;
+};
+
 struct fib_nh_notifier_info {
 	struct fib_notifier_info info; /* must be first */
 	struct fib_nh *fib_nh;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 7a941a5..d9cd3be 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -175,11 +175,14 @@ static struct fib_table *fib_empty_table(struct net *net)
 }
 
 static int call_fib_rule_notifiers(struct net *net,
-				   enum fib_event_type event_type)
+				   enum fib_event_type event_type,
+				   struct fib_rule *rule)
 {
-	struct fib_notifier_info info;
+	struct fib_rule_notifier_info info = {
+		.rule = rule,
+	};
 
-	return call_fib_notifiers(net, event_type, &info);
+	return call_fib_notifiers(net, event_type, &info.info);
 }
 
 void fib_rules_notify(struct net *net, struct notifier_block *nb)
@@ -246,7 +249,7 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	rule4->tos = frh->tos;
 
 	net->ipv4.fib_has_custom_rules = true;
-	call_fib_rule_notifiers(net, FIB_EVENT_RULE_ADD);
+	call_fib_rule_notifiers(net, FIB_EVENT_RULE_ADD, rule);
 
 	err = 0;
 errout:
@@ -268,7 +271,7 @@ static int fib4_rule_delete(struct fib_rule *rule)
 		net->ipv4.fib_num_tclassid_users--;
 #endif
 	net->ipv4.fib_has_custom_rules = true;
-	call_fib_rule_notifiers(net, FIB_EVENT_RULE_DEL);
+	call_fib_rule_notifiers(net, FIB_EVENT_RULE_DEL, rule);
 errout:
 	return err;
 }
-- 
2.7.4
