From: Roland Dreier <rdreier@cisco.com>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 14:58:23 -0800
Message-ID: <ada8wromu0g.fsf@cisco.com>
References: <1226494493.3016.3.camel@achroite>
	<20081112.134618.30673281.davem@davemloft.net>
	<1226526657.3016.10.camel@achroite>
	<20081112.142625.120012106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, jdb@comx.dk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:27860 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbYKLW6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 17:58:25 -0500
In-Reply-To: <20081112.142625.120012106.davem@davemloft.net> (David Miller's
	message of "Wed, 12 Nov 2008 14:26:25 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Just google "C order of evaluation" and you will get hundreds
 > of tables, and all of them will have an entry for "|" (not
 > just "||") which says that operands are evaluated left to
 > right.

You're talking about associativity, which says how an expression like
"a | b | c" is implicitly parenthesized.  The order of evaluation is
undefined -- in fact the C standard I have says:

  Except as specified later (for the function-call (), &&, ||, ?:, and
  comma operators), the order of evaluation of subexpressions and the
  order in which side effects take place are both unspecified.

So there is no rule about which subexpression is evaluated first in an
expression like "a | b".

 > And since these MMIO reads are volatile operations, there is
 > no way the compiler can execute them out of order.

"volatile" just means that accessing a volatile expression is considered
a side effect -- and side effects are only ordered with respect to
sequence points.

So according to my understanding of the C standard, there is no required
on which readl() is done first in an expression like "readl(a) | readl(b)".

 > And the plain truth is that no compiler does, and that is what
 > matters in the end.

I think it's cleaner to avoid relying on undefined behavior (eg gcc 4.5
will probably break things), especially when the fix is so simple --
something the following should work fine:

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 9acb5d7..1fb0d2f 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -51,8 +51,8 @@ MODULE_VERSION(DRV_MODULE_VERSION);
 #ifndef readq
 static u64 readq(void __iomem *reg)
 {
-	return (((u64)readl(reg + 0x4UL) << 32) |
-		(u64)readl(reg));
+	u64 v = readl(reg);
+	return v | (u64) readl(reg + 0x4UL) << 32;
 }
 
 static void writeq(u64 val, void __iomem *reg)
