From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 1/3] ipv6: Refactor common ip6gre_tunnel_init codes
Date: Tue, 1 Sep 2015 11:55:01 -0700
Message-ID: <1441133703-1570969-2-git-send-email-kafai@fb.com>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:25317 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751757AbbIASzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 14:55:15 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t81IrkpL011790
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 11:55:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wngjrr64c-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 11:55:15 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 f4e1861850da11e58f210002c95209d8-f53fd240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 11:55:04 -0700
In-Reply-To: <1441133703-1570969-1-git-send-email-kafai@fb.com>
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
index 69f4f68..495eab3 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1244,7 +1244,7 @@ static void ip6gre_tunnel_setup(struct net_device *dev)
 	netif_keep_dst(dev);
 }
 
-static int ip6gre_tunnel_init(struct net_device *dev)
+static int ip6gre_tunnel_init_common(struct net_device *dev)
 {
 	struct ip6_tnl *tunnel;
 
@@ -1254,16 +1254,30 @@ static int ip6gre_tunnel_init(struct net_device *dev)
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
 
@@ -1459,19 +1473,16 @@ static void ip6gre_netlink_parms(struct nlattr *data[],
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
1.8.1
