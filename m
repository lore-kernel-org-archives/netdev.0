From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] ipv4: route: fix inet_rtm_getroute induced crash
Date: Mon, 14 Aug 2017 00:52:58 +0200
Message-ID: <20170813225258.16001-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Ahern <dsahern@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:57598 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750714AbdHMWwn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 18:52:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"ip route get $daddr iif eth0 from $saddr" causes:
 BUG: KASAN: use-after-free in ip_route_input_rcu+0x1535/0x1b50
 Call Trace:
  ip_route_input_rcu+0x1535/0x1b50
  ip_route_input_noref+0xf9/0x190
  tcp_v4_early_demux+0x1a4/0x2b0
  ip_rcv+0xbcb/0xc05
  __netif_receive_skb+0x9c/0xd0
  netif_receive_skb_internal+0x5a8/0x890

Problem is that inet_rtm_getroute calls either ip_route_input_rcu (if an
iif was provided) or ip_route_output_key_hash_rcu.

But ip_route_input_rcu, unlike ip_route_output_key_hash_rcu, already
associates the dst_entry with the skb.  This clears the SKB_DST_NOREF
bit (i.e. skb_dst_drop will release/free the entry while it should not).

Thus only set the dst if we called ip_route_output_key_hash_rcu().

I tested this patch by running:
 while true;do ip r get 10.0.1.2;done > /dev/null &
 while true;do ip r get 10.0.1.2 iif eth0  from 10.0.1.1;done > /dev/null &
... and saw no crash or memory leak.

Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
Cc: David Ahern <dsahern@gmail.com>
Fixes: ba52d61e0ff ("ipv4: route: restore skb_dst_set in inet_rtm_getroute")
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0383e66f59bc..7effa62beed3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2750,12 +2750,13 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		err = 0;
 		if (IS_ERR(rt))
 			err = PTR_ERR(rt);
+		else
+			skb_dst_set(skb, &rt->dst);
 	}
 
 	if (err)
 		goto errout_free;
 
-	skb_dst_set(skb, &rt->dst);
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-- 
2.13.0
