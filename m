From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bugme-new] [Bug 9440] New: Problem in joinning a socket to ipv6 multicast address in specific scenario
Date: Fri, 30 Nov 2007 15:25:16 +0300
Message-ID: <20071130122516.GA28027@2ka.mipt.ru>
References: <bug-9440-10286@http.bugzilla.kernel.org/> <20071122172342.721ee232.akpm@linux-foundation.org> <20071123105924.GB22062@2ka.mipt.ru> <20071128111814.GA10246@2ka.mipt.ru> <20071130120219.GA26848@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, aviad.yehezkel5@gmail.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34658 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713AbXK3MZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 07:25:42 -0500
Content-Disposition: inline
In-Reply-To: <20071130120219.GA26848@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 30, 2007 at 11:02:19PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> OK, this looks like a good change.  However, we should also
> change NETDEV_UP as well to recreate idev if it isn't there
> and the MTU is big enough.

Ok, added netdev_up too.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 567664e..e8c3475 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2293,6 +2293,9 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 				break;
 			}
 
+			if (!idev && dev->mtu >= IPV6_MIN_MTU)
+				idev = ipv6_add_dev(dev);
+
 			if (idev)
 				idev->if_flags |= IF_READY;
 		} else {
@@ -2357,12 +2360,18 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
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
