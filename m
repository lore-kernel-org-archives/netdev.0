From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/3] netfilter: ebtables: Fix extension lookup with identical name
Date: Thu, 14 Apr 2016 00:54:54 +0200
Message-ID: <1460588094-3933-4-git-send-email-pablo@netfilter.org>
References: <1460588094-3933-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1460588094-3933-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Sutter <phil@nwl.cc>

If a requested extension exists as module and is not loaded,
ebt_check_match() might accidentally use an NFPROTO_UNSPEC one with same
name and fail.

Reproduced with limit match: Given xt_limit and ebt_limit both built as
module, the following would fail:

  modprobe xt_limit
  ebtables -I INPUT --limit 1/s -j ACCEPT

The fix is to make ebt_check_match() distrust a found NFPROTO_UNSPEC
extension and retry after requesting an appropriate module.

Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: Phil Sutter <phil@nwl.cc>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtables.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 8570bc7..5a61f35 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -370,7 +370,11 @@ ebt_check_match(struct ebt_entry_match *m, struct xt_mtchk_param *par,
 	    left - sizeof(struct ebt_entry_match) < m->match_size)
 		return -EINVAL;
 
-	match = xt_request_find_match(NFPROTO_BRIDGE, m->u.name, 0);
+	match = xt_find_match(NFPROTO_BRIDGE, m->u.name, 0);
+	if (IS_ERR(match) || match->family != NFPROTO_BRIDGE) {
+		request_module("ebt_%s", m->u.name);
+		match = xt_find_match(NFPROTO_BRIDGE, m->u.name, 0);
+	}
 	if (IS_ERR(match))
 		return PTR_ERR(match);
 	m->u.match = match;
-- 
2.1.4

