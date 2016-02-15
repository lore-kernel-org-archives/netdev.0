From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 2/6] igmp: net: Move igmp namespace init to correct file
Date: Mon, 15 Feb 2016 12:11:28 +0200
Message-ID: <1455531092-23184-3-git-send-email-kernel@kyup.com>
References: <1455531092-23184-1-git-send-email-kernel@kyup.com>
Cc: netfilter-devel@vger.kernel.org, ebiederm@xmission.com,
	pabeni@redhat.com, jmorris@namei.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37186 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732AbcBOKLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 05:11:38 -0500
Received: by mail-wm0-f51.google.com with SMTP id g62so101541667wme.0
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 02:11:38 -0800 (PST)
In-Reply-To: <1455531092-23184-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When igmp related sysctl were namespacified their initializatin was
erroneously put into the tcp socket namespace constructor. This
patch moves the relevant code into the igmp namespace constructor to
keep things consistent.

Also sprinkle some #ifdefs to silence warnings

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 net/ipv4/igmp.c     | 14 ++++++++++++++
 net/ipv4/tcp_ipv4.c |  6 ------
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 7c95335bf85e..2aea9f1a2a31 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1224,7 +1224,9 @@ static void igmp_group_dropped(struct ip_mc_list *im)
 static void igmp_group_added(struct ip_mc_list *im)
 {
 	struct in_device *in_dev = im->interface;
+#ifdef CONFIG_IP_MULTICAST
 	struct net *net = dev_net(in_dev->dev);
+#endif
 
 	if (im->loaded == 0) {
 		im->loaded = 1;
@@ -1316,7 +1318,9 @@ static void ip_mc_hash_remove(struct in_device *in_dev,
 void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 {
 	struct ip_mc_list *im;
+#ifdef CONFIG_IP_MULTICAST
 	struct net *net = dev_net(in_dev->dev);
+#endif
 
 	ASSERT_RTNL();
 
@@ -1643,7 +1647,9 @@ void ip_mc_down(struct in_device *in_dev)
 
 void ip_mc_init_dev(struct in_device *in_dev)
 {
+#ifdef CONFIG_IP_MULTICAST
 	struct net *net = dev_net(in_dev->dev);
+#endif
 	ASSERT_RTNL();
 
 #ifdef CONFIG_IP_MULTICAST
@@ -1662,7 +1668,9 @@ void ip_mc_init_dev(struct in_device *in_dev)
 void ip_mc_up(struct in_device *in_dev)
 {
 	struct ip_mc_list *pmc;
+#ifdef CONFIG_IP_MULTICAST
 	struct net *net = dev_net(in_dev->dev);
+#endif
 
 	ASSERT_RTNL();
 
@@ -2923,6 +2931,12 @@ static int __net_init igmp_net_init(struct net *net)
 		goto out_sock;
 	}
 
+	/* Sysctl initialization */
+	net->ipv4.sysctl_igmp_max_memberships = 20;
+	net->ipv4.sysctl_igmp_max_msf = 10;
+	/* IGMP reports for link-local multicast groups are enabled by default */
+	net->ipv4.sysctl_igmp_llm_reports = 1;
+	net->ipv4.sysctl_igmp_qrv = 2;
 	return 0;
 
 out_sock:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ba5d0146e3f0..3f872a6bc274 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2399,12 +2399,6 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_fin_timeout = TCP_FIN_TIMEOUT;
 	net->ipv4.sysctl_tcp_notsent_lowat = UINT_MAX;
 
-	net->ipv4.sysctl_igmp_max_memberships = 20;
-	net->ipv4.sysctl_igmp_max_msf = 10;
-	/* IGMP reports for link-local multicast groups are enabled by default */
-	net->ipv4.sysctl_igmp_llm_reports = 1;
-	net->ipv4.sysctl_igmp_qrv = 2;
-
 	return 0;
 fail:
 	tcp_sk_exit(net);
-- 
2.5.0
