From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 7/7 v2]IPv6:netfilter: Add IPSTATS_MIB_REASMFAILS
 MIB counter value when evicting fragment queue
Date: Sat, 27 Feb 2010 14:40:14 +0800
Message-ID: <4B88BE4E.3000308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.o
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53904 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753809Ab0B0GkP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 01:40:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds MIB counter value about IPSTATS_MIB_REASMFAILS
if mem member of netns_frags exceeds high thresh, just like IPv4/v6 stack.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index fc97a68..501aca7 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -200,9 +200,13 @@ static __inline__ void fq_kill(struct nf_ct_frag6_queue *fq)
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
@@ -712,7 +716,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	fhdr = (struct frag_hdr *)skb_transport_header(clone);
 
 	if (atomic_read(&net->ipv6.frags.mem) > net->ipv6.frags.high_thresh)
-		nf_ct_frag6_evictor(net);
+		nf_ct_frag6_evictor(net, idev);
 
 	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr);
 	if (fq == NULL) {
-- 
1.6.3.3
