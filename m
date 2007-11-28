From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bugme-new] [Bug 9440] New: Problem in joinning a socket to ipv6 multicast address in specific scenario
Date: Wed, 28 Nov 2007 14:18:14 +0300
Message-ID: <20071128111814.GA10246@2ka.mipt.ru>
References: <bug-9440-10286@http.bugzilla.kernel.org/> <20071122172342.721ee232.akpm@linux-foundation.org> <20071123105924.GB22062@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	aviad.yehezkel5@gmail.com, Herbert Xu <herbert@gondor.apana.org.au>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51937 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756297AbXK1LSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 06:18:45 -0500
Content-Disposition: inline
In-Reply-To: <20071123105924.GB22062@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

Avaid provided test application, so bug got fixed.

IPv6 addrconf removes ipv6 inner device from netdev each time cmu
changes and new value is less than IPV6_MIN_MTU (1280 bytes).
When mtu is changed and new value is greater than IPV6_MIN_MTU,
it does not add ipv6 addresses and inner device bac.

This patch fixes that.

Tested with Avaid's application, which works ok now.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 567664e..4f7e46c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2357,12 +2358,18 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 		break;
 
 	case NETDEV_CHANGEMTU:
-		if ( idev && dev->mtu >= IPV6_MIN_MTU) {
+		if (idev && dev->mtu >= IPV6_MIN_MTU) {
 			rt6_mtu_change(dev, dev->mtu);
 			idev->cnf.mtu6 = dev->mtu;
 			break;
 		}
 
+		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
+			idev = ipv6_add_dev(dev);
+			if (idev)
+				break;
+		}
+
 		/* MTU falled under IPV6_MIN_MTU. Stop IPv6 on this interface. */
 
 	case NETDEV_DOWN:

-- 
	Evgeniy Polyakov
