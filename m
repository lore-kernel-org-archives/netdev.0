From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fake rtable dst patch applied but kernel keeps panicing
Date: Thu, 19 Apr 2012 10:45:08 +0200
Message-ID: <1334825108.2395.28.camel@edumazet-glaptop>
References: <4F8E9291.9000607@navynet.it>
	 <1334745072.2472.110.camel@edumazet-glaptop>  <4F8FC66F.90703@navynet.it>
	 <1334823256.2395.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Massimo Cetra <ctrix+debianbugs@navynet.it>,
	netdev@vger.kernel.org, peter.huangpeng@huawei.com
To: Massimo Cetra <mcetra@navynet.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:65011 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab2DSIpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 04:45:13 -0400
Received: by bkcik5 with SMTP id ik5so6121455bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 01:45:12 -0700 (PDT)
In-Reply-To: <1334823256.2395.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 10:14 +0200, Eric Dumazet wrote:
> On Thu, 2012-04-19 at 10:01 +0200, Massimo Cetra wrote:
> > On 18/04/2012 12:31, Eric Dumazet wrote:
> > >
> > > Seems a different issue, skb->nf_bridge seems to be NULL
> > >
> > 
> > This is another trace of another panic.
> > I hope it may be useful.
> > Please notice that it is not related to adding/removing br interfaces or 
> > tun/vic interfaces from a bridge set.
> > It happened suddenly during a normal workload.
> > 
> > When were those bridge-related bugs introduced ?
> > What's the latest release that seems to work ?
> > I'm asking so that i can restore some servers to a proper workload.
> > 
> > 
> > Massimo
> 
> Maybe you should try latest kernel, because we fixed some bugs lately.
> 
> 

Oh well, at first glance nf_bridge_unshare() is buggy, not sure if this
can help your bug, but its another step.


[PATCH] bridge: fix nf_bridge_unshare()

If memory allocation failed, return an error.

If not, skb->nf_bridge should be updated to point to the copy, not old
info, or bad things can happen.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/bridge/br_netfilter.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index dec4f38..b7c2cec 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -185,21 +185,20 @@ static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
 	return skb->nf_bridge;
 }
 
-static inline struct nf_bridge_info *nf_bridge_unshare(struct sk_buff *skb)
+
+static inline int nf_bridge_unshare(struct sk_buff *skb)
 {
-	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct nf_bridge_info *copy, *nf_bridge = skb->nf_bridge;
 
 	if (atomic_read(&nf_bridge->use) > 1) {
-		struct nf_bridge_info *tmp = nf_bridge_alloc(skb);
-
-		if (tmp) {
-			memcpy(tmp, nf_bridge, sizeof(struct nf_bridge_info));
-			atomic_set(&tmp->use, 1);
-		}
+		copy = kmemdup(nf_bridge, sizeof(*nf_bridge), GFP_ATOMIC);
+		if (!copy)
+			return -ENOMEM;
+		atomic_set(&copy->use, 1);
 		nf_bridge_put(nf_bridge);
-		nf_bridge = tmp;
+		skb->nf_bridge = copy;
 	}
-	return nf_bridge;
+	return 0;
 }
 
 static inline void nf_bridge_push_encap_header(struct sk_buff *skb)
@@ -744,8 +743,9 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 	/* Need exclusive nf_bridge_info since we might have multiple
-	 * different physoutdevs. */
-	if (!nf_bridge_unshare(skb))
+	 * different physoutdevs.
+	 */
+	if (nf_bridge_unshare(skb))
 		return NF_DROP;
 
 	parent = bridge_parent(out);
