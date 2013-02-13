From: pablo@netfilter.org
Subject: [PATCH 1/3] netfilter: ctnetlink: don't permit ct creation with random tuple
Date: Wed, 13 Feb 2013 21:38:31 +0100
Message-ID: <1360787913-10335-2-git-send-email-pablo@netfilter.org>
References: <1360787913-10335-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1360787913-10335-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Userspace can cause kernel panic by not specifying orig/reply
tuple: kernel will create a tuple with random stack values.

Problem is that tuple.dst.dir will be random, too, which
causes nf_ct_tuplehash_to_ctrack() to return garbage.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@gnumonks.org>
---
 net/netfilter/nf_conntrack_netlink.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 627b0e5..a081915 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1705,6 +1705,9 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		if (nlh->nlmsg_flags & NLM_F_CREATE) {
 			enum ip_conntrack_events events;
 
+			if (!cda[CTA_TUPLE_ORIG] || !cda[CTA_TUPLE_REPLY])
+				return -EINVAL;
+
 			ct = ctnetlink_create_conntrack(net, zone, cda, &otuple,
 							&rtuple, u3);
 			if (IS_ERR(ct))
-- 
1.7.10.4

