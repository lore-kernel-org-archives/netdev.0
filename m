From: zhao ya <marywangran0627@gmail.com>
Subject: [PATCH] IPIP tunnel performance improvement
Date: Sat, 27 Feb 2016 12:40:55 +0800
Message-ID: <56D128D7.3090009@gmail.com>
References: <56D12752.7080303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56D12752.7080303@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhao Ya <marywangran0627@gmail.com>
Date: Sat, 27 Feb 2016 10:06:44 +0800
Subject: [PATCH] IPIP tunnel performance improvement

bypass the logic of each packet's own neighbour creation when using 
pointopint or loopback device.

Recently, in our tests, met a performance problem.
In a large number of packets with different target IP address through 
ipip tunnel, PPS will decrease sharply.

The output of perf top are as follows, __write_lock_failed is of the first:
  - 5.89% [kernel]		[k] __write_lock_failed
   -__write_lock_failed 					a
   -_raw_write_lock_bh						a
   -__neigh_create						a
   -ip_finish_output						a
   -ip_output							a
   -ip_local_out						a

The neighbour subsystem will create a neighbour object for each target 
when using pointopint device. When massive amounts of packets with diff-
erent target IP address to be xmit through a pointopint device, these 
packets will suffer the bottleneck at write_lock_bh(&tbl->lock) after 
creating the neighbour object and then inserting it into a hash-table 
at the same time. 

This patch correct it. Only one or little amounts of neighbour objects 
will be created when massive amounts of packets with different target IP 
address through ipip tunnel. 

As the result, performance will be improved.


Signed-off-by: Zhao Ya <marywangran0627@gmail.com>
Signed-off-by: Zhaoya <gaiuszhao@tencent.com>
---
 net/ipv4/ip_output.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 64878ef..d7c0594 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -202,6 +202,8 @@ static int ip_finish_output2(struct net *net, struct sock *sk, struct sk_buff *s
 
 	rcu_read_lock_bh();
 	nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
+	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
+		nexthop = 0;
 	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
 	if (unlikely(!neigh))
 		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
