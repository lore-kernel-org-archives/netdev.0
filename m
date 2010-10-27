From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] tunnels: Fix tunnels change rcu protection
Date: Wed, 27 Oct 2010 19:43:53 +0400
Message-ID: <4CC848B9.1060406@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2028 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755142Ab0J0PoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 11:44:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After making rcu protection for tunnels (ipip, gre, sit and ip6) a bug
was introduced into the SIOCCHGTUNNEL code.

The tunnel is first unlinked, then addresses change, then it is linked
back probably into another bucket. But while changing the parms, the
hash table is unlocked to readers and they can lookup the improper tunnel.

Respective commits are b7285b79 (ipip: get rid of ipip_lock), 1507850b
(gre: get rid of ipgre_lock), 3a43be3c (sit: get rid of ipip6_lock) and
94767632 (ip6tnl: get rid of ip6_tnl_lock).

The quick fix is to wait for quiescent state to pass after unlinking,
but if it is inappropriate I can invent something better, just let me
know.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d0ffcbe..01087e0 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1072,6 +1072,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 					break;
 				}
 				ipgre_tunnel_unlink(ign, t);
+				synchronize_net();
 				t->parms.iph.saddr = p.iph.saddr;
 				t->parms.iph.daddr = p.iph.daddr;
 				t->parms.i_key = p.i_key;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index e9b816e..cd300aa 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -676,6 +676,7 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 				}
 				t = netdev_priv(dev);
 				ipip_tunnel_unlink(ipn, t);
+				synchronize_net();
 				t->parms.iph.saddr = p.iph.saddr;
 				t->parms.iph.daddr = p.iph.daddr;
 				memcpy(dev->dev_addr, &p.iph.saddr, 4);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 38b9a56..2a59610 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1284,6 +1284,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 				t = netdev_priv(dev);
 
 			ip6_tnl_unlink(ip6n, t);
+			synchronize_net();
 			err = ip6_tnl_change(t, &p);
 			ip6_tnl_link(ip6n, t);
 			netdev_state_change(dev);
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 367a6cc..d6bfaec 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -963,6 +963,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 				}
 				t = netdev_priv(dev);
 				ipip6_tunnel_unlink(sitn, t);
+				synchronize_net();
 				t->parms.iph.saddr = p.iph.saddr;
 				t->parms.iph.daddr = p.iph.daddr;
 				memcpy(dev->dev_addr, &p.iph.saddr, 4);
