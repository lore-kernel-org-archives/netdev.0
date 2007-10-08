From: David Miller <davem@davemloft.net>
Subject: Re: [NET] IPv6 oops bisected
Date: Sun, 07 Oct 2007 23:16:08 -0700 (PDT)
Message-ID: <20071007.231608.104667710.davem@davemloft.net>
References: <4708E016.9020300@garzik.org>
	<4708E3CF.4000401@gmail.com>
	<4708F387.1060602@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlunev@gmail.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, den@openvz.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50621
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751463AbXJHGQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 02:16:10 -0400
In-Reply-To: <4708F387.1060602@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Sun, 07 Oct 2007 10:56:07 -0400

> /etc/sysconfig/network-scripts/network-functions-ipv6: line 246: 1760 Killed
> 	LC_ALL=C /sbin/ip $options
> 
> 
> NULL pointer dereference at 0x000003f8
> 
> backtrace:
> :ipv6:ip6_route_add+0x1b1/0x543

'dev' can be NULL in that code branch of ip6_route_add(),
yet we're deferencing it to get dev->nd_net.

 	if ((cfg->fc_flags & RTF_REJECT) ||
 	    (dev && (dev->flags&IFF_LOOPBACK) && !(addr_type&IPV6_ADDR_LOOPBACK))) {
 		/* hold loopback dev/idev if we haven't done so. */
-		if (dev != init_net.loopback_dev) {
+		if (dev != dev->nd_net->loopback_dev) {

I'll add the appropriate check for NULL as follows:

commit b3c1427c21f9bac4ceaa02e875f3b2c9a5592132
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Sun Oct 7 23:15:56 2007 -0700

    [IPV6]: Fix OOPS introduced by 5f5dace1ce001b24fb8286e09ffd3c4d2b547e09.
    
    In ip6_add_route(), 'dev' can be NULL, so check that before
    we try to deref dev->nd_net.
    
    Based upon a crash report by Jeff Garzik.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a7db84c..7109ad6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1188,7 +1188,7 @@ int ip6_route_add(struct fib6_config *cfg)
 	if ((cfg->fc_flags & RTF_REJECT) ||
 	    (dev && (dev->flags&IFF_LOOPBACK) && !(addr_type&IPV6_ADDR_LOOPBACK))) {
 		/* hold loopback dev/idev if we haven't done so. */
-		if (dev != dev->nd_net->loopback_dev) {
+		if (!dev || (dev != dev->nd_net->loopback_dev)) {
 			if (dev) {
 				dev_put(dev);
 				in6_dev_put(idev);
