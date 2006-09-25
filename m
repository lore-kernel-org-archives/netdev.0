From: Andrew Morton <akpm@osdl.org>
Subject: [patch] neighbour.c, pneigh_get_next() skips published entry
Date: Mon, 25 Sep 2006 16:45:35 -0700
Message-ID: <20060925164535.4245ee02.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jari Takkala <jari.takkala@q9.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:57013 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750943AbWIYXpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:45:39 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I've been sitting on this patch because afaik the problem which it purports
to fix remains unfixed.

Should I drop it??

Thanks.



From: "Jari Takkala" <Jari.Takkala@Q9.com>

Fix a problem where output from /proc/net/arp skips a record when the full
output does not fit into the users read() buffer.

To reproduce: publish a large number of ARP entries (more than 10 required
on my system).  Run 'dd if=/proc/net/arp of=arp-1024.out bs=1024'.  View
the output, one entry will be missing.

Signed-off-by: Jari Takkala <jari.takkala@q9.com>

[akpm: submitted before, discussion ended inconclusively, iirc]
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/core/neighbour.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff -puN net/core/neighbour.c~neighbourc-pneigh_get_next-skips-published-entry net/core/neighbour.c
--- a/net/core/neighbour.c~neighbourc-pneigh_get_next-skips-published-entry
+++ a/net/core/neighbour.c
@@ -2209,6 +2209,12 @@ static struct pneigh_entry *pneigh_get_n
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

