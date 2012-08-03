From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Fri, 03 Aug 2012 07:45:29 +0200
Message-ID: <1343972729.9299.596.camel@edumazet-glaptop>
References: <50179F66.1000604@parallels.com> <878ve0dtw3.fsf@xmission.com>
	 <1343903310.9299.184.camel@edumazet-glaptop>
	 <20120802.162601.2080519313891137444.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, xemul@parallels.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:51420 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794Ab2HCFpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 01:45:33 -0400
Received: by weyx8 with SMTP id x8so177840wey.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 22:45:32 -0700 (PDT)
In-Reply-To: <20120802.162601.2080519313891137444.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-02 at 16:26 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 02 Aug 2012 12:28:30 +0200
> 
> > Strange because I see no false sharing on this ifindex location for
> > loopback device.
> 
> Are you sure netdev->rx_dropped isn't being incremented?  That appears
> as if it would land on the same cache line as netdev->ifindex.
> 

Yes I am sure (by the way my output device was dummy0, not lo, but its
the same for the case here)

offsetof(struct net_device, features)=0x80
... (all features are mostly read only)
offsetof(struct net_device, ifindex)=0xa0

struct net_device_stats stats; is untouched on dummy device

offsetof(struct net_device, rx_dropped)=0x160

So thats only the dereference done million times per second that show in
the profiles, even if cache lines are clean and in cpu cache.

I see that even more clear in the IN_DEV_ROUTE_LOCALNET(in_dev) macro in
ip_route_input_slow(), doing so many derefs :

Its actually faster to avoid it, if we already have the net pointer in
hand : IN_DEV_NET_ROUTE_LOCALNET(in_dev, net) 

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 67f9dda..d032780 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -104,9 +104,14 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_ANDCONF(in_dev, attr) \
 	(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), attr) && \
 	 IN_DEV_CONF_GET((in_dev), attr))
-#define IN_DEV_ORCONF(in_dev, attr) \
-	(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), attr) || \
+
+#define IN_DEV_NET_ORCONF(in_dev, net, attr) \
+	(IPV4_DEVCONF_ALL(net, attr) || \
 	 IN_DEV_CONF_GET((in_dev), attr))
+
+#define IN_DEV_ORCONF(in_dev, attr) \
+	IN_DEV_NET_ORCONF(in_dev, dev_net(in_dev->dev), attr)
+
 #define IN_DEV_MAXCONF(in_dev, attr) \
 	(max(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), attr), \
 	     IN_DEV_CONF_GET((in_dev), attr)))
@@ -133,6 +138,8 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 					IN_DEV_ORCONF((in_dev), \
 						      PROMOTE_SECONDARIES)
 #define IN_DEV_ROUTE_LOCALNET(in_dev)	IN_DEV_ORCONF(in_dev, ROUTE_LOCALNET)
+#define IN_DEV_NET_ROUTE_LOCALNET(in_dev, net)	\
+	IN_DEV_NET_ORCONF(in_dev, net, ROUTE_LOCALNET)
 
 #define IN_DEV_RX_REDIRECTS(in_dev) \
 	((IN_DEV_FORWARD(in_dev) && \
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e4ba974..5e88e3b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1587,13 +1587,11 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (ipv4_is_zeronet(daddr))
 		goto martian_destination;
 
-	if (likely(!IN_DEV_ROUTE_LOCALNET(in_dev))) {
-		if (ipv4_is_loopback(daddr))
-			goto martian_destination;
+	if (ipv4_is_loopback(daddr) && !IN_DEV_NET_ROUTE_LOCALNET(in_dev, net))
+		goto martian_destination;
 
-		if (ipv4_is_loopback(saddr))
-			goto martian_source;
-	}
+	if (ipv4_is_loopback(saddr) && !IN_DEV_NET_ROUTE_LOCALNET(in_dev, net))
+		goto martian_source;
 
 	/*
 	 *	Now we are ready to route packet.
