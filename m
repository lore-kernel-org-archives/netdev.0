From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 33/33] Enable netfilter in netns
Date: Mon,  8 Sep 2008 07:03:10 +0400
Message-ID: <1220842990-30500-33-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.184]:64074 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137AbYIHDDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 23:03:35 -0400
Received: by gv-out-0910.google.com with SMTP id e6so91840gvc.37
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 20:03:35 -0700 (PDT)
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From kernel perspective, allow entrance in nf_hook_slow().

Stuff which uses nf_register_hook/nf_register_hooks, but otherwise not netns-ready:

	DECnet netfilter
	ipt_CLUSTERIP
	nf_nat_standalone.c together with XFRM (?)
	IPVS
	several individual match modules (like hashlimit)
	ctnetlink
	NOTRACK
	all sorts of queueing and reporting to userspace
	L3 and L4 protocol sysctls, bridge sysctls
	probably something else

Anyway critical mass has been achieved, there is no reason to hide netfilter any longer.

>From userspace perspective, allow to manipulate all sorts of                                                                                                                                                                                   
iptables/ip6tables/arptables rules.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index b16cd79..a90ac83 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -165,14 +165,6 @@ int nf_hook_slow(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
 	unsigned int verdict;
 	int ret = 0;
 
-#ifdef CONFIG_NET_NS
-	struct net *net;
-
-	net = indev == NULL ? dev_net(outdev) : dev_net(indev);
-	if (net != &init_net)
-		return 1;
-#endif
-
 	/* We may already have this, but read-locks nest anyway */
 	rcu_read_lock();
 
diff --git a/net/netfilter/nf_sockopt.c b/net/netfilter/nf_sockopt.c
index f9b46de..8ab829f 100644
--- a/net/netfilter/nf_sockopt.c
+++ b/net/netfilter/nf_sockopt.c
@@ -65,9 +65,6 @@ static struct nf_sockopt_ops *nf_sockopt_find(struct sock *sk, u_int8_t pf,
 {
 	struct nf_sockopt_ops *ops;
 
-	if (!net_eq(sock_net(sk), &init_net))
-		return ERR_PTR(-ENOPROTOOPT);
-
 	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
 		return ERR_PTR(-EINTR);
 
