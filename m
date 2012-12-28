From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux kernel handling of IPv6 temporary addresses
Date: Fri, 28 Dec 2012 09:19:25 -0800
Message-ID: <1356715165.21409.296.camel@edumazet-glaptop>
References: <20121114231411.4328fc47@lola.kot>
	 <20121114.162956.610530798200803185.davem@davemloft.net>
	 <20121115010324.2707950c@lola.kot>
	 <20121114.180824.1930899985436392426.davem@davemloft.net>
	 <20121227175735.26c70cbb@lola.kot>
	 <1356627241.30414.1079.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: George Kargiotakis <kargig@void.gr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:62755 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693Ab2L1RT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 12:19:29 -0500
Received: by mail-pa0-f49.google.com with SMTP id bi1so6118872pad.22
        for <netdev@vger.kernel.org>; Fri, 28 Dec 2012 09:19:28 -0800 (PST)
In-Reply-To: <1356627241.30414.1079.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-27 at 08:54 -0800, Eric Dumazet wrote:

> We should only rate limit, and not disable forever.
> 

Something like :

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index dd52d51..32d51e2 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1282,7 +1282,7 @@ max_desync_factor - INTEGER
 	Default: 600
 
 regen_max_retry - INTEGER
-	Number of attempts before give up attempting to generate
+	Number of attempts per second before give up attempting to generate
 	valid temporary addresses.
 	Default: 5
 
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 9356322..8f206cf 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -70,6 +70,7 @@ struct inet6_ifaddr {
 	struct list_head	tmp_list;
 	struct inet6_ifaddr	*ifpub;
 	int			regen_count;
+	u32			regen_stamp;
 #endif
 	struct rcu_head		rcu;
 };
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 408cac4a..c41925c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -980,6 +980,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 	int max_addresses;
 	u32 addr_flags;
 	unsigned long now = jiffies;
+	u32 stamp;
 
 	write_lock(&idev->lock);
 	if (ift) {
@@ -994,18 +995,22 @@ retry:
 	in6_dev_hold(idev);
 	if (idev->cnf.use_tempaddr <= 0) {
 		write_unlock(&idev->lock);
-		pr_info("%s: use_tempaddr is disabled\n", __func__);
+		pr_info_ratelimited("%s: use_tempaddr is disabled\n", __func__);
 		in6_dev_put(idev);
 		ret = -1;
 		goto out;
 	}
 	spin_lock_bh(&ifp->lock);
+	stamp = jiffies / HZ;
+	if (stamp != ifp->regen_stamp) {
+		ifp->regen_stamp = stamp;
+		ifp->regen_count = 0;
+	}
 	if (ifp->regen_count++ >= idev->cnf.regen_max_retry) {
-		idev->cnf.use_tempaddr = -1;	/*XXX*/
 		spin_unlock_bh(&ifp->lock);
 		write_unlock(&idev->lock);
-		pr_warn("%s: regeneration time exceeded - disabled temporary address support\n",
-			__func__);
+		pr_warn_ratelimited("%s: regeneration time exceeded - disabled temporary address support\n",
+				    __func__);
 		in6_dev_put(idev);
 		ret = -1;
 		goto out;
