From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] IPv6: fix rt_lookup in pmtu_discovery
Date: Wed, 13 Jan 2010 16:51:30 -0800
Message-ID: <55a4f86e1001131651j102b600fm1552a42866c3c671@mail.gmail.com>
References: <55a4f86e1001071705i33f8c58cubae56f5616216de4@mail.gmail.com>
	 <20100107.171015.29035630.davem@davemloft.net>
	 <b91784ff1001081612g7c15e968u5e77931289af25c@mail.gmail.com>
	 <20100110.131524.241344047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: lorenzo@google.com, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:51800 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625Ab0ANA7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 19:59:13 -0500
Received: by pwj9 with SMTP id 9so3308632pwj.21
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2010 16:59:13 -0800 (PST)
In-Reply-To: <20100110.131524.241344047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I believe you are looking for the following patch.

I don't think it solves the problem of source based routing to any
(significantly) greater extent than the previous patch.
That would actually require iterating over all IPs assigned to any
interface on our machine.

However, I really don't understand the code (nor the precise issues
involved) sufficiently well to be certain of that.

I actually think the ipv4 code path suffers from a very similar problem.

Mind you - I don't think these issues are really significant problems,
because they just mean we do PMTU once per (dest ip, src ip) instead
of once per (dest ip).

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c2bd74c..dd8e3b3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1562,14 +1562,13 @@ out:
  *	i.e. Path MTU discovery
  */

-void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr,
-			struct net_device *dev, u32 pmtu)
+static void rt6_do_pmtu_disc(struct in6_addr *daddr, struct in6_addr *saddr,
+			     struct net *net, u32 pmtu, int ifindex)
 {
 	struct rt6_info *rt, *nrt;
-	struct net *net = dev_net(dev);
 	int allfrag = 0;

-	rt = rt6_lookup(net, daddr, saddr, dev->ifindex, 0);
+	rt = rt6_lookup(net, daddr, saddr, ifindex, 0);
 	if (rt == NULL)
 		return;

@@ -1637,6 +1636,31 @@ out:
 	dst_release(&rt->u.dst);
 }

+void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr,
+			struct net_device *dev, u32 pmtu)
+{
+	struct net *net = dev_net(dev);
+
+	/*
+	 * RFC 1981 states that a node "MUST reduce the size of the packets it
+	 * is sending along the path" that caused the Packet Too Big message.
+	 * Since it's not possible in the general case to determine which
+	 * interface was used to send the original packet, we update the MTU
+	 * on the interface that will be used to send future packets. We also
+	 * update the MTU on the interface that received the Packet Too Big in
+	 * case the original packet was forced out that interface with
+	 * SO_BINDTODEVICE or similar. This is the next best thing to the
+	 * correct behaviour, which would be to update the MTU on all
+	 * interfaces.
+	 */
+	rt6_do_pmtu_disc(daddr, saddr, net, pmtu, 0);
+	rt6_do_pmtu_disc(daddr, saddr, net, pmtu, dev->ifindex);
+	/* also support source address based routing */
+	rt6_do_pmtu_disc(daddr, NULL, net, pmtu, 0);
+	rt6_do_pmtu_disc(daddr, NULL, net, pmtu, dev->ifindex);
+}
+
+
 /*
  *	Misc support functions
  */
