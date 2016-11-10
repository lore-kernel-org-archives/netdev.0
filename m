From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/14] netfilter: ip_vs_sync: fix bogus maybe-uninitialized warning
Date: Thu, 10 Nov 2016 01:23:40 +0100
Message-ID: <1478737427-1574-8-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

Building the ip_vs_sync code with CONFIG_OPTIMIZE_INLINING on x86
confuses the compiler to the point where it produces a rather
dubious warning message:

net/netfilter/ipvs/ip_vs_sync.c:1073:33: error: ‘opt.init_seq’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
  struct ip_vs_sync_conn_options opt;
                                 ^~~
net/netfilter/ipvs/ip_vs_sync.c:1073:33: error: ‘opt.delta’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
net/netfilter/ipvs/ip_vs_sync.c:1073:33: error: ‘opt.previous_delta’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
net/netfilter/ipvs/ip_vs_sync.c:1073:33: error: ‘*((void *)&opt+12).init_seq’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
net/netfilter/ipvs/ip_vs_sync.c:1073:33: error: ‘*((void *)&opt+12).delta’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
net/netfilter/ipvs/ip_vs_sync.c:1073:33: error: ‘*((void *)&opt+12).previous_delta’ may be used uninitialized in this function [-Werror=maybe-uninitialized]

The problem appears to be a combination of a number of factors, including
the __builtin_bswap32 compiler builtin being slightly odd, having a large
amount of code inlined into a single function, and the way that some
functions only get partially inlined here.

I've spent way too much time trying to work out a way to improve the
code, but the best I've come up with is to add an explicit memset
right before the ip_vs_seq structure is first initialized here. When
the compiler works correctly, this has absolutely no effect, but in the
case that produces the warning, the warning disappears.

In the process of analysing this warning, I also noticed that
we use memcpy to copy the larger ip_vs_sync_conn_options structure
over two members of the ip_vs_conn structure. This works because
the layout is identical, but seems error-prone, so I'm changing
this in the process to directly copy the two members. This change
seemed to have no effect on the object code or the warning, but
it deals with the same data, so I kept the two changes together.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_sync.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 1b07578bedf3..9350530c16c1 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -283,6 +283,7 @@ struct ip_vs_sync_buff {
  */
 static void ntoh_seq(struct ip_vs_seq *no, struct ip_vs_seq *ho)
 {
+	memset(ho, 0, sizeof(*ho));
 	ho->init_seq       = get_unaligned_be32(&no->init_seq);
 	ho->delta          = get_unaligned_be32(&no->delta);
 	ho->previous_delta = get_unaligned_be32(&no->previous_delta);
@@ -917,8 +918,10 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 			kfree(param->pe_data);
 	}
 
-	if (opt)
-		memcpy(&cp->in_seq, opt, sizeof(*opt));
+	if (opt) {
+		cp->in_seq = opt->in_seq;
+		cp->out_seq = opt->out_seq;
+	}
 	atomic_set(&cp->in_pkts, sysctl_sync_threshold(ipvs));
 	cp->state = state;
 	cp->old_state = cp->state;
-- 
2.1.4

