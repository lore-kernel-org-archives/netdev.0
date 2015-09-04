From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v2 net 1/5] ipv6: Refactor common ip6gre_tunnel_init codes
Date: Fri, 4 Sep 2015 16:12:38 -0700
Message-ID: <1441408362-4177515-2-git-send-email-kafai@fb.com>
References: <1441408362-4177515-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37147 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933992AbbIDXM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 19:12:57 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t84NB7pO007210
	for <netdev@vger.kernel.org>; Fri, 4 Sep 2015 16:12:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wqme5g2h7-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 04 Sep 2015 16:12:57 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 79707ac0535a11e5bc530002c99331b0-5bbf4240 for <netdev@vger.kernel.org>;	Fri,
 04 Sep 2015 16:12:55 -0700
In-Reply-To: <1441408362-4177515-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a prep work to fix the dst_entry refcnt bugs in ip6_tunnel.

This patch refactors some common init codes used by both
ip6gre_tunnel_init and ip6gre_tap_init.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/ip6_gre.c | 42 +++++++++++++++++++++++++-----------------
 1 file changed, 25 insertions(+), 17 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 7b5758b..be6b0b9 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1244,7 +1244,7 @@ static void ip6gre_tunnel_setup(struct net_device *dev)
 	netif_keep_dst(dev);
 }
 
-static int ip6gre_tunnel_init(struct net_device *dev)
+static int ip6gre_tunnel_init_common(struct net_device *dev)
 {
 	struct ip6_tnl *tunnel;
 
@@ -1253,6 +1253,25 @@ static int ip6gre_tunnel_init(struct net_device *dev)
 	tunnel->dev = dev;
 	tunnel->net = dev_net(dev);
 	strcpy(tunnel->parms.name, dev->name);
+	dev->iflink = tunnel->parms.link;
+
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
 
 	memcpy(dev->dev_addr, &tunnel->parms.laddr, sizeof(struct in6_addr));
 	memcpy(dev->broadcast, &tunnel->parms.raddr, sizeof(struct in6_addr));
@@ -1260,12 +1279,6 @@ static int ip6gre_tunnel_init(struct net_device *dev)
 	if (ipv6_addr_any(&tunnel->parms.raddr))
 		dev->header_ops = &ip6gre_header_ops;
 
-	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
-	if (!dev->tstats)
-		return -ENOMEM;
-
-	dev->iflink = tunnel->parms.link;
-
 	return 0;
 }
 
@@ -1461,21 +1474,16 @@ static void ip6gre_netlink_parms(struct nlattr *data[],
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
-	dev->iflink = tunnel->parms.link;
-
 	return 0;
 }
 
-- 
1.8.1
