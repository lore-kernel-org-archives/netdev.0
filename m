From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Fri, 04 Mar 2016 23:11:09 -0500 (EST)
Message-ID: <20160304.231109.1838919633640757059.davem@davemloft.net>
References: <20160304213920.GJ4184@uranus.lan>
	<20160304.175032.1728003538386465719.davem@davemloft.net>
	<1457136510.2761.8.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39683 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759694AbcCEELR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 23:11:17 -0500
In-Reply-To: <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 04 Mar 2016 16:08:30 -0800

> __inet_del_ifa() should probably take into account in_dev->dead (no
> promotion, no list scan...)

Indeed, that is the real problem:

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 8c3df2c..7412feb 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -334,6 +334,12 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 
 	ASSERT_RTNL();
 
+	/* None of these potentially quadratic scans matter if the
+	 * device is being destroyed.
+	 */
+	if (in_dev->dead)
+		goto no_promotions;
+
 	/* 1. Deleting primary ifaddr forces deletion all secondaries
 	 * unless alias promotion is set
 	 **/
@@ -380,6 +386,7 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 			fib_del_ifaddr(ifa, ifa1);
 	}
 
+no_promotions:
 	/* 2. Unlink it */
 
 	*ifap = ifa1->ifa_next;
