From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] udp: increment UDP_MIB_NOPORTS in mcast receive
Date: Wed, 03 Oct 2012 09:28:48 +0200
Message-ID: <1349249328.12401.1364.camel@edumazet-glaptop>
References: <506955F3.8050304@googlemail.com>
	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <20121001193434.GA14236@redhat.com>
	 <20121001.160115.1816241312626722150.davem@davemloft.net>
	 <1349121884.12401.721.camel@edumazet-glaptop>
	 <1349192133.12401.768.camel@edumazet-glaptop>
	 <1349192919.12401.778.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1210030032430.25856@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chris2553@googlemail.com,
	netdev@vger.kernel.org, gpiez@web.de, Dave Jones <davej@redhat.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61956 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754837Ab2JCH2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 03:28:53 -0400
Received: by bkcjk13 with SMTP id jk13so5897822bkc.19
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2012 00:28:52 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1210030032430.25856@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-03 at 02:24 +0300, Julian Anastasov wrote:
> 	Hello,
> 
> On Tue, 2 Oct 2012, Eric Dumazet wrote:
> 
> > > David, shouldnt we use a nh_rth_forward instead of a nh_rth_input in
> > > __mkroute_input() ?
> > > 
> > > (And change rt_cache_route() as well ?)
> > > 
> > > I am testing a patch right now.
> > 
> > Yeah, this patch seems to fix the bug for me.
> > 
> > [PATCH] ipv4: properly cache forward routes
> > 
> > commit d2d68ba9fe8 (ipv4: Cache input routes in fib_info nexthops.)
> > introduced a regression for forwarding.
> > 
> > This was hard to reproduce but the symptom was that packets were
> > delivered to local host instead of being forwarded.
> > 
> > Add a separate cache (nh_rth_forward) to solve the problem.
> 
> 	Can it be a problem related to fib_info reuse
> from different routes. For example, when local IP address
> is created for subnet we have:
> 
> broadcast 192.168.0.255 dev DEV  proto kernel  scope link  src 192.168.0.1
> 192.168.0.0/24 dev DEV  proto kernel  scope link  src 192.168.0.1
> local 192.168.0.1 dev DEV  proto kernel  scope host  src 192.168.0.1
> 
> 	The "dev DEV  proto kernel  scope link  src 192.168.0.1" is
> a reused fib_info structure where we put cached routes.
> The result can be same fib_info for 192.168.0.255 and
> 192.168.0.0/24. RTN_BROADCAST is cached only for input
> routes. Incoming broadcast to 192.168.0.255 can be cached
> and can cause problems for traffic forwarded to 192.168.0.0/24.
> So, this patch should solve the problem because it
> separates the broadcast from unicast traffic.
> 
> 	And the ip_route_input_slow caching will work for
> local and broadcast input routes (above routes 1 and 3) just
> because they differ in scope and use different fib_info.
> 
> 	Another possible failure is for output routes:
> 
> multicast 224.0.0.0/4 fib_info
> with unicast
> 192.168.0.0/24 fib_info
> 
> 	The multicast sets RTCF_MULTICAST | RTCF_LOCAL
> and can cause problems for generated unicast traffic on
> fib_info reuse. Depends on the scope, for multicast it is
> usually scope global, so may be it is difficult to happen
> in practice.
> 
> 	__mkroute_output works for local/unicast routes
> because they differ in scope.


Thanks Julian for these informations.

BTW, it seems we dont properly increase UDP MIB counters when a
multicast message is not delivered to at least one socket.

Lets fix this to ease future bug hunting.

I hate when "netstat -s" is useless and we have to use dropwatch to
figure out where we drop a frame.

[PATCH] udp: increment UDP_MIB_NOPORTS in multicast receive

We should increment UDP_MIB_NOPORTS in the case we found
no socket to deliver a copy of one incoming UDP message.

(RFC 4113 udpNoPorts)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/udp.c |    1 +
 net/ipv6/udp.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 79c8dbe..dfa73c5 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1591,6 +1591,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 			sock_put(stack[i]);
 	} else {
 		kfree_skb(skb);
+		UDP_INC_STATS_BH(net, UDP_MIB_NOPORTS, udptable != &udp_table);
 	}
 	return 0;
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index fc99972..0be9ac2 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -748,6 +748,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 			sock_put(stack[i]);
 	} else {
 		kfree_skb(skb);
+		UDP6_INC_STATS_BH(net, UDP_MIB_NOPORTS, udptable != &udp_table);
 	}
 	return 0;
 }
