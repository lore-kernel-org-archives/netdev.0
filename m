From: Zhang Le <r0bertz@gentoo.org>
Subject: [PATCH] ipv4: mitigate an integer underflow when comparing tcp timestamps
Date: Sun, 14 Nov 2010 15:35:56 +0800
Message-ID: <1289720156-30118-1-git-send-email-r0bertz@gentoo.org>
Cc: Zhang Le <r0bertz@gentoo.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Behind a loadbalancer which does NAT, peer->tcp_ts could be much smaller than
req->ts_recent. In this case, theoretically the req should not be ignored.

But in fact, it could be ignored, if peer->tcp_ts is so small that the
difference between this two number is larger than 2 to the power of 31.

I understand that under this situation, timestamp does not make sense any more,
because it actually comes from difference machines. However, if anyone
ever need to do the same investigation which I have done, this will
save some time for him.

Signed-off-by: Zhang Le <r0bertz@gentoo.org>
---
 net/ipv4/tcp_ipv4.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8f8527d..1eb4974 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1352,8 +1352,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		    peer->v4daddr == saddr) {
 			inet_peer_refcheck(peer);
 			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
-			    (s32)(peer->tcp_ts - req->ts_recent) >
-							TCP_PAWS_WINDOW) {
+			    ((s32)(peer->tcp_ts - req->ts_recent) > TCP_PAWS_WINDOW &&
+			     peer->tcp_ts > req->ts_recent)) {
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
 				goto drop_and_release;
 			}
-- 
1.7.3.2
