From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] Fix "ip rule delete table 256"
Date: Thu, 7 Nov 2013 18:26:38 +0100
Message-ID: <20131107172638.GA6110@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@networkplumber.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h32.telenor.se ([213.150.131.5]:33463 "EHLO
	smtprelay-h32.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123Ab3KGR4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 12:56:46 -0500
Received: from ipb4.telenor.se (ipb4.telenor.se [195.54.127.167])
	by smtprelay-h32.telenor.se (Postfix) with ESMTP id 7B3BDE96CF
	for <netdev@vger.kernel.org>; Thu,  7 Nov 2013 18:34:27 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When trying to delete a table >= 256 using iproute2 the local table
will be deleted.
The table id is specified as a netlink attribute when it needs more then
8 bits and iproute2 then sets the table field to RT_TABLE_UNSPEC (0).
Preconditions to matching the table id in the rule delete code
doesn't seem to take the "table id in netlink attribute" into condition
so the frh_get_table helper function never gets to do its job when
matching against current rule.
Use the helper function twice instead of peaking at the table value directly.

Originally reported at: http://bugs.debian.org/724783

Reported-by: Nicolas HICHER <nhicher@avencall.com>
Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 net/core/fib_rules.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

An alternative would be to say RT_TABLE_UNSPEC is incorrect value
to use for the rule->table when using the netlink attribute and
change iproute2 instead....
... but RT_TABLE_UNSPEC sounds quite suitable, so why not
change the kernel to be more forgiving.

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 2e65413..f409e0b 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -460,7 +460,8 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 		if (frh->action && (frh->action != rule->action))
 			continue;
 
-		if (frh->table && (frh_get_table(frh, tb) != rule->table))
+		if (frh_get_table(frh, tb) &&
+		    (frh_get_table(frh, tb) != rule->table))
 			continue;
 
 		if (tb[FRA_PRIORITY] &&
-- 
1.8.4.2
