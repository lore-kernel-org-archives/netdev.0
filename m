From: Greg KH <gregkh@suse.de>
Subject: [072/205] IPv6: only notify protocols if address is completely gone
Date: Fri, 30 Jul 2010 10:51:29 -0700
Message-ID: <20100730175140.180788935@clark.site>
References: <20100730175238.GA3924@kroah.com>
Cc: stable-review@kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	NetDev <netdev@vger.kernel.org>, <emil.s.tantilov@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Emil S Tantilov <emils.tantilov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:58245 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759925Ab0G3RzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jul 2010 13:55:21 -0400
In-Reply-To: <20100730175238.GA3924@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.34-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Stephen Hemminger <shemminger@vyatta.com>

(cherry picked from commit 8595805aafc8b077e01804c9a3668e9aa3510e89)

The notifier for address down should only be called if address is completely
gone, not just being marked as tentative on link transition. The code
in net-next would case bonding/sctp/s390 to see address disappear on link
down, but they would never see it reappear on link up.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/ipv6/addrconf.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2729,7 +2729,9 @@ static int addrconf_ifdown(struct net_de
 		write_unlock_bh(&idev->lock);
 
 		__ipv6_ifa_notify(RTM_DELADDR, ifa);
-		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
+		if (ifa->dead)
+			atomic_notifier_call_chain(&inet6addr_chain,
+						   NETDEV_DOWN, ifa);
 		in6_ifa_put(ifa);
 
 		write_lock_bh(&idev->lock);


