From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] VPN broken in net-next
Date: Wed, 09 Mar 2011 13:28:09 -0800 (PST)
Message-ID: <20110309.132809.48496992.davem@davemloft.net>
References: <20110302.165421.258093056.davem@davemloft.net>
	<alpine.LFD.2.00.1103031414240.1677@ja.ssi.bg>
	<alpine.LFD.2.00.1103031454060.2113@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752709Ab1CIV1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 16:27:32 -0500
In-Reply-To: <alpine.LFD.2.00.1103031454060.2113@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 3 Mar 2011 15:09:22 +0200 (EET)

> 	While checking for ifa_address usage I see other
> two places that look suspicious:
> 
> - inet_gifconf() exposes address from ifa_local but then
> devinet_ioctl() matches by ifa_address in the
> 'if (tryaddrmatch)' block. I think, we should use ifa_local.
> 
> - IN_DEV_ARP_NOTIFY: announces ifa_address instead of ifa_local.

Thanks Julian, I'll push the following into net-2.6:

--------------------
ipv4: Fix erroneous uses of ifa_address.

In usual cases ifa_address == ifa_local, but in the case where
SIOCSIFDSTADDR sets the destination address on a point-to-point
link, ifa_address gets set to that destination address.

Therefore we should use ifa_local when we want the local interface
address.

There were two cases where the selection was done incorrectly:

1) When devinet_ioctl() does matching, it checks ifa_address even
   though gifconf correct reported ifa_local to the user

2) IN_DEV_ARP_NOTIFY handling sends a gratuitous ARP using
   ifa_address instead of ifa_local.

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/devinet.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index df4616f..036652c 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -670,7 +670,7 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 			     ifap = &ifa->ifa_next) {
 				if (!strcmp(ifr.ifr_name, ifa->ifa_label) &&
 				    sin_orig.sin_addr.s_addr ==
-							ifa->ifa_address) {
+							ifa->ifa_local) {
 					break; /* found */
 				}
 			}
@@ -1040,8 +1040,8 @@ static void inetdev_send_gratuitous_arp(struct net_device *dev,
 		return;
 
 	arp_send(ARPOP_REQUEST, ETH_P_ARP,
-		 ifa->ifa_address, dev,
-		 ifa->ifa_address, NULL,
+		 ifa->ifa_local, dev,
+		 ifa->ifa_local, NULL,
 		 dev->dev_addr, NULL);
 }
 
-- 
1.7.4.1

