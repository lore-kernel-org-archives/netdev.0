From: Shmulik Ladkani <shmulik@nsof.io>
Subject: [PATCH net-next] ip6_tunnel: Allow rcv/xmit even if remote address is a local address
Date: Sat, 21 Oct 2017 00:25:15 +0300
Message-ID: <20171020212515.4678-1-shmulik@nsof.io>
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:47113 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752346AbdJTVZr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:25:47 -0400
Received: by mail-wr0-f195.google.com with SMTP id y39so12413392wrd.4
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:25:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Currently, ip6_tnl_xmit_ctl drops tunneled packets if the remote
address (outer v6 destination) is one of host's locally configured
addresses.
Same applies to ip6_tnl_rcv_ctl: it drops packets if the remote address
(outer v6 source) is a local address.

This prevents using ipxip6 (and ip6_gre) tunnels whose local/remote
endpoints are on same host; OTOH v4 tunnels (ipip or gre) allow such
configurations.

An example where this proves useful is a system where entities are
identified by their unique v6 addresses, and use tunnels to encapsulate
traffic between them. The limitation prevents placing several entities
on same host.

Introduce IP6_TNL_F_ALLOW_LOCAL_REMOTE which allows to bypass this
restriction.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
The restriction's history is pre-git era.

The warning in ip6_tnl_xmit_ctl states "Routing loop! Remote address
found on this node" - but having the outer v6 destination being a host
address does not necessarily mean the packets will go into a routing
loop: it depends on ip6_tunnel setup and routing setup for the packets
ingressing from the peer ip6_tunnel device.

Also, the same "routing loop" argument could have been applied to ipip
v4 tunnels, but these completely lack this validation.

Decided it is best for the admin to specify whether the restriction is
needed per tunnel. An alternative is to remove the restriction
completely.
---
 include/uapi/linux/ip6_tunnel.h | 2 ++
 net/ipv6/ip6_tunnel.c           | 6 ++++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/ip6_tunnel.h b/include/uapi/linux/ip6_tunnel.h
index 425926c467d7..ffebbe365478 100644
--- a/include/uapi/linux/ip6_tunnel.h
+++ b/include/uapi/linux/ip6_tunnel.h
@@ -20,6 +20,8 @@
 #define IP6_TNL_F_RCV_DSCP_COPY 0x10
 /* copy fwmark from inner packet */
 #define IP6_TNL_F_USE_ORIG_FWMARK 0x20
+/* allow remote endpoint on the local node */
+#define IP6_TNL_F_ALLOW_LOCAL_REMOTE 0x40
 
 struct ip6_tnl_parm {
 	char name[IFNAMSIZ];	/* name of tunnel device */
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 4212879ff35e..439d65f7e094 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -770,7 +770,8 @@ int ip6_tnl_rcv_ctl(struct ip6_tnl *t,
 
 		if ((ipv6_addr_is_multicast(laddr) ||
 		     likely(ipv6_chk_addr(net, laddr, ldev, 0))) &&
-		    likely(!ipv6_chk_addr(net, raddr, NULL, 0)))
+		    ((p->flags & IP6_TNL_F_ALLOW_LOCAL_REMOTE) ||
+		     likely(!ipv6_chk_addr(net, raddr, NULL, 0))))
 			ret = 1;
 	}
 	return ret;
@@ -1000,7 +1001,8 @@ int ip6_tnl_xmit_ctl(struct ip6_tnl *t,
 		if (unlikely(!ipv6_chk_addr(net, laddr, ldev, 0)))
 			pr_warn("%s xmit: Local address not yet configured!\n",
 				p->name);
-		else if (!ipv6_addr_is_multicast(raddr) &&
+		else if (!(p->flags & IP6_TNL_F_ALLOW_LOCAL_REMOTE) &&
+			 !ipv6_addr_is_multicast(raddr) &&
 			 unlikely(ipv6_chk_addr(net, raddr, NULL, 0)))
 			pr_warn("%s xmit: Routing loop! Remote address found on this node!\n",
 				p->name);
-- 
2.14.2
