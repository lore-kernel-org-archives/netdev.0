From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] net: Fix the fib trie iterator to work with a single
 entry routing tables
Date: Fri, 26 Jan 2007 13:56:29 +0100
Message-ID: <17849.64125.710251.587076@robur.slu.se>
References: <m17ivc19na.fsf@ebiederm.dsl.xmission.com>
	<17847.54018.72176.431127@robur.slu.se>
	<20070124.144254.78492493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, ebiederm@xmission.com,
	netdev@vger.kernel.org, robert.olsson@its.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:35269 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752123AbXAZM4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 07:56:36 -0500
In-Reply-To: <20070124.144254.78492493.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David Miller writes:

 > > Yes the case when the trie is just a single leaf got wrong with the
 > > iterator and your patchs cures it. I think we have a similar problem
 > > with /proc/net/fib_trie
 > 
 > I'm happy to review a fix for that :-)
 
When main table is just a single leaf this gets printed as belonging to the 
local table in /proc/net/fib_trie. A fix is below.

Cheers.
						--ro


Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


--- net-2.6.20/net/ipv4/fib_trie.c.orig	2007-01-26 13:18:13.000000000 +0100
+++ net-2.6.20/net/ipv4/fib_trie.c	2007-01-26 13:19:36.000000000 +0100
@@ -2290,16 +2290,17 @@
 	if (v == SEQ_START_TOKEN)
 		return 0;
 
+	if (!NODE_PARENT(n)) {
+		if (iter->trie == trie_local)
+			seq_puts(seq, "<local>:\n");
+		else
+			seq_puts(seq, "<main>:\n");
+	} 
+
 	if (IS_TNODE(n)) {
 		struct tnode *tn = (struct tnode *) n;
 		__be32 prf = htonl(MASK_PFX(tn->key, tn->pos));
 
-		if (!NODE_PARENT(n)) {
-			if (iter->trie == trie_local)
-				seq_puts(seq, "<local>:\n");
-			else
-				seq_puts(seq, "<main>:\n");
-		} 
 		seq_indent(seq, iter->depth-1);
 		seq_printf(seq, "  +-- %d.%d.%d.%d/%d %d %d %d\n",
 			   NIPQUAD(prf), tn->pos, tn->bits, tn->full_children, 
 

 
