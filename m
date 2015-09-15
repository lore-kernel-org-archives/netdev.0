From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v4 net 1/5] ipv6: Refactor common ip6gre_tunnel_init codes
Date: Tue, 15 Sep 2015 14:30:05 -0700
Message-ID: <1442352609-1476011-2-git-send-email-kafai@fb.com>
References: <1442352609-1476011-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:16983 "EHLO
	m0001303.ppops.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751670AbbIOVaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 17:30:39 -0400
Received: from pps.filterd (m0001303 [127.0.0.1])
	by m0001303.ppops.net (8.14.5/8.14.5) with SMTP id t8FLSXuM021024
	for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 14:30:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1wxu1p02hx-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 14:30:39 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 01532ae85bf111e596940002c991e86a-bc9f9240 for <netdev@vger.kernel.org>;	Tue,
 15 Sep 2015 14:30:37 -0700
In-Reply-To: <1442352609-1476011-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a prep work to fix the dst_entry refcnt bugs in ip6_tunnel.

This patch refactors some common init codes used by both
ip6gre_tunnel_init and ip6gre_tap_init.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/ip6_gre.c | 37 ++++++++++++++++++++++++-------------
 1 file changed, 24 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 4038c69..af60d46 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1245,7 +1245,7 @@ static void ip6gre_tunnel_setup(struct net_device *dev)
 	netif_keep_dst(dev);
 }
 
-static int ip6gre_tunnel_init(struct net_device *dev)
+static int ip6gre_tunnel_init_common(struct net_device *dev)
 {
 	struct ip6_tnl *tunnel;
 
@@ -1255,16 +1255,30 @@ static int ip6gre_tunnel_init(struct net_device *dev)
 	tunnel->net = dev_net(dev);
 	strcpy(tunnel->parms.name, dev->name);
 
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static int ip6gre_tunnel_init(struct net_device *dev)
+{
+	struct ip6_tnl *tunnel;
+	int ret;
+
+	ret = ip6gre_tunnel_init_common(dev);
+	if (ret)
+		return ret;
+
+	tunnel = netdev_priv(dev);
+
 	memcpy(dev->dev_addr, &tunnel->parms.laddr, sizeof(struct in6_addr));
 	memcpy(dev->broadcast, &tunnel->parms.raddr, sizeof(struct in6_addr));
 
 	if (ipv6_addr_any(&tunnel->parms.raddr))
 		dev->header_ops = &ip6gre_header_ops;
 
-	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
-	if (!dev->tstats)
-		return -ENOMEM;
-
 	return 0;
 }
 
@@ -1460,19 +1474,16 @@ static void ip6gre_netlink_parms(struct nlattr *data[],
 static int ip6gre_tap_init(struct net_device *dev)
 {
 	struct ip6_tnl *tunnel;
+	int ret;
 
-	tunnel = netdev_priv(dev);
+	ret = ip6gre_tunnel_init_common(dev);
+	if (ret)
+		return ret;
 
-	tunnel->dev = dev;
-	tunnel->net = dev_net(dev);
-	strcpy(tunnel->parms.name, dev->name);
+	tunnel = netdev_priv(dev);
 
 	ip6gre_tnl_link_config(tunnel, 1);
 
-	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
-	if (!dev->tstats)
-		return -ENOMEM;
-
 	return 0;
 }
 
-- 
2.5.1
