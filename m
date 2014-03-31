From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: some ipv6 statistic counters failed to disable bh
Date: Mon, 31 Mar 2014 20:14:10 +0200
Message-ID: <20140331181410.GC24150@order.stressinduktion.org>
References: <CAOMZO5DQ3dNB-R5rsd2X89XLbg_VYs7za8xQT2K-bWWmFS=YHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, eric.dumazet@gmail.com
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42564 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569AbaCaSOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 14:14:11 -0400
Content-Disposition: inline
In-Reply-To: <CAOMZO5DQ3dNB-R5rsd2X89XLbg_VYs7za8xQT2K-bWWmFS=YHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit c15b1ccadb323ea ("ipv6: move DAD and addrconf_verify
processing to workqueue") some counters are now updated in process context
and thus need to disable bh before doing so, otherwise deadlocks can
happen on 32-bit archs. Fabio Estevam noticed this while while mounting
a NFS volume on an ARM board.

As a compensation for missing this I looked after the other *_STATS_BH
and found three other calls which need updating:

1) icmp6_send: ip6_fragment -> icmpv6_send -> icmp6_send (error handling)
2) ip6_push_pending_frames: rawv6_sendmsg -> rawv6_push_pending_frames -> ...
   (only in case of icmp protocol with raw sockets in error handling)
3) ping6_v6_sendmsg (error handling)

Fixes: c15b1ccadb323ea ("ipv6: move DAD and addrconf_verify processing to workqueue")
Reported-by: Fabio Estevam <festevam@gmail.com>
Tested-by: Fabio Estevam <fabio.estevam@freescale.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

I would propose this patch for -stable, too.

Thanks!

 net/ipv6/icmp.c       |  2 +-
 net/ipv6/ip6_output.c |  4 ++--
 net/ipv6/mcast.c      | 11 ++++++-----
 net/ipv6/ping.c       |  4 ++--
 4 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index f2610e1..7b32652 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -520,7 +520,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 			      np->tclass, NULL, &fl6, (struct rt6_info *)dst,
 			      MSG_DONTWAIT, np->dontfrag);
 	if (err) {
-		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTERRORS);
+		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
 	} else {
 		err = icmpv6_push_pending_frames(sk, &fl6, &tmp_hdr,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 64d6073..3702d17 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1566,8 +1566,8 @@ int ip6_push_pending_frames(struct sock *sk)
 	if (proto == IPPROTO_ICMPV6) {
 		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
-		ICMP6MSGOUT_INC_STATS_BH(net, idev, icmp6_hdr(skb)->icmp6_type);
-		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
+		ICMP6MSGOUT_INC_STATS(net, idev, icmp6_hdr(skb)->icmp6_type);
+		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
 	}
 
 	err = ip6_local_out(skb);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index e1e4735..08b367c 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1620,11 +1620,12 @@ static void mld_sendpack(struct sk_buff *skb)
 		      dst_output);
 out:
 	if (!err) {
-		ICMP6MSGOUT_INC_STATS_BH(net, idev, ICMPV6_MLD2_REPORT);
-		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
-		IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_OUTMCAST, payload_len);
-	} else
-		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTDISCARDS);
+		ICMP6MSGOUT_INC_STATS(net, idev, ICMPV6_MLD2_REPORT);
+		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
+		IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUTMCAST, payload_len);
+	} else {
+		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
+	}
 
 	rcu_read_unlock();
 	return;
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 587bbdc..bda7429 100644
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
1.9.0
