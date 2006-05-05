From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH] [IPV6] ADDRCONF: Convert addrconf_lock to RCU.
Date: Fri, 05 May 2006 12:24:52 +0900 (JST)
Message-ID: <20060505.122452.46183936.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:24837 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932462AbWEEDYo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 23:24:44 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 750e250..74dca37 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -127,20 +127,18 @@ extern int unregister_inet6addr_notifier
 static inline struct inet6_dev *
 __in6_dev_get(struct net_device *dev)
 {
-	return (struct inet6_dev *)dev->ip6_ptr;
+	return rcu_dereference(dev->ip6_ptr);
 }
 
-extern rwlock_t addrconf_lock;
-
 static inline struct inet6_dev *
 in6_dev_get(struct net_device *dev)
 {
 	struct inet6_dev *idev = NULL;
-	read_lock(&addrconf_lock);
-	idev = dev->ip6_ptr;
+	rcu_read_lock();
+	idev = __in6_dev_get(dev);
 	if (idev)
 		atomic_inc(&idev->refcnt);
-	read_unlock(&addrconf_lock);
+	rcu_read_unlock();
 	return idev;
 }
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index c23e9c0..e3b326d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1786,7 +1786,7 @@ static void pktgen_setup_inject(struct p
 			 * use ipv6_get_lladdr if/when it's get exported
 			 */
 
-			read_lock(&addrconf_lock);
+			rcu_read_lock();
 			if ((idev = __in6_dev_get(pkt_dev->odev)) != NULL) {
 				struct inet6_ifaddr *ifp;
 
@@ -1805,7 +1805,7 @@ static void pktgen_setup_inject(struct p
 				}
 				read_unlock_bh(&idev->lock);
 			}
-			read_unlock(&addrconf_lock);
+			rcu_read_unlock();
 			if (err)
 				printk("pktgen: ERROR: IPv6 link address not availble.\n");
 		}
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 445006e..6cb12d4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -118,9 +118,6 @@ static int ipv6_count_addresses(struct i
 static struct inet6_ifaddr		*inet6_addr_lst[IN6_ADDR_HSIZE];
 static DEFINE_RWLOCK(addrconf_hash_lock);
 
-/* Protects inet6 devices */
-DEFINE_RWLOCK(addrconf_lock);
-
 static void addrconf_verify(unsigned long);
 
 static DEFINE_TIMER(addr_chk_timer, addrconf_verify, 0, 0);
@@ -405,9 +402,8 @@ static struct inet6_dev * ipv6_add_dev(s
 	if (netif_carrier_ok(dev))
 		ndev->if_flags |= IF_READY;
 
-	write_lock_bh(&addrconf_lock);
-	dev->ip6_ptr = ndev;
-	write_unlock_bh(&addrconf_lock);
+	/* protected by rtnl_lock */
+	rcu_assign_pointer(dev->ip6_ptr, ndev);
 
 	ipv6_mc_init_dev(ndev);
 	ndev->tstamp = jiffies;
@@ -471,7 +467,7 @@ static void addrconf_forward_change(void
 
 	read_lock(&dev_base_lock);
 	for (dev=dev_base; dev; dev=dev->next) {
-		read_lock(&addrconf_lock);
+		rcu_read_lock();
 		idev = __in6_dev_get(dev);
 		if (idev) {
 			int changed = (!idev->cnf.forwarding) ^ (!ipv6_devconf.forwarding);
@@ -479,7 +475,7 @@ static void addrconf_forward_change(void
 			if (changed)
 				dev_forward_change(idev);
 		}
-		read_unlock(&addrconf_lock);
+		rcu_read_unlock();
 	}
 	read_unlock(&dev_base_lock);
 }
@@ -520,7 +516,7 @@ ipv6_add_addr(struct inet6_dev *idev, co
 	int hash;
 	int err = 0;
 
-	read_lock_bh(&addrconf_lock);
+	rcu_read_lock_bh();
 	if (idev->dead) {
 		err = -ENODEV;			/*XXX*/
 		goto out2;
@@ -590,7 +586,7 @@ ipv6_add_addr(struct inet6_dev *idev, co
 	in6_ifa_hold(ifa);
 	write_unlock(&idev->lock);
 out2:
-	read_unlock_bh(&addrconf_lock);
+	rcu_read_unlock_bh();
 
 	if (likely(err == 0))
 		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_UP, ifa);
@@ -887,7 +883,7 @@ int ipv6_dev_get_saddr(struct net_device
 	memset(&hiscore, 0, sizeof(hiscore));
 
 	read_lock(&dev_base_lock);
-	read_lock(&addrconf_lock);
+	rcu_read_lock();
 
 	for (dev = dev_base; dev; dev=dev->next) {
 		struct inet6_dev *idev;
@@ -1096,7 +1092,7 @@ record_it:
 		}
 		read_unlock_bh(&idev->lock);
 	}
-	read_unlock(&addrconf_lock);
+	rcu_read_unlock();
 	read_unlock(&dev_base_lock);
 
 	if (!ifa_result)
@@ -1120,7 +1116,7 @@ int ipv6_get_lladdr(struct net_device *d
 	struct inet6_dev *idev;
 	int err = -EADDRNOTAVAIL;
 
-	read_lock(&addrconf_lock);
+	rcu_read_lock();
 	if ((idev = __in6_dev_get(dev)) != NULL) {
 		struct inet6_ifaddr *ifp;
 
@@ -1134,7 +1130,7 @@ int ipv6_get_lladdr(struct net_device *d
 		}
 		read_unlock_bh(&idev->lock);
 	}
-	read_unlock(&addrconf_lock);
+	rcu_read_unlock();
 	return err;
 }
 
@@ -1435,7 +1431,7 @@ static void ipv6_regen_rndid(unsigned lo
 	struct inet6_dev *idev = (struct inet6_dev *) data;
 	unsigned long expires;
 
-	read_lock_bh(&addrconf_lock);
+	rcu_read_lock_bh();
 	write_lock_bh(&idev->lock);
 
 	if (idev->dead)
@@ -1459,7 +1455,7 @@ static void ipv6_regen_rndid(unsigned lo
 
 out:
 	write_unlock_bh(&idev->lock);
-	read_unlock_bh(&addrconf_lock);
+	rcu_read_unlock_bh();
 	in6_dev_put(idev);
 }
 
@@ -2291,10 +2287,9 @@ static int addrconf_ifdown(struct net_de
 	           Do not dev_put!
 	 */
 	if (how == 1) {
-		write_lock_bh(&addrconf_lock);
-		dev->ip6_ptr = NULL;
-		idev->dead = 1;
-		write_unlock_bh(&addrconf_lock);
+		set_wmb(idev->dead, 1);
+		/* protected by rtnl_lock */
+		rcu_assign_pointer(dev->ip6_ptr, NULL);
 
 		/* Step 1.5: remove snmp6 entry */
 		snmp6_unregister_dev(idev);
@@ -3348,10 +3343,10 @@ static void __ipv6_ifa_notify(int event,
 
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 {
-	read_lock_bh(&addrconf_lock);
+	rcu_read_lock_bh();
 	if (likely(ifp->idev->dead == 0))
 		__ipv6_ifa_notify(event, ifp);
-	read_unlock_bh(&addrconf_lock);
+	rcu_read_unlock_bh();
 }
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 39ec528..8d71496 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -57,7 +57,7 @@ ip6_onlink(struct in6_addr *addr, struct
 	int	onlink;
 
 	onlink = 0;
-	read_lock(&addrconf_lock);
+	rcu_read_lock();
 	idev = __in6_dev_get(dev);
 	if (idev) {
 		read_lock_bh(&idev->lock);
@@ -69,7 +69,7 @@ ip6_onlink(struct in6_addr *addr, struct
 		}
 		read_unlock_bh(&idev->lock);
 	}
-	read_unlock(&addrconf_lock);
+	rcu_read_unlock();
 	return onlink;
 }
 
diff --git a/net/ipv6/ipv6_syms.c b/net/ipv6/ipv6_syms.c
index 1648278..628f1b6 100644
--- a/net/ipv6/ipv6_syms.c
+++ b/net/ipv6/ipv6_syms.c
@@ -15,7 +15,6 @@ EXPORT_SYMBOL(ndisc_mc_map);
 EXPORT_SYMBOL(register_inet6addr_notifier);
 EXPORT_SYMBOL(unregister_inet6addr_notifier);
 EXPORT_SYMBOL(ip6_route_output);
-EXPORT_SYMBOL(addrconf_lock);
 EXPORT_SYMBOL(ipv6_setsockopt);
 EXPORT_SYMBOL(ipv6_getsockopt);
 EXPORT_SYMBOL(inet6_register_protosw);
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index c20d282..5bdc117 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -321,9 +321,9 @@ static void sctp_v6_copy_addrlist(struct
 	struct inet6_ifaddr *ifp;
 	struct sctp_sockaddr_entry *addr;
 
-	read_lock(&addrconf_lock);
+	rcu_read_lock();
 	if ((in6_dev = __in6_dev_get(dev)) == NULL) {
-		read_unlock(&addrconf_lock);
+		rcu_read_unlock();
 		return;
 	}
 
@@ -342,7 +342,7 @@ static void sctp_v6_copy_addrlist(struct
 	}
 
 	read_unlock(&in6_dev->lock);
-	read_unlock(&addrconf_lock);
+	rcu_read_unlock();
 }
 
 /* Initialize a sockaddr_storage from in incoming skb. */

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
