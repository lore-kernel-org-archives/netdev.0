From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net] ipv6: Don't call with rt6_uncached_list_flush_dev
Date: Mon, 12 Oct 2015 11:02:08 -0500
Message-ID: <87wpusoz27.fsf_-_@x220.int.ebiederm.org>
References: <CACT4Y+a3J5sgSk7OvzdG6vg2PuFfBPpuJHo3csKpox5s77H+rA@mail.gmail.com>
	<1444652652.27760.158.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Martin KaFai Lau <kafai@fb.com>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, syzkaller@googlegroups.com,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60627 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbbJLQK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 12:10:28 -0400
In-Reply-To: <1444652652.27760.158.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Mon, 12 Oct 2015 05:24:12 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As originally written rt6_uncached_list_flush_dev makes no sense when
called with dev == NULL as it attempts to flush all uncached routes
regardless of network namespace when dev == NULL.  Which is simply
incorrect behavior.

Furthermore at the point rt6_ifdown is called with dev == NULL no more
network devices exist in the network namespace so even if the code in
rt6_uncached_list_flush_dev were to attempt something sensible it
would be meaningless.

Therefore remove support in rt6_uncached_list_flush_dev for handling
network devices where dev == NULL, and only call rt6_uncached_list_flush_dev
 when rt6_ifdown is called with a network device.

Fixes: 8d0b94afdca8 ("ipv6: Keep track of DST_NOCACHE routes in case of iface down/unregister")
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv6/route.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b8f85f143b69..1c45d7d90718 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -143,6 +143,9 @@ static void rt6_uncached_list_flush_dev(struct net *net, struct net_device *dev)
 	struct net_device *loopback_dev = net->loopback_dev;
 	int cpu;
 
+	if (dev == loopback_dev)
+		return;
+
 	for_each_possible_cpu(cpu) {
 		struct uncached_list *ul = per_cpu_ptr(&rt6_uncached_list, cpu);
 		struct rt6_info *rt;
@@ -152,14 +155,12 @@ static void rt6_uncached_list_flush_dev(struct net *net, struct net_device *dev)
 			struct inet6_dev *rt_idev = rt->rt6i_idev;
 			struct net_device *rt_dev = rt->dst.dev;
 
-			if (rt_idev && (rt_idev->dev == dev || !dev) &&
-			    rt_idev->dev != loopback_dev) {
+			if (rt_idev->dev == dev) {
 				rt->rt6i_idev = in6_dev_get(loopback_dev);
 				in6_dev_put(rt_idev);
 			}
 
-			if (rt_dev && (rt_dev == dev || !dev) &&
-			    rt_dev != loopback_dev) {
+			if (rt_dev == dev) {
 				rt->dst.dev = loopback_dev;
 				dev_hold(rt->dst.dev);
 				dev_put(rt_dev);
@@ -2600,7 +2601,8 @@ void rt6_ifdown(struct net *net, struct net_device *dev)
 
 	fib6_clean_all(net, fib6_ifdown, &adn);
 	icmp6_clean_all(fib6_ifdown, &adn);
-	rt6_uncached_list_flush_dev(net, dev);
+	if (dev)
+		rt6_uncached_list_flush_dev(net, dev);
 }
 
 struct rt6_mtu_change_arg {
-- 
2.2.1
