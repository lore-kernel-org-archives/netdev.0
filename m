From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/8] ipv4: fib: Convert FIB notification chain to be atomic
Date: Wed, 16 Nov 2016 15:08:59 +0100
Message-ID: <1479305343-13167-5-git-send-email-jiri@resnulli.us>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35325 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932333AbcKPOJK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:09:10 -0500
Received: by mail-wm0-f66.google.com with SMTP id a20so11531180wme.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:09:10 -0800 (PST)
In-Reply-To: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In order not to hold RTNL for long periods of time we're going to dump
the FIB tables using RCU.

Convert the FIB notification chain to be atomic, as we can't block in
RCU critical sections.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/ipv4/fib_trie.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 4cff74d..64a51ec 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -84,17 +84,17 @@
 #include <trace/events/fib.h>
 #include "fib_lookup.h"
 
-static BLOCKING_NOTIFIER_HEAD(fib_chain);
+static ATOMIC_NOTIFIER_HEAD(fib_chain);
 
 int register_fib_notifier(struct notifier_block *nb)
 {
-	return blocking_notifier_chain_register(&fib_chain, nb);
+	return atomic_notifier_chain_register(&fib_chain, nb);
 }
 EXPORT_SYMBOL(register_fib_notifier);
 
 int unregister_fib_notifier(struct notifier_block *nb)
 {
-	return blocking_notifier_chain_unregister(&fib_chain, nb);
+	return atomic_notifier_chain_unregister(&fib_chain, nb);
 }
 EXPORT_SYMBOL(unregister_fib_notifier);
 
@@ -102,7 +102,7 @@ int call_fib_notifiers(struct net *net, enum fib_event_type event_type,
 		       struct fib_notifier_info *info)
 {
 	info->net = net;
-	return blocking_notifier_call_chain(&fib_chain, event_type, info);
+	return atomic_notifier_call_chain(&fib_chain, event_type, info);
 }
 
 static int call_fib_entry_notifiers(struct net *net,
-- 
2.7.4
