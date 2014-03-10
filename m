From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Re: Link-local source IPv6 address in unicast Neighbor Solicitation towards global destination
Date: Mon, 10 Mar 2014 03:44:25 +0100
Message-ID: <20140310024425.GG5493@order.stressinduktion.org>
References: <20140306070250.GC26307@order.stressinduktion.org> <trinity-e0e97e3d-2c6a-4f81-bd27-f7151a67b303-1394097503168@3capp-gmx-bs05>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52579 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108AbaCJCo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 22:44:26 -0400
Content-Disposition: inline
In-Reply-To: <trinity-e0e97e3d-2c6a-4f81-bd27-f7151a67b303-1394097503168@3capp-gmx-bs05>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon!

On Thu, Mar 06, 2014 at 10:18:23AM +0100, Simon Schneider wrote:
> thanks, checking that would be good.
> 
> Another point here (probably a bit academic): without link-local address on the interface (just the global one), the unicast NS for NUD is not sent at all.
> 
> The neighbor cache entry is in DELAY state for some time, unicast NS is not sent, then the entry is moved to FAILED rather quickly.

Yep, that's the case. IMHO undefined behaviour so it is ok but could
be improved.

This would be the patch, should improve your initial observation and would
also "fix" the situation you noted above. Could you give it a test drive?

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 09a22f4..43c66f6 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -553,7 +553,17 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 	struct nd_msg *msg;
 
 	if (saddr == NULL) {
-		if (ipv6_get_lladdr(dev, &addr_buf,
+		if (!ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
+				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->srcprefs,
+				       &addr_buf) &&
+		    ipv6_chk_addr(dev_net(dev), &addr_buf, dev, 1)) {
+			struct inet6_ifaddr *ifp = ipv6_get_ifaddr(dev_net(dev), &addr_buf, dev, 1);
+			if (ifp && !(ifp->flags & IFA_F_OPTIMISTIC))
+				saddr = &addr_buf;
+			in6_ifa_put(ifp);
+		}
+
+		if (!saddr && ipv6_get_lladdr(dev, &addr_buf,
 				   (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
 			return;
 		saddr = &addr_buf;


Thanks,

  Hannes
