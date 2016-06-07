From: Su Xuemin <suxm@chinanetcenter.com>
Subject: [PATCH] udp reuseport: fix packet of same flow hashed to different socket
Date: Tue,  7 Jun 2016 21:54:47 +0800
Message-ID: <1465307687-23211-1-git-send-email-suxm@chinanetcenter.com>
Cc: linux-kernel@vger.kernel.org, suxm@chinanetcenter.com
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Su, Xuemin" <suxm@chinanetcenter.com>

There is a corner case in which udp packets belonging to a same
flow are hashed to different socket when hslot->count changes from 10
to 11:

1) When hslot->count <= 10, __udp_lib_lookup() searches udp_table->hash,
and always passes 'daddr' to udp_ehashfn().

2) When hslot->count > 10, __udp_lib_lookup() searches udp_table->hash2,
but may pass 'INADDR_ANY' to udp_ehashfn() if the sockets are bound to
INADDR_ANY instead of some specific addr.

That means when hslot->count changes from 10 to 11, the hash calculated by
udp_ehashfn() is also changed, and the udp packets belonging to a same
flow will be hashed to different socket.

This is easily reproduced:
1) Create 10 udp sockets and bind all of them to 0.0.0.0:40000.
2) From the same host send udp packets to 127.0.0.1:40000, record the
socket index which receives the packets.
3) Create 1 more udp socket and bind it to 0.0.0.0:44096. The number 44096
is 40000 + UDP_HASH_SIZE(4096), this makes the new socket put into the
same hslot as the aformentioned 10 sockets, and makes the hslot->count
change from 10 to 11.
4) From the same host send udp packets to 127.0.0.1:40000, and the socket
index which receives the packets will be different from the one received
in step 2.
This should not happen as the socket bound to 0.0.0.0:44096 should not
change the behavior of the sockets bound to 0.0.0.0:40000.

The fix here is that when searching udp_table->hash, if the socket
supports reuseport, pass inet_sk(sk)->inet_rcv_saddr to udp_ehashfn()
instead of daddr. When the sockets are bound to some specific addr,
inet_sk(sk)->inet_rcv_saddr should equal to daddr, and when the sockets
are bould to INADDR_ANY, this will pass INADDR_ANY to udp_ehashfn() as
what is done when searching udp_table->hash2.

Signed-off-by: Su, Xuemin <suxm@chinanetcenter.com>
---
 net/ipv4/udp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d56c055..57c38f6 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -577,7 +577,9 @@ begin:
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				hash = udp_ehashfn(net, daddr, hnum,
+				hash = udp_ehashfn(net,
+						   inet_sk(sk)->inet_rcv_saddr,
+						   hnum,
 						   saddr, sport);
 				result = reuseport_select_sock(sk, hash, skb,
 							sizeof(struct udphdr));
-- 
1.8.3.1
