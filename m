From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/3] ipv6: Send unsolicited neighbour
 advertismements when notified
Date: Sat, 16 Apr 2011 00:46:02 +0100
Message-ID: <1302911162.2845.39.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:6693 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920Ab1DOXqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 19:46:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NETDEV_NOTIFY_PEERS notifier is a request to send such
advertisements following migration to a different physical link,
e.g. virtual machine migration.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This seems to work and should match what the bonding driver was
previously doing on failover, except that it iterates over all
addresses.  I don't know whether it's actually right though.

Ben.

 net/ipv6/ndisc.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 92f952d..a51fa74c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -611,6 +611,29 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 		     inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
 }
 
+static void ndisc_send_unsol_na(struct net_device *dev)
+{
+	struct inet6_dev *idev;
+	struct inet6_ifaddr *ifa;
+	struct in6_addr mcaddr;
+
+	idev = in6_dev_get(dev);
+	if (!idev)
+		return;
+
+	read_lock_bh(&idev->lock);
+	list_for_each_entry(ifa, &idev->addr_list, if_list) {
+		addrconf_addr_solict_mult(&ifa->addr, &mcaddr);
+		ndisc_send_na(dev, NULL, &mcaddr, &ifa->addr,
+			      /*router=*/ !!idev->cnf.forwarding,
+			      /*solicited=*/ false, /*override=*/ true,
+			      /*inc_opt=*/ true);
+	}
+	read_unlock_bh(&idev->lock);
+
+	in6_dev_put(idev);
+}
+
 void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		   const struct in6_addr *solicit,
 		   const struct in6_addr *daddr, const struct in6_addr *saddr)
@@ -1722,6 +1745,9 @@ static int ndisc_netdev_event(struct notifier_block *this, unsigned long event,
 		neigh_ifdown(&nd_tbl, dev);
 		fib6_run_gc(~0UL, net);
 		break;
+	case NETDEV_NOTIFY_PEERS:
+		ndisc_send_unsol_na(dev);
+		break;
 	default:
 		break;
 	}
-- 
1.7.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

