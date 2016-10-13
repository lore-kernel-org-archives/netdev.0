From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH 1/2] IPv6: Drop the temporary address regen_timer
Date: Thu, 13 Oct 2016 18:50:02 +0200
Message-ID: <20161013165002.zn7wgjbacs34i73i@dwarf.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57693 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933132AbcJMQ7E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 12:59:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The randomized interface identifier (rndid) was periodically updated from
the regen_timer timer. Simplify the code by updating the rndid only when
needed by ipv6_try_regen_rndid().

This makes the follow-up DESYNC_FACTOR fix much simpler.  Also it fixes a
reference counting error in this error path, where an in6_dev_put was
missing:
		err = addrconf_sysctl_register(ndev);
		if (err) {
			ipv6_mc_destroy_dev(ndev);
	-               del_timer(&ndev->regen_timer);
			snmp6_unregister_dev(ndev);
			goto err_release;

Signed-off-by: Jiri Bohac <jbohac@suse.cz>
---
 include/net/if_inet6.h |  1 -
 net/ipv6/addrconf.c    | 61 ++++++++------------------------------------------
 2 files changed, 9 insertions(+), 53 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 515352c..ae70735 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -191,7 +191,6 @@ struct inet6_dev {
 	int			dead;
 
 	u8			rndid[8];
-	struct timer_list	regen_timer;
 	struct list_head	tempaddr_list;
 
 	struct in6_addr		token;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d8983e1..63fc857 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -147,9 +147,8 @@ static inline void addrconf_sysctl_unregister(struct inet6_dev *idev)
 }
 #endif
 
-static void __ipv6_regen_rndid(struct inet6_dev *idev);
-static void __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr);
-static void ipv6_regen_rndid(unsigned long data);
+static void ipv6_regen_rndid(struct inet6_dev *idev);
+static void ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr);
 
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
 static int ipv6_count_addresses(struct inet6_dev *idev);
@@ -409,9 +408,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 		goto err_release;
 	}
 
-	/* One reference from device.  We must do this before
-	 * we invoke __ipv6_regen_rndid().
-	 */
+	/* One reference from device. */
 	in6_dev_hold(ndev);
 
 	if (dev->flags & (IFF_NOARP | IFF_LOOPBACK))
@@ -425,17 +422,14 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 #endif
 
 	INIT_LIST_HEAD(&ndev->tempaddr_list);
-	setup_timer(&ndev->regen_timer, ipv6_regen_rndid, (unsigned long)ndev);
 	if ((dev->flags&IFF_LOOPBACK) ||
 	    dev->type == ARPHRD_TUNNEL ||
 	    dev->type == ARPHRD_TUNNEL6 ||
 	    dev->type == ARPHRD_SIT ||
 	    dev->type == ARPHRD_NONE) {
 		ndev->cnf.use_tempaddr = -1;
-	} else {
-		in6_dev_hold(ndev);
-		ipv6_regen_rndid((unsigned long) ndev);
-	}
+	} else
+		ipv6_regen_rndid(ndev);
 
 	ndev->token = in6addr_any;
 
@@ -447,7 +441,6 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	err = addrconf_sysctl_register(ndev);
 	if (err) {
 		ipv6_mc_destroy_dev(ndev);
-		del_timer(&ndev->regen_timer);
 		snmp6_unregister_dev(ndev);
 		goto err_release;
 	}
@@ -1222,7 +1215,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 	}
 	in6_ifa_hold(ifp);
 	memcpy(addr.s6_addr, ifp->addr.s6_addr, 8);
-	__ipv6_try_regen_rndid(idev, tmpaddr);
+	ipv6_try_regen_rndid(idev, tmpaddr);
 	memcpy(&addr.s6_addr[8], idev->rndid, 8);
 	age = (now - ifp->tstamp) / HZ;
 	tmp_valid_lft = min_t(__u32,
@@ -2150,7 +2143,7 @@ static int ipv6_inherit_eui64(u8 *eui, struct inet6_dev *idev)
 }
 
 /* (re)generation of randomized interface identifier (RFC 3041 3.2, 3.5) */
-static void __ipv6_regen_rndid(struct inet6_dev *idev)
+static void ipv6_regen_rndid(struct inet6_dev *idev)
 {
 regen:
 	get_random_bytes(idev->rndid, sizeof(idev->rndid));
@@ -2179,43 +2172,10 @@ static void __ipv6_regen_rndid(struct inet6_dev *idev)
 	}
 }
 
-static void ipv6_regen_rndid(unsigned long data)
-{
-	struct inet6_dev *idev = (struct inet6_dev *) data;
-	unsigned long expires;
-
-	rcu_read_lock_bh();
-	write_lock_bh(&idev->lock);
-
-	if (idev->dead)
-		goto out;
-
-	__ipv6_regen_rndid(idev);
-
-	expires = jiffies +
-		idev->cnf.temp_prefered_lft * HZ -
-		idev->cnf.regen_max_retry * idev->cnf.dad_transmits *
-		NEIGH_VAR(idev->nd_parms, RETRANS_TIME) -
-		idev->cnf.max_desync_factor * HZ;
-	if (time_before(expires, jiffies)) {
-		pr_warn("%s: too short regeneration interval; timer disabled for %s\n",
-			__func__, idev->dev->name);
-		goto out;
-	}
-
-	if (!mod_timer(&idev->regen_timer, expires))
-		in6_dev_hold(idev);
-
-out:
-	write_unlock_bh(&idev->lock);
-	rcu_read_unlock_bh();
-	in6_dev_put(idev);
-}
-
-static void  __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr)
+static void  ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr)
 {
 	if (tmpaddr && memcmp(idev->rndid, &tmpaddr->s6_addr[8], 8) == 0)
-		__ipv6_regen_rndid(idev);
+		ipv6_regen_rndid(idev);
 }
 
 /*
@@ -3594,9 +3554,6 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	if (!how)
 		idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD|IF_READY);
 
-	if (how && del_timer(&idev->regen_timer))
-		in6_dev_put(idev);
-
 	/* Step 3: clear tempaddr list */
 	while (!list_empty(&idev->tempaddr_list)) {
 		ifa = list_first_entry(&idev->tempaddr_list,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
