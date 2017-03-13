From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/10] net: fib_rules: Add default rule indication
Date: Mon, 13 Mar 2017 08:38:24 +0100
Message-ID: <1489390713-2634-1-git-send-email-jiri@resnulli.us>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35648 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751595AbdCMHil (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 03:38:41 -0400
Received: by mail-wm0-f66.google.com with SMTP id z63so8329651wmg.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 00:38:40 -0700 (PDT)
In-Reply-To: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Currently, when non-default (custom) FIB rules are used, devices capable
of layer 3 offloading flush their tables and let the kernel do the
forwarding instead.

When these devices' drivers are loaded they register to the FIB
notification chain, which lets them know about the existence of any
custom FIB rules. This is done by sending a RULE_ADD notification based
on the value of 'net->ipv4.fib_has_custom_rules'.

This approach is problematic when VRF offload is taken into account, as
upon the creation of the first VRF netdev, a l3mdev rule is programmed
to direct skbs to the VRF's table.

Instead of merely reading the above value and sending a single RULE_ADD
notification, we should iterate over all the FIB rules and send a
detailed notification for each, thereby allowing offloading drivers to
sanitize the rules they don't support and potentially flush their
tables.

While l3mdev rules are uniquely marked, the default rules are not.
Therefore, when they are being notified they might invoke offloading
drivers to unnecessarily flush their tables. Solve this by uniquely
marking the default rules.

Add a 'def' member to the FIB rule struct and set it whenever a default
rule is created.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/fib_rules.h | 3 ++-
 net/core/fib_rules.c    | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 8dbfdf7..8103f99 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -23,7 +23,8 @@ struct fib_rule {
 	u32			table;
 	u8			action;
 	u8			l3mdev;
-	/* 2 bytes hole, try to use */
+	u8			def;
+	/* 1 byte hole, try to use */
 	u32			target;
 	__be64			tun_id;
 	struct fib_rule __rcu	*ctarget;
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index b6791d9..fa92c71 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -39,6 +39,7 @@ int fib_default_rule_add(struct fib_rules_ops *ops,
 	r->flags = flags;
 	r->fr_net = ops->fro_net;
 	r->uid_range = fib_kuid_range_unset;
+	r->def = 1;
 
 	r->suppress_prefixlen = -1;
 	r->suppress_ifgroup = -1;
-- 
2.7.4
