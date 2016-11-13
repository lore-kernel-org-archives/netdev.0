From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/39] netfilter: conntrack: fix NF_REPEAT handling
Date: Sun, 13 Nov 2016 23:25:09 +0100
Message-ID: <1479075933-4491-16-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

gcc correctly identified a theoretical uninitialized variable use:

net/netfilter/nf_conntrack_core.c: In function 'nf_conntrack_in':
net/netfilter/nf_conntrack_core.c:1125:14: error: 'l4proto' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This could only happen when we 'goto out' before looking up l4proto,
and then enter the retry, implying that l3proto->get_l4proto()
returned NF_REPEAT. This does not currently get returned in any
code path and probably won't ever happen, but is not good to
rely on.

Moving the repeat handling up a little should have the same
behavior as today but avoids the warning by making that case
impossible to enter.

[ I have mangled this original patch to remove the check for tmpl, we
  should inconditionally jump back to the repeat label in case we hit
  NF_REPEAT instead. I have also moved the comment that explains this
  where it belongs. --pablo ]

Fixes: 08733a0cb7de ("netfilter: handle NF_REPEAT from nf_conntrack_in()")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index de4b8a75f30b..e9ffe33dc0ca 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1337,6 +1337,12 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		if (ret == -NF_DROP)
 			NF_CT_STAT_INC_ATOMIC(net, drop);
+		/* Special case: TCP tracker reports an attempt to reopen a
+		 * closed/aborted connection. We have to go back and create a
+		 * fresh conntrack.
+		 */
+		if (ret == -NF_REPEAT)
+			goto repeat;
 		ret = -ret;
 		goto out;
 	}
@@ -1344,16 +1350,8 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	if (set_reply && !test_and_set_bit(IPS_SEEN_REPLY_BIT, &ct->status))
 		nf_conntrack_event_cache(IPCT_REPLY, ct);
 out:
-	if (tmpl) {
-		/* Special case: TCP tracker reports an attempt to reopen a
-		 * closed/aborted connection. We have to go back and create a
-		 * fresh conntrack.
-		 */
-		if (ret == NF_REPEAT)
-			goto repeat;
-		else
-			nf_ct_put(tmpl);
-	}
+	if (tmpl)
+		nf_ct_put(tmpl);
 
 	return ret;
 }
-- 
2.1.4

