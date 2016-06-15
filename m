From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 01/17] vxlan/geneve: Include udp_tunnel.h in
 vxlan/geneve.h and fixup includes
Date: Wed, 15 Jun 2016 15:07:22 -0700
Message-ID: <20160615220722.15575.27178.stgit@localhost.localdomain>
References: <20160615220449.15575.17031.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, eugenia@mellanox.com,
	jbenc@redhat.com, alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35150 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819AbcFOWHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 18:07:24 -0400
Received: by mail-pf0-f169.google.com with SMTP id c2so12759873pfa.2
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 15:07:24 -0700 (PDT)
In-Reply-To: <20160615220449.15575.17031.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes it so that we add udp_tunnel.h to vxlan.h and geneve.h
header files.  This is useful as I plan to move the generic handlers for
the port offloads into the udp_tunnel header file and leave the vxlan and
geneve headers to be a bit more protocol specific.

I also went through and cleaned out a number of redundant includes that
where in the .h and .c files for these drivers.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/geneve.c     |    1 -
 drivers/net/vxlan.c      |   17 -----------------
 include/net/geneve.h     |    3 ---
 include/net/udp_tunnel.h |    2 ++
 include/net/vxlan.h      |    6 +-----
 5 files changed, 3 insertions(+), 26 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index cadefe4fdaa2..e5e33cd01082 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -12,7 +12,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/hash.h>
 #include <net/dst_metadata.h>
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f999db2f97b4..10ad41d60652 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -11,32 +11,18 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/kernel.h>
-#include <linux/types.h>
 #include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/slab.h>
-#include <linux/skbuff.h>
-#include <linux/rculist.h>
-#include <linux/netdevice.h>
-#include <linux/in.h>
-#include <linux/ip.h>
 #include <linux/udp.h>
 #include <linux/igmp.h>
-#include <linux/etherdevice.h>
 #include <linux/if_ether.h>
-#include <linux/if_vlan.h>
-#include <linux/hash.h>
 #include <linux/ethtool.h>
 #include <net/arp.h>
 #include <net/ndisc.h>
 #include <net/ip.h>
-#include <net/ip_tunnels.h>
 #include <net/icmp.h>
-#include <net/udp.h>
-#include <net/udp_tunnel.h>
 #include <net/rtnetlink.h>
-#include <net/route.h>
-#include <net/dsfield.h>
 #include <net/inet_ecn.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
@@ -44,12 +30,9 @@
 #include <net/protocol.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
-#include <net/ipv6.h>
-#include <net/addrconf.h>
 #include <net/ip6_tunnel.h>
 #include <net/ip6_checksum.h>
 #endif
-#include <net/dst_metadata.h>
 
 #define VXLAN_VERSION	"0.1"
 
diff --git a/include/net/geneve.h b/include/net/geneve.h
index cb544a530146..f8aff18d6702 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -1,10 +1,7 @@
 #ifndef __NET_GENEVE_H
 #define __NET_GENEVE_H  1
 
-#ifdef CONFIG_INET
 #include <net/udp_tunnel.h>
-#endif
-
 
 /* Geneve Header:
  *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 9d14f707e534..59019562d14c 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -105,12 +105,14 @@ struct metadata_dst *udp_tun_rx_dst(struct sk_buff *skb, unsigned short family,
 				    __be16 flags, __be64 tunnel_id,
 				    int md_size);
 
+#ifdef CONFIG_INET
 static inline int udp_tunnel_handle_offloads(struct sk_buff *skb, bool udp_csum)
 {
 	int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 
 	return iptunnel_handle_offloads(skb, type);
 }
+#endif
 
 static inline void udp_tunnel_encap_enable(struct socket *sock)
 {
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index b8803165df91..7d944941f32f 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -1,12 +1,8 @@
 #ifndef __NET_VXLAN_H
 #define __NET_VXLAN_H 1
 
-#include <linux/ip.h>
-#include <linux/ipv6.h>
 #include <linux/if_vlan.h>
-#include <linux/skbuff.h>
-#include <linux/netdevice.h>
-#include <linux/udp.h>
+#include <net/udp_tunnel.h>
 #include <net/dst_metadata.h>
 
 /* VXLAN protocol (RFC 7348) header:
