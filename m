From: Arnd Bergmann <arnd@arndb.de>
Subject: [net-next PATCH] ipv6: fix false-postive maybe-uninitialized warning
Date: Fri, 18 Aug 2017 13:34:22 +0200
Message-ID: <20170818113434.3037484-1-arnd@arndb.de>
Cc: Florian Westphal <fw@strlen.de>, Arnd Bergmann <arnd@arndb.de>,
        David Ahern <dsahern@gmail.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Wei Wang <weiwan@google.com>,
        WANG Cong <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding a lock around one of the assignments prevents gcc from
tracking the state of the local 'fibmatch' variable, so it can no
longer prove that 'dst' is always initialized, leading to a bogus
warning:

net/ipv6/route.c: In function 'inet6_rtm_getroute':
net/ipv6/route.c:3659:2: error: 'dst' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This moves the other assignment into the same lock to shut up the
warning.

Fixes: 121622dba8da ("ipv6: route: make rtm_getroute not assume rtnl is locked")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/ipv6/route.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

This kind of warning involving an unlock between variable initialization
and use is relatively frequent for false-positives. I should try to
seek clarification from the gcc developers on whether this can be
improved.

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index dc021ed6dd37..bec12ae3e6b7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3624,6 +3624,8 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 
 		if (!fibmatch)
 			dst = ip6_route_input_lookup(net, dev, &fl6, flags);
+		else
+			dst = ip6_route_lookup(net, &fl6, 0);
 
 		rcu_read_unlock();
 	} else {
@@ -3631,10 +3633,10 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 
 		if (!fibmatch)
 			dst = ip6_route_output(net, NULL, &fl6);
+		else
+			dst = ip6_route_lookup(net, &fl6, 0);
 	}
 
-	if (fibmatch)
-		dst = ip6_route_lookup(net, &fl6, 0);
 
 	rt = container_of(dst, struct rt6_info, dst);
 	if (rt->dst.error) {
-- 
2.9.0
