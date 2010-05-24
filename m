From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] IPv6: only notify protocols if address is completely
 gone
Date: Mon, 24 May 2010 11:33:00 -0700
Message-ID: <20100524113300.2ef38e12@nehalam>
References: <20100412154130.397252857@vyatta.com>
	<20100412154255.641453741@vyatta.com>
	<EA929A9653AAE14F841771FB1DE5A1365FE4FCE12C@rrsmsx501.amr.corp.intel.com>
	<AANLkTin3CfATS0-ePL5WUSiuq0seRCQgM6xc-YwxpPEy@mail.gmail.com>
	<20100524113118.47cc9852@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>, stable@kernel.org
To: Emil S Tantilov <emils.tantilov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53442 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757682Ab0EXSdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 May 2010 14:33:11 -0400
In-Reply-To: <20100524113118.47cc9852@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The notifier for address down should only be called if address is completely
gone, not just being marked as tentative on link transition. The code
in net-next would case bonding/sctp/s390 to see address disappear on link
down, but they would never see it reappear on link up.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
(cherry picked from commit 8595805aafc8b077e01804c9a3668e9aa3510e89)
---
Patch for 2.6.34-stable, not needed on earlier or later kernels

 net/ipv6/addrconf.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 12e9558..844ffc5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2729,7 +2729,9 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		write_unlock_bh(&idev->lock);
 
 		__ipv6_ifa_notify(RTM_DELADDR, ifa);
-		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
+		if (ifa->dead)
+			atomic_notifier_call_chain(&inet6addr_chain,
+						   NETDEV_DOWN, ifa);
 		in6_ifa_put(ifa);
 
 		write_lock_bh(&idev->lock);
-- 
1.7.0.4

