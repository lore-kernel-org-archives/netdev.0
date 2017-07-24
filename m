From: Stefano Brivio <sbrivio@redhat.com>
Subject: [PATCH net] ipv6: Don't increase IPSTATS_MIB_FRAGFAILS twice in ip6_fragment()
Date: Mon, 24 Jul 2017 23:14:28 +0200
Message-ID: <2b9ed84e722e2654d33e0b57faf985108b452a5f.1500930781.git.sbrivio@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38878 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932727AbdGXVOe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 17:14:34 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7902C80477
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 21:14:34 +0000 (UTC)
Received: from elisabeth.redhat.com (unknown [10.36.112.12])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B466E17F33
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 21:14:33 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 2465 defines ipv6IfStatsOutFragFails as:

	"The number of IPv6 datagrams that have been discarded
	 because they needed to be fragmented at this output
	 interface but could not be."

The existing implementation, instead, would increase the counter
twice in case we fail to allocate room for single fragments:
once for the fragment, once for the datagram.

This didn't look intentional though. In one of the two affected
affected failure paths, the double increase was simply a result
of a new 'goto fail' statement, introduced to avoid a skb leak.
The other path appears to be affected since at least 2.6.12-rc2.

Reported-by: Sabrina Dubroca <sdubroca@redhat.com>
Fixes: 1d325d217c7f ("ipv6: ip6_fragment: fix headroom tests and skb leak")
Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
---
 net/ipv6/ip6_output.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1422d6c08377..162efba0d0cd 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -673,8 +673,6 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		*prevhdr = NEXTHDR_FRAGMENT;
 		tmp_hdr = kmemdup(skb_network_header(skb), hlen, GFP_ATOMIC);
 		if (!tmp_hdr) {
-			IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
-				      IPSTATS_MIB_FRAGFAILS);
 			err = -ENOMEM;
 			goto fail;
 		}
@@ -789,8 +787,6 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		frag = alloc_skb(len + hlen + sizeof(struct frag_hdr) +
 				 hroom + troom, GFP_ATOMIC);
 		if (!frag) {
-			IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
-				      IPSTATS_MIB_FRAGFAILS);
 			err = -ENOMEM;
 			goto fail;
 		}
-- 
2.9.4
