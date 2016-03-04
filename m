From: Bill Sommerfeld <wsommerfeld@google.com>
Subject: [PATCH] udp6: fix UDP/IPv6 encap resubmit path
Date: Fri,  4 Mar 2016 14:47:21 -0800
Message-ID: <1457131641-79311-1-git-send-email-wsommerfeld@google.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Josh Hunt <johunt@akamai.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Bill Sommerfeld <wsommerfeld@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPv4 interprets a negative return value from a protocol handler as a
request to redispatch to a new protocol.  In contrast, IPv6 interprets a
negative value as an error, and interprets a positive value as a request
for redispatch.

UDP for IPv6 was unaware of this difference.  Change __udp6_lib_rcv() to
return a positive value for redispatch.  Note that the socket's
encap_rcv hook still needs to return a negative value to request
dispatch, and in the case of IPv6 packets, adjust IP6CB(skb)->nhoff to
identify the byte containing the next protocol.

Signed-off-by: Bill Sommerfeld <wsommerfeld@google.com>
---
 net/ipv6/udp.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 0711f8f..fd25e44 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -922,11 +922,9 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		ret = udpv6_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
-		/* a return value > 0 means to resubmit the input, but
-		 * it wants the return to be -protocol, or 0
-		 */
+		/* a return value > 0 means to resubmit the input */
 		if (ret > 0)
-			return -ret;
+			return ret;
 
 		return 0;
 	}
-- 
2.7.0.rc3.207.g0ac5344
