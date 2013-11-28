From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] inet: further fixes of possible seqlock deadlocks
Date: Thu, 28 Nov 2013 20:22:31 +0100
Message-ID: <20131128192231.GE24171@order.stressinduktion.org>
References: <13025162.118881385612276530.JavaMail.weblogic@epv6ml01> <1385659390.5352.20.camel@edumazet-glaptop2.roam.corp.google.com> <1385661082.5352.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jongman.heo@samsung.com, David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1385661082.5352.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes more incorrect uses of *_STATS_BH in process context.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/udp.c        | 8 ++++----
 net/ipv6/ip6_output.c | 8 ++++----
 net/ipv6/ping.c       | 4 ++--
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 44e3884..f5cc018 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1160,10 +1160,10 @@ static unsigned int first_packet_length(struct sock *sk)
 	spin_lock_bh(&rcvq->lock);
 	while ((skb = skb_peek(rcvq)) != NULL &&
 		udp_lib_checksum_complete(skb)) {
-		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS,
-				 IS_UDPLITE(sk));
-		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
-				 IS_UDPLITE(sk));
+		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_CSUMERRORS,
+				   IS_UDPLITE(sk));
+		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS,
+				   IS_UDPLITE(sk));
 		atomic_inc(&sk->sk_drops);
 		__skb_unlink(skb, rcvq);
 		__skb_queue_tail(&list_kill, skb);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 59df872..e05cf0a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -116,8 +116,8 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	}
 	rcu_read_unlock_bh();
 
-	IP6_INC_STATS_BH(dev_net(dst->dev),
-			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
+	IP6_INC_STATS(dev_net(dst->dev),
+		      ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
 	return -EINVAL;
 }
@@ -1524,8 +1524,8 @@ int ip6_push_pending_frames(struct sock *sk)
 	if (proto == IPPROTO_ICMPV6) {
 		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
-		ICMP6MSGOUT_INC_STATS_BH(net, idev, icmp6_hdr(skb)->icmp6_type);
-		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
+		ICMP6MSGOUT_INC_STATS(net, idev, icmp6_hdr(skb)->icmp6_type);
+		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
 	}
 
 	err = ip6_local_out(skb);
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index a83243c..3a1f1f3 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -182,8 +182,8 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			      MSG_DONTWAIT, np->dontfrag);
 
 	if (err) {
-		ICMP6_INC_STATS_BH(sock_net(sk), rt->rt6i_idev,
-				   ICMP6_MIB_OUTERRORS);
+		ICMP6_INC_STATS(sock_net(sk), rt->rt6i_idev,
+				ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
 	} else {
 		err = icmpv6_push_pending_frames(sk, &fl6,
-- 
1.8.3.1
