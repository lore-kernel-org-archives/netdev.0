From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: flush nd cache on IFF_NOARP change
Date: Wed, 29 Jul 2015 12:01:41 +0200
Message-ID: <1438164101.20182.83.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1437989630.20182.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150728.234147.1087098759056655521.davem@davemloft.net>
	 <1438161351.20182.73.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1438162343.20182.75.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, valas@google.com, willemb@google.com,
	Mario Fanelli <mariofanelli@google.com>, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36063 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbbG2KBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 06:01:46 -0400
Received: by wicgb10 with SMTP id gb10so192797642wic.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 03:01:45 -0700 (PDT)
In-Reply-To: <1438162343.20182.75.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This patch is the IPv6 equivalent of commit
6c8b4e3ff81b ("arp: flush arp cache on IFF_NOARP change") 

Without it, we keep buggy neighbours in the cache, with destination
MAC address equal to our own MAC address.

Tested:
 tcpdump -i eth0 -s 0 ip6 -n -e &
 ip link set dev eth0 arp off
 ping6 remote   // sends buggy frames
 ip link set dev eth0 arp on
 ping6 remote   // should work once kernel is patched

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Mario Fanelli <mariofanelli@google.com>
---
 net/ipv6/ndisc.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0a05b35..c53331c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1650,6 +1650,7 @@ int ndisc_rcv(struct sk_buff *skb)
 static int ndisc_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct netdev_notifier_change_info *change_info;
 	struct net *net = dev_net(dev);
 	struct inet6_dev *idev;
 
@@ -1664,6 +1665,11 @@ static int ndisc_netdev_event(struct notifier_block *this, unsigned long event,
 			ndisc_send_unsol_na(dev);
 		in6_dev_put(idev);
 		break;
+	case NETDEV_CHANGE:
+		change_info = ptr;
+		if (change_info->flags_changed & IFF_NOARP)
+			neigh_changeaddr(&nd_tbl, dev);
+		break;
 	case NETDEV_DOWN:
 		neigh_ifdown(&nd_tbl, dev);
 		fib6_run_gc(0, net, false);
