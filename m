From: Patrick McHardy <kaber@trash.net>
Subject: net 01/05: fib_rules: rearrange struct fib_rule
Date: Mon, 30 Nov 2009 18:55:31 +0100 (MET)
Message-ID: <20091130175531.7555.50079.sendpatchset@x2.localnet>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56501 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbZK3Rz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 12:55:27 -0500
In-Reply-To: <20091130175529.7555.10132.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 0d9a871c9888ef8f7a08531beaa69220edf4bea3
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Nov 30 15:45:49 2009 +0100

    net: fib_rules: rearrange struct fib_rule
    
    The ifname member is only used to resolve interface names and is not needed
    during rule lookups. The target and ctarget members however are used during
    rule lookups and are currently located in a second cacheline.
    
    Move ifname further to the end to make sure both target and ctarget are
    located in the same cacheline as other members used during rule lookups.
    
    The layout on 64 bit changes from:
    
    struct fib_rule {
    	...
            u32                        table;                /*    56     4 */
            u8                         action;               /*    60     1 */
    
            /* XXX 3 bytes hole, try to pack */
    
            /* --- cacheline 1 boundary (64 bytes) --- */
            u32                        target;               /*    64     4 */
    
            /* XXX 4 bytes hole, try to pack */
    
            struct fib_rule *          ctarget;              /*    72     8 */
            struct rcu_head            rcu;                  /*    80    16 */
            struct net *               fr_net;               /*    96     8 */
    };
    
    to:
    
    struct fib_rule {
    	...
            u32                        table;                /*    40     4 */
            u8                         action;               /*    44     1 */
    
            /* XXX 3 bytes hole, try to pack */
    
            u32                        target;               /*    48     4 */
    
            /* XXX 4 bytes hole, try to pack */
    
            struct fib_rule *          ctarget;              /*    56     8 */
            /* --- cacheline 1 boundary (64 bytes) --- */
            char                       ifname[16];           /*    64    16 */
            struct rcu_head            rcu;                  /*    80    16 */
            struct net *               fr_net;               /*    96     8 */
    
    };
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 2cd707b..22fb323 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -11,7 +11,6 @@ struct fib_rule {
 	struct list_head	list;
 	atomic_t		refcnt;
 	int			ifindex;
-	char			ifname[IFNAMSIZ];
 	u32			mark;
 	u32			mark_mask;
 	u32			pref;
@@ -20,6 +19,7 @@ struct fib_rule {
 	u8			action;
 	u32			target;
 	struct fib_rule *	ctarget;
+	char			ifname[IFNAMSIZ];
 	struct rcu_head		rcu;
 	struct net *		fr_net;
 };
