From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 1/4] ipv4: don't disable interface if last ipv4 address is removed
Date: Tue, 21 Jan 2014 13:48:48 +0200
Message-ID: <2748ead3b814852075f954ea157fe5d7288531e2.1390304505.git.popovich_sergei@mail.ru>
References: <cover.1390304505.git.popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback4.mail.ru ([94.100.176.42]:59224 "EHLO
	fallback4.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134AbaAULwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 06:52:47 -0500
Received: from smtp11.mail.ru (smtp11.mail.ru [94.100.176.85])
	by fallback4.mail.ru (mPOP.Fallback_MX) with ESMTP id 2EEB214C62D
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 15:49:07 +0400 (MSK)
Received: from [2a01:6d80:103:13::c3ea:4404] (port=42200 helo=tuxracer.localdomain)
	by smtp11.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1W5ZpA-0006Kt-8x
	for netdev@vger.kernel.org; Tue, 21 Jan 2014 15:48:56 +0400
In-Reply-To: <cover.1390304505.git.popovich_sergei@mail.ru>
In-Reply-To: <cover.1390304505.git.popovich_sergei@mail.ru>
References: <cover.1390304505.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since

  commit 876fd05ddbae03166e7037fca957b55bb3be6594
  Author: Hannes Frederic Sowa <>
  Date:   Mon Jun 24 00:22:20 2013 +0200

    ipv6: don't disable interface if last ipv6 address is removed

we have disabled this behavior for IPv6. Adjust behavior for IPv4.

There is at least one additional reason to do the same for IPv4.
Suppose we have following configuration:

  # ip link add dev dummy1 type dummy
  # ip -4 addr add 192.168.1.254/24 dev dummy1
  # ip link set up dev dummy1

  # ip link add dev veth1a type veth peer name veth1b
  # ip link set up dev veth1a
  # ip -4 route add 192.168.1.1/32 dev veth1a src 192.168.1.254 proto static

  # ip netns add pc1
  # ip link set netns pc1 dev veth1b
  # ip netns exec pc1 ip -4 addr add 192.168.1.1/24 dev veth1b
  # ip netns exec pc1 ip link set up dev veth1b
  # ip netns exec pc1 ip link set up dev lo

  # ip -4 addr add 10.0.1.1/30 dev veth1a
  # ip -4 addr sh dev veth1a
  32: veth1a: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    inet 10.0.1.1/30 scope global veth1a
       valid_lft forever preferred_lft forever
  # ip -4 route show dev veth1a
  10.0.1.0/30  proto kernel  scope link  src 10.0.1.1
  192.168.1.1  proto static  scope link  src 192.168.1.254

  # ping -I192.168.1.254 192.168.1.1 -c1
  PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
  64 bytes from 192.168.1.1: icmp_req=1 ttl=64 time=0.039 ms

  --- 192.168.1.1 ping statistics ---
  1 packets transmitted, 1 received, 0% packet loss, time 0ms
  rtt min/avg/max/mdev = 0.039/0.039/0.039/0.000 ms
  # ip -4 neigh sh dev veth1a
  192.168.1.1 lladdr 9a:7e:a5:aa:1b:a0 REACHABLE

  and after removing last ipv4 address from veth1a
  ------------------------------------------------

  # ip -4 addr del 10.0.1.1/30 dev veth1a
  # ip -4 neigh sh dev veth1a
  # ip -4 route show dev veth1a

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 net/ipv4/fib_frontend.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index d846304..ae5f35f 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1021,14 +1021,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 	case NETDEV_DOWN:
 		fib_del_ifaddr(ifa, NULL);
 		atomic_inc(&net->ipv4.dev_addr_genid);
-		if (ifa->ifa_dev->ifa_list == NULL) {
-			/* Last address was deleted from this interface.
-			 * Disable IP.
-			 */
-			fib_disable_ip(dev, 1);
-		} else {
-			rt_cache_flush(dev_net(dev));
-		}
+		rt_cache_flush(dev_net(dev));
 		break;
 	}
 	return NOTIFY_DONE;
-- 
1.8.3.4
