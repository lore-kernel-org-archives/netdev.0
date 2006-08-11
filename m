From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.18-rc3-mm2 - BUG in rt6_lookup() from ipv6_del_addr()
Date: Thu, 10 Aug 2006 21:20:40 -0700 (PDT)
Message-ID: <20060810.212040.133762526.davem@davemloft.net>
References: <20060806030809.2cfb0b1e.akpm@osdl.org>
	<200608110215.k7B2FQPu006243@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6859
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751225AbWHKEUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 00:20:32 -0400
To: Valdis.Kletnieks@vt.edu
In-Reply-To: <200608110215.k7B2FQPu006243@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valdis.Kletnieks@vt.edu
Date: Thu, 10 Aug 2006 22:15:26 -0400

> On Sun, 06 Aug 2006 03:08:09 PDT, Andrew Morton said:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc3/2.6.18-rc3-mm2/
> 
> After applying the patch that Patrick McHardy pointed me at, it lived
> longer.  However, I'm now seeing problems at system shutdown (or anytime
> you try to 'ifdown ethX' where ethX has an IPv6 address attached to it):

This is cured by yet another fix already in the net-2.6.19
tree:

>From 7a3a5e6b0e6847749c756cbe4bf554eda063a577 Mon Sep 17 00:00:00 2001
From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Tue, 8 Aug 2006 16:44:17 -0700
Subject: [PATCH] [IPV6]: Make sure fib6_rule_lookup doesn't return NULL

The callers of fib6_rule_lookup don't expect it to return NULL,
therefore it must return ip6_null_entry whenever fib_rule_lookup fails.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/fib6_rules.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index bf9bba8..22a2fdb 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -63,7 +63,11 @@ struct dst_entry *fib6_rule_lookup(struc
 	if (arg.rule)
 		fib_rule_put(arg.rule);
 
-	return (struct dst_entry *) arg.result;
+	if (arg.result)
+		return (struct dst_entry *) arg.result;
+
+	dst_hold(&ip6_null_entry.u.dst);
+	return &ip6_null_entry.u.dst;
 }
 
 static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
-- 
1.4.2.rc2.g3e042


