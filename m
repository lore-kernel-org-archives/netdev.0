From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] ip6_output: fragment outgoing reassembled skb properly
Date: Wed,  6 Nov 2013 17:52:19 +0100
Message-ID: <1383756740-7392-2-git-send-email-jiri@resnulli.us>
References: <1383756740-7392-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1383756740-7392-1-git-send-email-jiri@resnulli.us>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If reassembled packet would fit into outdev MTU, it is not fragmented
according the original frag size and it is send as single big packet.

The second case is if skb is gso. In that case fragmentation does not happen
according to the original frag size.

This patch fixes these.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv6/ip6_output.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 91fb4e8..5e31a90 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -125,7 +125,8 @@ static int ip6_finish_output2(struct sk_buff *skb)
 static int ip6_finish_output(struct sk_buff *skb)
 {
 	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
-	    dst_allfrag(skb_dst(skb)))
+	    dst_allfrag(skb_dst(skb)) ||
+	    (IP6CB(skb)->frag_max_size && skb->len > IP6CB(skb)->frag_max_size))
 		return ip6_fragment(skb, ip6_finish_output2);
 	else
 		return ip6_finish_output2(skb);
-- 
1.8.3.1

