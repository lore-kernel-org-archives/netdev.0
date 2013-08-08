From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: [RFC net-next] ipip: Add room for custom tunnel header
Date: Thu,  8 Aug 2013 15:52:07 +0200
Message-ID: <1375969927-22235-1-git-send-email-kristian.evensen@gmail.com>
Cc: Kristian Evensen <kristian.evensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34171 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965685Ab3HHNwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 09:52:30 -0400
Received: by mail-wi0-f172.google.com with SMTP id hj13so596005wib.11
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 06:52:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

A project I recently worked on required me to tunnel traffic between devices
placed in different locations. The aggregated, average traffic from each
location is ~150Mb/s, which saturated the router CPU when using a TUN-interface
for tunneling (IP in UDP). Actually, the router was not able to tunnel more than
~60Mbit/s. 

I therefore decided to look into the different in-kernel tunneling options. As
the traffic is encrypted by the devices, ip-in-ip tunneling would be sufficient.
However, each site is connected using a public internet connection and placed
behind a NAT, so pure ip-in-ip tunneling would not work.

This patch enables users to specify the size of a header that will be added
between the two IP-headers. The header can then be filled in by for example an
xtables-module (avoiding a memmove). In addition to solving my problem (I
inserted a UDP header to fool the NAT-boxes), this patch can be used to ease
development and deployment of new tunneling protocols. Instead of integrating
them in the kernel, protocols can be built on top of the existing IP-in-IP
tunnels and get the advantages of the ip_tunnels-framework.

The patch works as expected and provided me with a nice performance boost
(roughly x4). However, it currently has a problem. As I extend the ip_tunnel_parm
struct, applications like ip needs to be recompiled in order to work properly.
Is there a better way to pass the hlen-value to the kernel (user rtnl-ops and
add as parameter?), or to detect number of bytes waiting to be copied from user
space?

Also, is this something that would be considered useful and potentially added to
the kernel, or will it be viewed as a protocol hack? One other way I thought of
doing this, was to clone ipip.c and add a new tunneling type. However, that
seems a bit overkill for a five line change.

-Kristian

Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
---
 include/uapi/linux/if_tunnel.h |    1 +
 net/ipv4/ipip.c                |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index aee73d0..039bbc3 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -35,6 +35,7 @@ struct ip_tunnel_parm {
 	__be32			i_key;
 	__be32			o_key;
 	struct iphdr		iph;
+	int                     hlen;
 };
 
 enum {
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 51fc2a1..9705aa1 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -226,6 +226,9 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		skb->encapsulation = 1;
 	}
 
+	if (tunnel->hlen > 0)
+		skb_push(skb, tunnel->hlen);
+
 	ip_tunnel_xmit(skb, dev, tiph, tiph->protocol);
 	return NETDEV_TX_OK;
 
@@ -302,7 +305,7 @@ static int ipip_tunnel_init(struct net_device *dev)
 	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
-	tunnel->hlen = 0;
+	tunnel->hlen = tunnel->parms.hlen;
 	tunnel->parms.iph.protocol = IPPROTO_IPIP;
 	return ip_tunnel_init(dev);
 }
-- 
1.7.9.5
