From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 04/13] Don't do the UDP socket lookup if we already have
	one attached
Date: Mon, 05 Mar 2007 16:45:31 +0100
Message-ID: <20070305154531.3471.11197.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:1074 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933535AbXCEPpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:45:32 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id D9B9A294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:45:31 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

UDP input code path looks up the UDP socket hash tables to find a
socket matching the incoming packet. However, as iptable_tproxy does
socket lookups early the skb may already have the appropriate
reference attached, in that case we steal that reference instead of
doing the lookup.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 net/ipv4/udp.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ce6c460..1d15edc 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1226,8 +1226,15 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	if(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
 
-	sk = __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
-			       skb->dev->ifindex, udptable        );
+	if (skb->sk) {
+		/* steal reference */
+		sk = skb->sk;
+		skb->destructor = NULL;
+		skb->sk = NULL;
+	} else {
+		sk = __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
+				       skb->dev->ifindex, udptable        );
+	}
 
 	if (sk != NULL) {
 		int ret = udp_queue_rcv_skb(sk, skb);

