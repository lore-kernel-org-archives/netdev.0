From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netfilter: conntrack: remove uninitialized shadow variable
Date: Mon,  9 May 2016 21:47:23 +0200
Message-ID: <1462823254-3137116-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Sasha Levin <sasha.levin@oracle.com>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A recent commit introduced an unconditional use of an uninitialized
variable, as reported in this gcc warning:

net/netfilter/nf_conntrack_core.c: In function '__nf_conntrack_confirm':
net/netfilter/nf_conntrack_core.c:632:33: error: 'ctinfo' may be used uninitialized in this function [-Werror=maybe-uninitialized]
   bytes = atomic64_read(&counter[CTINFO2DIR(ctinfo)].bytes);
                                 ^
net/netfilter/nf_conntrack_core.c:628:26: note: 'ctinfo' was declared here
   enum ip_conntrack_info ctinfo;

The problem is that a local variable shadows the function parameter.
This removes the local variable, which looks like what Pablo originally
intended.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 71d8c47fc653 ("netfilter: conntrack: introduce clash resolution on insertion race")
---
 net/netfilter/nf_conntrack_core.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f58a70410c69..157ffa667395 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -625,7 +625,6 @@ static void nf_ct_acct_merge(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 	acct = nf_conn_acct_find(loser_ct);
 	if (acct) {
 		struct nf_conn_counter *counter = acct->counter;
-		enum ip_conntrack_info ctinfo;
 		unsigned int bytes;
 
 		/* u32 should be fine since we must have seen one packet. */
-- 
2.7.0
