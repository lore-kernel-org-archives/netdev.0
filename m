From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/2] [nf-next] netfilter: fix NF_REPEAT handling
Date: Tue,  8 Nov 2016 14:28:19 +0100
Message-ID: <20161108132914.1495283-2-arnd@arndb.de>
References: <20161108132914.1495283-1-arnd@arndb.de>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161108132914.1495283-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Fixes: 08733a0cb7de ("netfilter: handle NF_REPEAT from nf_conntrack_in()")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
The patch causing this is currently only in nf-next, and not yet
in net-next.
---
 net/netfilter/nf_conntrack_core.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index de4b8a75f30b..610c9de0ce18 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1337,6 +1337,8 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		if (ret == -NF_DROP)
 			NF_CT_STAT_INC_ATOMIC(net, drop);
+		if (ret == -NF_REPEAT && tmpl)
+			goto repeat;
 		ret = -ret;
 		goto out;
 	}
@@ -1349,10 +1351,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		 * closed/aborted connection. We have to go back and create a
 		 * fresh conntrack.
 		 */
-		if (ret == NF_REPEAT)
-			goto repeat;
-		else
-			nf_ct_put(tmpl);
+		nf_ct_put(tmpl);
 	}
 
 	return ret;
-- 
2.9.0
