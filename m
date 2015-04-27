From: "Gerd v. Egidy" <gerd.von.egidy@intra2net.com>
Subject: [bisected] ICMP fragmentation needed ignored / PMTU discovery broken since 3.19-rc7
Date: Mon, 27 Apr 2015 14:33:14 +0200
Message-ID: <1508242.C2rIQlqbSL@thunder>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Li Wei <lw@cn.fujitsu.com>, "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:34131 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932517AbbD0Mim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 08:38:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

my colleagues recently reported that they had spurious problems connecting
to a specific server via ssh. Investigation showed that the kernel completely 
ignored the ICMP dest. unreachable / fragmentation needed packets in this case:

client.45662 > server.22: Flags [S], seq 3738194662, win 29200, options [mss 1460,sackOK,TS val 668602 ecr 0,nop,wscale 7], length 0
server.22 > client.45662: Flags [S.], seq 2215869953, ack 3738194663, win 5792, options [mss 1460,sackOK,TS val 2974105033 ecr 668602,nop,wscale 6], length 0
client.45662 > server.22: Flags [.], ack 1, win 229, options [nop,nop,TS val 668621 ecr 2974105033], length 0
client.45662 > server.22: Flags [P.], seq 1:22, ack 1, win 229, options [nop,nop,TS val 668626 ecr 2974105033], length 21
server.22 > client.45662: Flags [.], ack 22, win 91, options [nop,nop,TS val 2974105057 ecr 668626], length 0
server.22 > client.45662: Flags [P.], seq 1:21, ack 22, win 91, options [nop,nop,TS val 2974105069 ecr 668626], length 20
client.45662 > server.22: Flags [.], ack 21, win 229, options [nop,nop,TS val 668657 ecr 2974105069], length 0
client.45662 > server.22: Flags [.], seq 22:1470, ack 21, win 229, options [nop,nop,TS val 668658 ecr 2974105069], length 1448
router > client: ICMP server unreachable - need to frag (mtu 1456), length 556
client.45662 > server.22: Flags [P.], seq 1470:1854, ack 21, win 229, options [nop,nop,TS val 668658 ecr 2974105069], length 384
server.22 > client.45662: Flags [P.], seq 21:725, ack 22, win 91, options [nop,nop,TS val 2974105088 ecr 668657], length 704
server.22 > client.45662: Flags [.], ack 22, win 91, options [nop,nop,TS val 2974105091 ecr 668657,nop,nop,sack 1 {1470:1854}], length 0
client.45662 > server.22: Flags [.], seq 22:1470, ack 725, win 240, options [nop,nop,TS val 668684 ecr 2974105088], length 1448
router > client: ICMP server unreachable - need to frag (mtu 1456), length 556
server.22 > client.45662: Flags [P.], seq 21:725, ack 22, win 91, options [nop,nop,TS val 2974105307 ecr 668657,nop,nop,sack 1 {1470:1854}], length 704
client.45662 > server.22: Flags [.], ack 725, win 240, options [nop,nop,TS val 668897 ecr 2974105307,nop,nop,sack 1 {21:725}], length 0
client.45662 > server.22: Flags [.], seq 22:1470, ack 725, win 240, options [nop,nop,TS val 668904 ecr 2974105307], length 1448
router > client: ICMP server unreachable - need to frag (mtu 1456), length 556
client.45662 > server.22: Flags [.], seq 22:1470, ack 725, win 240, options [nop,nop,TS val 669345 ecr 2974105307], length 1448

(tcpdump was done with tso, gso and gro off to show the real packet sizes on the line)

It took me a while till I found out how to reliably reproduce this:

$ ssh server
$ exit
$ ip route get server
server via router dev eth0  src client
    cache      expires 597sec mtu 1390
$ sleep 597
# really make sure the pmtu cache is empty
$ ip route get server
server via router dev eth0  src client
    cache 
$ ssh server

Now you can observe the behavior shown in the tcpdump above and the connection
will stall. So it only occurs after a pmtu entry expired from the routing/fib cache.
Calling "ip route flush cache" instead of waiting will not show the problem.

I bisected the problem and found the patch 3cdaa5be9e8 (also attached below) to be
the point where the problem was introduced. It was applied between 3.19-rc6 and 3.19-rc7
and is still in current mainline. I have tried a 4.0.0 kernel with this patch reverted
and it does not show the problem, while I can reproduce it with a vanilla 4.0.0.

I'm not familiar enough with the routing implementation in Linux to really tell why
this patch causes the problems I'm seeing, but from cursory glance seems to me that 
the patch only checks the rt->rt_pmtu value and not the pmtu value within a fnhe entry
which might also exist.

Please look into this.

Thank you.

Kind regards,

Gerd

>From 3cdaa5be9e81a914e633a6be7b7d2ef75b528562 Mon Sep 17 00:00:00 2001
From: Li Wei <lw@cn.fujitsu.com>
Date: Thu, 29 Jan 2015 16:09:03 +0800
Subject: [PATCH] ipv4: Don't increase PMTU with Datagram Too Big message.

RFC 1191 said, "a host MUST not increase its estimate of the Path
MTU in response to the contents of a Datagram Too Big message."

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d58dd0e..52e1f2b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -966,6 +966,9 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
    if (dst->dev->mtu < mtu)
        return;
 
+   if (rt->rt_pmtu && rt->rt_pmtu < mtu)
+       return;
+
    if (mtu < ip_rt_min_pmtu)
        mtu = ip_rt_min_pmtu;
 
-- 
1.9.3
