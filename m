From: "Jari Takkala" <Jari.Takkala@Q9.com>
Subject: [PATCH] neighbour.c, pneigh_get_next() skips published entry
Date: Thu, 11 May 2006 12:29:07 -0400
Message-ID: <413FEEF1743111439393FB76D0221E48046920E0@leopard.zoo.q9networks.com>
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.q9.com ([216.220.35.253]:695 "EHLO mx2.q9.com")
	by vger.kernel.org with ESMTP id S1750742AbWEKQ3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 12:29:09 -0400
Content-class: urn:content-classes:message
To: <linux-kernel@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patch fixes a problem where output from /proc/net/arp
skips a record when the full output does not fit into the users read()
buffer.

To reproduce: publish a large number of ARP entries (more than 10
required on my system). Run 'dd if=/proc/net/arp of=arp-1024.out
bs=1024'. View the output, one entry will be missing.

Please review and commit if acceptable.

Signed-off-by: Jari Takkala <jari.takkala@q9.com>

--- linux-2.6.16.15.orig/net/core/neighbour.c   2006-05-09
15:53:30.000000000 -0400
+++ linux-2.6.16.15/net/core/neighbour.c        2006-05-10
16:06:40.000000000 -0400
@@ -2120,6 +2120,11 @@
        struct neigh_seq_state *state = seq->private;
        struct neigh_table *tbl = state->tbl;

+       if (pos != NULL && *pos == 1 && (pn->next ||
tbl->phash_buckets[state->bucket])) {
+               --(*pos);
+               return pn;
+       }
+
        pn = pn->next;
        while (!pn) {
                if (++state->bucket > PNEIGH_HASHMASK)

