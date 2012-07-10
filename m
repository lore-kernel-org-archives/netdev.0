From: David Miller <davem@davemloft.net>
Subject: Re: net-next kernel NULL pointer dereference at fib_rules_tclass
Date: Tue, 10 Jul 2012 09:44:28 -0700 (PDT)
Message-ID: <20120710.094428.1167234955738653678.davem@davemloft.net>
References: <alpine.LRH.2.00.1207101008270.9760@ogerlitz.voltaire.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shlomop@mellanox.com, amirv@mellanox.com,
	erezsh@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39137 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999Ab2GJQo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 12:44:29 -0400
In-Reply-To: <alpine.LRH.2.00.1207101008270.9760@ogerlitz.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 10 Jul 2012 10:16:55 +0300

> Starting system logger: BUG: unable to handle kernel NULL pointer dereference at 00000000000000ac
> IP: [<ffffffff81320393>] fib_rules_tclass+0xf/0x17

Ok, fib_rules_tclass() checks for res->r being NULL and only
dereferences it if it is not.

fib4_rule->tclassid has offset ~0x8c on x86-64, and this fault
address is 0x10 bytes off.

Does this patch fix the problem?

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 539c672..000c467 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -230,6 +230,7 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 			     struct fib_result *res)
 {
 	if (!net->ipv4.fib_has_custom_rules) {
+		res->r = NULL;
 		if (net->ipv4.fib_local &&
 		    !fib_table_lookup(net->ipv4.fib_local, flp, res,
 				      FIB_LOOKUP_NOREF))
