From: akpm@osdl.org
Subject: [patch 06/17] neighbour.c, pneigh_get_next() skips published entry
Date: Thu, 01 Jun 2006 20:32:26 -0700
Message-ID: <200606020328.k523S8hh028820@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, Jari.Takkala@Q9.com,
	jari.takkala@Q9.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60596 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751201AbWFBD2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:13 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: "Jari Takkala" <Jari.Takkala@Q9.com>

Fix a problem where output from /proc/net/arp skips a record when the full
output does not fit into the users read() buffer.

To reproduce: publish a large number of ARP entries (more than 10 required
on my system).  Run 'dd if=/proc/net/arp of=arp-1024.out bs=1024'.  View
the output, one entry will be missing.

Signed-off-by: Jari Takkala <jari.takkala@q9.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/core/neighbour.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff -puN net/core/neighbour.c~neighbourc-pneigh_get_next-skips-published-entry net/core/neighbour.c
--- devel/net/core/neighbour.c~neighbourc-pneigh_get_next-skips-published-entry	2006-06-01 20:31:49.000000000 -0700
+++ devel-akpm/net/core/neighbour.c	2006-06-01 20:31:49.000000000 -0700
@@ -2138,6 +2138,12 @@ static struct pneigh_entry *pneigh_get_n
 	struct neigh_seq_state *state = seq->private;
 	struct neigh_table *tbl = state->tbl;
 
+	if (pos != NULL && *pos == 1 &&
+			(pn->next || tbl->phash_buckets[state->bucket])) {
+		--(*pos);
+		return pn;
+	}
+
 	pn = pn->next;
 	while (!pn) {
 		if (++state->bucket > PNEIGH_HASHMASK)
_
