From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 5/5]IPv6:netfilter: Add IPSTATS_MIB_REASMFAILS
 MIB counter value when evicting fragment queue
Date: Wed, 24 Feb 2010 14:08:50 +0800
Message-ID: <4B84C272.1040505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, Shan Wei <shanwei@cn.fujitsu.com>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds MIB counter value about IPSTATS_MIB_REASMFAILS
if mem member of netns_frags exceeds high thresh, just like IPv4/v6 stack.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 32c5bbd..136b0de 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -113,9 +113,13 @@ static __inline__ void fq_kill(struct nf_ct_frag6_queue *fq)
 	inet_frag_kill(&fq->q, &nf_frags);
 }
 
-static void nf_ct_frag6_evictor(struct net *net)
+static void nf_ct_frag6_evictor(struct net *net, struct inet6_dev *idev)
 {
-	inet_frag_evictor(&net->ipv6.frags, &nf_frags);
+	int evicted;
+
+	evicted = inet_frag_evictor(&net->ipv6.frags, &nf_frags);
+	if (evicted)
+		IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_REASMFAILS, evicted);
 }
 
 static void nf_ct_frag6_expire(unsigned long data)
@@ -632,7 +636,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	}
 
 	if (atomic_read(&net->ipv6.frags.mem) > net->ipv6.frags.high_thresh)
-		nf_ct_frag6_evictor(net);
+		nf_ct_frag6_evictor(net, idev);
 
 	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr);
 	if (fq == NULL) {
-- 
1.6.3.3

