From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Thu, 10 Mar 2016 13:20:18 +0300
Message-ID: <20160310102018.GA21154@uranus.lan>
References: <20160309204158.GO2207@uranus.lan>
 <20160309.154725.1921352291794389965.davem@davemloft.net>
 <20160309205746.GQ2207@uranus.lan>
 <20160309.161038.283281065293712589.davem@davemloft.net>
 <20160309211629.GR2207@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160309211629.GR2207@uranus.lan>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2016 at 12:16:29AM +0300, Cyrill Gorcunov wrote:
> 
> Thanks for explanation, Dave! I'll continue on this task tomorrow
> tryin to implement optimization you proposed.

OK, here are the results for the preliminary patch with conntrack running
---
[root@s125 ~]# ./exploit.sh 
START 4		addresses STOP 1457604516 1457604518
START 2704 	addresses STOP 1457604520 1457604521
START 10404 	addresses STOP 1457604533 1457604534
START 23104 	addresses STOP 1457604566 1457604567
START 40804 	addresses STOP 1457604642 1457604643
START 63504 	addresses STOP 1457604809 1457604810

It takes ~1 second for each case, which is great.
---
 net/ipv4/devinet.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

Index: linux-ml.git/net/ipv4/devinet.c
===================================================================
--- linux-ml.git.orig/net/ipv4/devinet.c
+++ linux-ml.git/net/ipv4/devinet.c
@@ -403,7 +403,18 @@ no_promotions:
 	   So that, this order is correct.
 	 */
 	rtmsg_ifa(RTM_DELADDR, ifa1, nlh, portid);
-	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);
+
+	if (!in_dev->dead || (in_dev->dead && !ifa1->ifa_next)) {
+		/*
+		 * We might be destroying device with millions
+		 * of addresses assigned, so we need to call
+		 * the notifier on the last pass only, otherwise
+		 * conntack code (if kernel supports) gonna scan
+		 * on each cleanup iteration wasting huge amount
+		 * of time.
+		 */
+		blocking_notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);
+	}
 
 	if (promote) {
 		struct in_ifaddr *next_sec = promote->ifa_next;
