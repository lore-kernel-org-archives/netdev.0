From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] [NET 2.6.26]: Add per-connection option to set max TSO frame
	size
Date: Wed, 05 Mar 2008 09:35:10 -0800
Message-ID: <20080305173510.5681.17426.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63864 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759011AbYCFAi4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 19:38:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update: My mailer ate one of Jarek's feedback mails...  Fixed the parameter
in netif_set_gso_max_size() to be u32, not u16.  Fixed the whitespace issue
due to a patch import botch.  Changed the types from u32 to unsigned int to
be more consistent with other variables in the area.  Also brought the patch
up to the latest net-2.6.26 tree.

Update: Made gso_max_size container 32 bits, not 16.  Moved the
location of gso_max_size within netdev to be less hotpath.  Made
more consistent names between the sock and netdev layers, and added a
define for the max GSO size.

Update: Respun for net-2.6.26 tree.

Update: changed max_gso_frame_size and sk_gso_max_size from signed to
unsigned - thanks Stephen!

This patch adds the ability for device drivers to control the size of the
TSO frames being sent to them, per TCP connection.  By setting the
netdevice's gso_max_size value, the socket layer will set the GSO
frame size based on that value.  This will propogate into the TCP layer,
and send TSO's of that size to the hardware.

This can be desirable to help tune the bursty nature of TSO on a
per-adapter basis, where one may have 1 GbE and 10 GbE devices coexisting
in a system, one running multiqueue and the other not, etc.

This can also be desirable for devices that cannot support full 64 KB
TSO's, but still want to benefit from some level of segmentation
offloading.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 include/linux/netdevice.h |   10 ++++++++++
 include/net/sock.h        |    2 ++
 net/core/dev.c            |    1 +
 net/core/sock.c           |    6 ++++--
 net/ipv4/tcp_output.c     |    4 ++--
 5 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a2f0032..ced61f8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -724,6 +724,10 @@ struct net_device
 	/* rtnetlink link ops */
 	const struct rtnl_link_ops *rtnl_link_ops;
 
+	/* for setting kernel sock attribute on TCP connection setup */
+#define GSO_MAX_SIZE		65536
+	unsigned int		gso_max_size;
+
 	/* The TX queue control structures */
 	unsigned int			egress_subqueue_count;
 	struct net_device_subqueue	egress_subqueue[1];
@@ -1475,6 +1479,12 @@ static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
 		unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
 }
 
+static inline void netif_set_gso_max_size(struct net_device *dev,
+					  unsigned int size)
+{
+	dev->gso_max_size = size;
+}
+
 /* On bonding slaves other than the currently active slave, suppress
  * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
  * ARP on active-backup slaves with arp_validate enabled.
diff --git a/include/net/sock.h b/include/net/sock.h
index 39112e7..8358fff 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -151,6 +151,7 @@ struct sock_common {
   *	@sk_no_check: %SO_NO_CHECK setting, wether or not checkup packets
   *	@sk_route_caps: route capabilities (e.g. %NETIF_F_TSO)
   *	@sk_gso_type: GSO type (e.g. %SKB_GSO_TCPV4)
+  *	@sk_gso_max_size: Maximum GSO segment size to build
   *	@sk_lingertime: %SO_LINGER l_linger setting
   *	@sk_backlog: always used with the per-socket spinlock held
   *	@sk_callback_lock: used with the callbacks in the end of this struct
@@ -237,6 +238,7 @@ struct sock {
 	gfp_t			sk_allocation;
 	int			sk_route_caps;
 	int			sk_gso_type;
+	unsigned int		sk_gso_max_size;
 	int			sk_rcvlowat;
 	unsigned long 		sk_flags;
 	unsigned long	        sk_lingertime;
diff --git a/net/core/dev.c b/net/core/dev.c
index fcdf03c..f973e38 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4021,6 +4021,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	}
 
 	dev->egress_subqueue_count = queue_count;
+	dev->gso_max_size = GSO_MAX_SIZE;
 
 	dev->get_stats = internal_stats;
 	netpoll_netdev_init(dev);
diff --git a/net/core/sock.c b/net/core/sock.c
index 0ca0697..3629c77 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1095,10 +1095,12 @@ void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 	if (sk->sk_route_caps & NETIF_F_GSO)
 		sk->sk_route_caps |= NETIF_F_GSO_SOFTWARE;
 	if (sk_can_gso(sk)) {
-		if (dst->header_len)
+		if (dst->header_len) {
 			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
-		else
+		} else {
 			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
+			sk->sk_gso_max_size = dst->dev->gso_max_size;
+		}
 	}
 }
 EXPORT_SYMBOL_GPL(sk_setup_caps);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cbfef8b..2c9cdb1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -998,7 +998,7 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 	xmit_size_goal = mss_now;
 
 	if (doing_tso) {
-		xmit_size_goal = (65535 -
+		xmit_size_goal = ((sk->sk_gso_max_size - 1) -
 				  inet_csk(sk)->icsk_af_ops->net_header_len -
 				  inet_csk(sk)->icsk_ext_hdr_len -
 				  tp->tcp_header_len);
@@ -1274,7 +1274,7 @@ static int tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 	limit = min(send_win, cong_win);
 
 	/* If a full-sized TSO skb can be sent, do it. */
-	if (limit >= 65536)
+	if (limit >= sk->sk_gso_max_size)
 		goto send_now;
 
 	if (sysctl_tcp_tso_win_divisor) {

