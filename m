From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 6/7] ipv6: Generic tunnel cleanup
Date: Fri, 29 Apr 2016 17:12:20 -0700
Message-ID: <1461975141-954269-7-git-send-email-tom@herbertland.com>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34714 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752650AbcD3AOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 20:14:49 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3U0CCOl024755
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:48 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22mggpg9ew-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:48 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 8bd3b3ca0e6811e6b5d224be0595f910-d43f7c50 for <netdev@vger.kernel.org>;	Fri,
 29 Apr 2016 17:14:46 -0700
In-Reply-To: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few generic changes to generalize tunnels in IPv6:
  - Export ip6_tnl_change_mtu so that it can be called by ip6_gre
  - Add tun_hlen to ip6_tnl structure.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/ip6_tunnel.h | 5 ++++-
 net/ipv6/ip6_tunnel.c    | 7 +++++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 835491b..fb9e015 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -50,8 +50,10 @@ struct ip6_tnl {
 	/* These fields used only by GRE */
 	__u32 i_seqno;	/* The last seen seqno	*/
 	__u32 o_seqno;	/* The last output seqno */
-	int hlen;       /* Precalculated GRE header length */
+	int hlen;       /* tun_hlen + encap_hlen */
+	int tun_hlen;	/* Precalculated header length */
 	int mlink;
+
 };
 
 /* Tunnel encapsulation limit destination sub-option */
@@ -76,6 +78,7 @@ __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
 			     const struct in6_addr *raddr);
 struct net *ip6_tnl_get_link_net(const struct net_device *dev);
 int ip6_tnl_get_iflink(const struct net_device *dev);
+int ip6_tnl_change_mtu(struct net_device *dev, int new_mtu);
 
 #ifdef CONFIG_INET
 static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index b1f31d2..ade55af 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1540,8 +1540,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
  *   %-EINVAL if mtu too small
  **/
 
-static int
-ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
+int ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct ip6_tnl *tnl = netdev_priv(dev);
 
@@ -1557,6 +1556,7 @@ ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
 	dev->mtu = new_mtu;
 	return 0;
 }
+EXPORT_SYMBOL(ip6_tnl_change_mtu);
 
 int ip6_tnl_get_iflink(const struct net_device *dev)
 {
@@ -1632,6 +1632,9 @@ ip6_tnl_dev_init_gen(struct net_device *dev)
 	if (ret)
 		goto destroy_dst;
 
+	t->hlen = 0;
+	t->tun_hlen = 0;
+
 	return 0;
 
 destroy_dst:
-- 
2.8.0.rc2
