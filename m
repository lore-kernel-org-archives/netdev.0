From: kaber@trash.net
Subject: [PATCH 6/6] netfilter: nf_conntrack_defrag: check socket type before touching nodefrag flag
Date: Wed, 22 Sep 2010 09:17:34 +0200
Message-ID: <1285139854-11827-7-git-send-email-kaber@trash.net>
References: <1285139854-11827-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1285139854-11827-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Olsa <jolsa@redhat.com>

we need to check proper socket type within ipv4_conntrack_defrag
function before referencing the nodefrag flag.

For example the tun driver receive path produces skbs with
AF_UNSPEC socket type, and so current code is causing unwanted
fragmented packets going out.

Signed-off-by: Jiri Olsa <jolsa@redhat.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_defrag_ipv4.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index eab8de3..f3a9b42 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -66,9 +66,11 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 					  const struct net_device *out,
 					  int (*okfn)(struct sk_buff *))
 {
+	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(skb->sk);
 
-	if (inet && inet->nodefrag)
+	if (sk && (sk->sk_family == PF_INET) &&
+	    inet->nodefrag)
 		return NF_ACCEPT;
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-- 
1.7.1

