From: Andy Zhou <azhou@nicira.com>
Subject: [net-next] openvswitch: fix a compilation error when CONFIG_INET is not setW!
Date: Mon,  6 Oct 2014 15:15:14 -0700
Message-ID: <1412633714-25048-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:47656 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751098AbaJFWVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 18:21:18 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so3945362pdb.35
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 15:21:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a openvswitch compilation error when CONFIG_INET is not set:

=====================================================
   In file included from include/net/geneve.h:4:0,
                       from net/openvswitch/flow_netlink.c:45:
		          include/net/udp_tunnel.h: In function 'udp_tunnel_handle_offloads':
			  >> include/net/udp_tunnel.h:100:2: error: implicit declaration of function 'iptunnel_handle_offloads' [-Werror=implicit-function-declaration]
			  >>      return iptunnel_handle_offloads(skb, udp_csum, type);
			  >>           ^
			  >>           >> include/net/udp_tunnel.h:100:2: warning: return makes pointer from integer without a cast
			  >>           >>    cc1: some warnings being treated as errors

=====================================================

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 drivers/net/Kconfig  |    1 -
 include/net/geneve.h |   36 +++++++++++++++++++++---------------
 net/ipv4/Kconfig     |   29 +++++++++++++++--------------
 3 files changed, 36 insertions(+), 30 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c6f6f69..4706386 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -147,7 +147,6 @@ config MACVTAP
 config VXLAN
        tristate "Virtual eXtensible Local Area Network (VXLAN)"
        depends on INET
-       select NET_IP_TUNNEL
        select NET_UDP_TUNNEL
        ---help---
 	  This allows one to create vxlan virtual interfaces that provide
diff --git a/include/net/geneve.h b/include/net/geneve.h
index ce98865..112132c 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -1,22 +1,10 @@
 #ifndef __NET_GENEVE_H
 #define __NET_GENEVE_H  1
 
+#ifdef CONFIG_INET
 #include <net/udp_tunnel.h>
+#endif
 
-struct geneve_sock;
-
-typedef void (geneve_rcv_t)(struct geneve_sock *gs, struct sk_buff *skb);
-
-struct geneve_sock {
-	struct hlist_node	hlist;
-	geneve_rcv_t		*rcv;
-	void			*rcv_data;
-	struct work_struct	del_work;
-	struct socket		*sock;
-	struct rcu_head		rcu;
-	atomic_t		refcnt;
-	struct udp_offload	udp_offloads;
-};
 
 /* Geneve Header:
  *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@@ -74,6 +62,22 @@ struct genevehdr {
 	struct geneve_opt options[];
 };
 
+#ifdef CONFIG_INET
+struct geneve_sock;
+
+typedef void (geneve_rcv_t)(struct geneve_sock *gs, struct sk_buff *skb);
+
+struct geneve_sock {
+	struct hlist_node	hlist;
+	geneve_rcv_t		*rcv;
+	void			*rcv_data;
+	struct work_struct	del_work;
+	struct socket		*sock;
+	struct rcu_head		rcu;
+	atomic_t		refcnt;
+	struct udp_offload	udp_offloads;
+};
+
 #define GENEVE_VER 0
 #define GENEVE_BASE_HLEN (sizeof(struct udphdr) + sizeof(struct genevehdr))
 
@@ -88,4 +92,6 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
 		    __u8 ttl, __be16 df, __be16 src_port, __be16 dst_port,
 		    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
 		    bool xnet);
-#endif
+#endif /*ifdef CONFIG_INET */
+
+#endif /*ifdef__NET_GENEVE_H */
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index c203544..e682b48 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -309,6 +309,7 @@ config NET_IPVTI
 
 config NET_UDP_TUNNEL
 	tristate
+	select NET_IP_TUNNEL
 	default n
 
 config NET_FOU
@@ -321,6 +322,20 @@ config NET_FOU
 	  network mechanisms and optimizations for UDP (such as ECMP
 	  and RSS) can be leveraged to provide better service.
 
+config GENEVE
+	tristate "Generic Network Virtualization Encapsulation (Geneve)"
+	depends on INET
+	select NET_UDP_TUNNEL
+	---help---
+	This allows one to create Geneve virtual interfaces that provide
+	Layer 2 Networks over Layer 3 Networks. Geneve is often used
+	to tunnel virtual network infrastructure in virtualized environments.
+	For more information see:
+	  http://tools.ietf.org/html/draft-gross-geneve-01
+
+	  To compile this driver as a module, choose M here: the module
+
+
 config INET_AH
 	tristate "IP: AH transformation"
 	select XFRM_ALGO
@@ -453,20 +468,6 @@ config TCP_CONG_BIC
 	increase provides TCP friendliness.
 	See http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/
 
-config GENEVE
-	tristate "Generic Network Virtualization Encapsulation (Geneve)"
-	depends on INET
-	select NET_IP_TUNNEL
-	select NET_UDP_TUNNEL
-	---help---
-	This allows one to create Geneve virtual interfaces that provide
-	Layer 2 Networks over Layer 3 Networks. Geneve is often used
-	to tunnel virtual network infrastructure in virtualized environments.
-	For more information see:
-	  http://tools.ietf.org/html/draft-gross-geneve-01
-
-	  To compile this driver as a module, choose M here: the module
-
 config TCP_CONG_CUBIC
 	tristate "CUBIC TCP"
 	default y
-- 
1.7.9.5
