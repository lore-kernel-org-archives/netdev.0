From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [BK PATCH] [IPV6] Multiple locking fixes/improvements
Date: Mon, 22 Nov 2004 22:32:05 -0500 (EST)
Message-ID: <20041122.223205.14979415.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Please pull the following changesets available at:
    <bk://bk.skbuff.net:20610/linux-2.6-inet6/>

HEADLINES
---------
ChangeSet@1.2231, 2004-11-23 11:50:54+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix possible dead-lock in ipv6_create_tempaddr().
ChangeSet@1.2232, 2004-11-23 11:52:57+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix a race when dad completed during shutting down its owner interface.
ChangeSet@1.2233, 2004-11-23 11:54:38+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Stop DAD during shutting down the interface.
ChangeSet@1.2234, 2004-11-23 12:16:24+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Clean-up locking in ipv6_add_addr().


DIFFSTATS
---------
 net/ipv6/addrconf.c |  115 ++++++++++++++++++++++++++++++----------------------
 1 files changed, 67 insertions(+), 48 deletions(-)


CHANGESETS
----------
ChangeSet@1.2231, 2004-11-23 11:50:54+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix possible dead-lock in ipv6_create_tempaddr().
 
 If we need to obtain lock both ifp and ifp->idev, we need to do
 lock idev first to avoid dead-lock.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-11-23 12:23:23 +09:00
+++ b/net/ipv6/addrconf.c	2004-11-23 12:23:23 +09:00
@@ -645,13 +645,14 @@
 #ifdef CONFIG_IPV6_PRIVACY
 static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *ift)
 {
-	struct inet6_dev *idev;
+	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr addr, *tmpaddr;
-	unsigned long tmp_prefered_lft, tmp_valid_lft;
+	unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp;
 	int tmp_plen;
 	int ret = 0;
 	int max_addresses;
 
+	write_lock(&idev->lock);
 	if (ift) {
 		spin_lock_bh(&ift->lock);
 		memcpy(&addr.s6_addr[8], &ift->addr.s6_addr[8], 8);
@@ -661,40 +662,35 @@
 		tmpaddr = NULL;
 	}
 retry:
-	spin_lock_bh(&ifp->lock);
-	in6_ifa_hold(ifp);
-	idev = ifp->idev;
 	in6_dev_hold(idev);
-	memcpy(addr.s6_addr, ifp->addr.s6_addr, 8);
-	write_lock(&idev->lock);
 	if (idev->cnf.use_tempaddr <= 0) {
 		write_unlock(&idev->lock);
-		spin_unlock_bh(&ifp->lock);
 		printk(KERN_INFO
 			"ipv6_create_tempaddr(): use_tempaddr is disabled.\n");
 		in6_dev_put(idev);
-		in6_ifa_put(ifp);
 		ret = -1;
 		goto out;
 	}
+	spin_lock_bh(&ifp->lock);
 	if (ifp->regen_count++ >= idev->cnf.regen_max_retry) {
 		idev->cnf.use_tempaddr = -1;	/*XXX*/
-		write_unlock(&idev->lock);
 		spin_unlock_bh(&ifp->lock);
+		write_unlock(&idev->lock);
 		printk(KERN_WARNING
 			"ipv6_create_tempaddr(): regeneration time exceeded. disabled temporary address support.\n");
 		in6_dev_put(idev);
-		in6_ifa_put(ifp);
 		ret = -1;
 		goto out;
 	}
+	in6_ifa_hold(ifp);
+	memcpy(addr.s6_addr, ifp->addr.s6_addr, 8);
 	if (__ipv6_try_regen_rndid(idev, tmpaddr) < 0) {
-		write_unlock(&idev->lock);
 		spin_unlock_bh(&ifp->lock);
+		write_unlock(&idev->lock);
 		printk(KERN_WARNING
 			"ipv6_create_tempaddr(): regeneration of randomized interface id failed.\n");
-		in6_dev_put(idev);
 		in6_ifa_put(ifp);
+		in6_dev_put(idev);
 		ret = -1;
 		goto out;
 	}
@@ -707,27 +703,33 @@
 				 idev->cnf.temp_prefered_lft - desync_factor / HZ);
 	tmp_plen = ifp->prefix_len;
 	max_addresses = idev->cnf.max_addresses;
-	write_unlock(&idev->lock);
+	tmp_cstamp = ifp->cstamp;
+	tmp_tstamp = ifp->tstamp;
 	spin_unlock_bh(&ifp->lock);
+
+	write_unlock(&idev->lock);
 	ift = !max_addresses ||
 	      ipv6_count_addresses(idev) < max_addresses ? 
 		ipv6_add_addr(idev, &addr, tmp_plen,
 			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORARY) : NULL;
 	if (!ift || IS_ERR(ift)) {
-		in6_dev_put(idev);
 		in6_ifa_put(ifp);
+		in6_dev_put(idev);
 		printk(KERN_INFO
 			"ipv6_create_tempaddr(): retry temporary address regeneration.\n");
 		tmpaddr = &addr;
+		write_lock(&idev->lock);
 		goto retry;
 	}
+
 	spin_lock_bh(&ift->lock);
 	ift->ifpub = ifp;
 	ift->valid_lft = tmp_valid_lft;
 	ift->prefered_lft = tmp_prefered_lft;
-	ift->cstamp = ifp->cstamp;
-	ift->tstamp = ifp->tstamp;
+	ift->cstamp = tmp_cstamp;
+	ift->tstamp = tmp_tstamp;
 	spin_unlock_bh(&ift->lock);
+
 	addrconf_dad_start(ift, 0);
 	in6_ifa_put(ift);
 	in6_dev_put(idev);
@@ -938,14 +940,12 @@
 	struct inet6_ifaddr * ifp;
 	u8 hash = ipv6_addr_hash(addr);
 
-	read_lock_bh(&addrconf_hash_lock);
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
 			if (dev == NULL || ifp->idev->dev == dev)
 				break;
 		}
 	}
-	read_unlock_bh(&addrconf_hash_lock);
 	return ifp != NULL;
 }
 

ChangeSet@1.2232, 2004-11-23 11:52:57+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix a race when dad completed during shutting down its owner interface.
 
 Bug was noticed by Herbert Xu <herbert@gondor.apana.org.au>.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-11-23 12:23:28 +09:00
+++ b/net/ipv6/addrconf.c	2004-11-23 12:23:28 +09:00
@@ -137,6 +137,7 @@
 static void addrconf_dad_timer(unsigned long data);
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
 static void addrconf_rs_timer(unsigned long data);
+static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifa);
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifa);
 
 static void inet6_prefix_notify(int event, struct inet6_dev *idev, 
@@ -2049,7 +2050,7 @@
 		addrconf_del_timer(ifa);
 		write_unlock_bh(&idev->lock);
 
-		ipv6_ifa_notify(RTM_DELADDR, ifa);
+		__ipv6_ifa_notify(RTM_DELADDR, ifa);
 		in6_ifa_put(ifa);
 
 		write_lock_bh(&idev->lock);
@@ -2980,7 +2981,7 @@
 				      .dumpit	= inet6_dump_fib, },
 };
 
-static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
+static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 {
 	inet6_ifa_notify(event ? : RTM_NEWADDR, ifp);
 
@@ -3003,6 +3004,16 @@
 			dst_release(&ifp->rt->u.dst);
 		break;
 	}
+}
+
+static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
+{
+	read_lock_bh(&addrconf_lock);
+	if (ifp->idev->dead)
+		goto out;
+	__ipv6_ifa_notify(event, ifp);
+out:
+	read_unlock_bh(&addrconf_lock);
 }
 
 #ifdef CONFIG_SYSCTL

ChangeSet@1.2233, 2004-11-23 11:54:38+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Stop DAD during shutting down the interface.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-11-23 12:23:32 +09:00
+++ b/net/ipv6/addrconf.c	2004-11-23 12:23:32 +09:00
@@ -2130,11 +2130,10 @@
  */
 static void addrconf_dad_start(struct inet6_ifaddr *ifp, int flags)
 {
-	struct net_device *dev;
+	struct inet6_dev *idev = ifp->idev;
+	struct net_device *dev = idev->dev;
 	unsigned long rand_num;
 
-	dev = ifp->idev->dev;
-
 	addrconf_join_solict(dev, &ifp->addr);
 
 	if (ifp->prefix_len != 128 && (ifp->flags&IFA_F_PERMANENT))
@@ -2142,31 +2141,43 @@
 					flags);
 
 	net_srandom(ifp->addr.s6_addr32[3]);
-	rand_num = net_random() % (ifp->idev->cnf.rtr_solicit_delay ? : 1);
+	rand_num = net_random() % (idev->cnf.rtr_solicit_delay ? : 1);
 
+	read_lock_bh(&idev->lock);
+	if (ifp->dead)
+		goto out;
 	spin_lock_bh(&ifp->lock);
 
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
 	    !(ifp->flags&IFA_F_TENTATIVE)) {
 		ifp->flags &= ~IFA_F_TENTATIVE;
 		spin_unlock_bh(&ifp->lock);
+		read_unlock_bh(&idev->lock);
 
 		addrconf_dad_completed(ifp);
 		return;
 	}
 
-	ifp->probes = ifp->idev->cnf.dad_transmits;
+	ifp->probes = idev->cnf.dad_transmits;
 	addrconf_mod_timer(ifp, AC_DAD, rand_num);
 
 	spin_unlock_bh(&ifp->lock);
+out:
+	read_unlock_bh(&idev->lock);
 }
 
 static void addrconf_dad_timer(unsigned long data)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *) data;
+	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr unspec;
 	struct in6_addr mcaddr;
 
+	read_lock_bh(&idev->lock);
+	if (idev->dead) {
+		read_unlock_bh(&idev->lock);
+		goto out;
+	}
 	spin_lock_bh(&ifp->lock);
 	if (ifp->probes == 0) {
 		/*
@@ -2175,22 +2186,23 @@
 
 		ifp->flags &= ~IFA_F_TENTATIVE;
 		spin_unlock_bh(&ifp->lock);
+		read_unlock_bh(&idev->lock);
 
 		addrconf_dad_completed(ifp);
 
-		in6_ifa_put(ifp);
-		return;
+		goto out;
 	}
 
 	ifp->probes--;
 	addrconf_mod_timer(ifp, AC_DAD, ifp->idev->nd_parms->retrans_time);
 	spin_unlock_bh(&ifp->lock);
+	read_unlock_bh(&idev->lock);
 
 	/* send a neighbour solicitation for our addr */
 	memset(&unspec, 0, sizeof(unspec));
 	addrconf_addr_solict_mult(&ifp->addr, &mcaddr);
 	ndisc_send_ns(ifp->idev->dev, NULL, &ifp->addr, &mcaddr, &unspec);
-
+out:
 	in6_ifa_put(ifp);
 }
 

ChangeSet@1.2234, 2004-11-23 12:16:24+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Clean-up locking in ipv6_add_addr().
 
 Use addrconf_hash_lock instead of private lock.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-11-23 12:23:37 +09:00
+++ b/net/ipv6/addrconf.c	2004-11-23 12:23:37 +09:00
@@ -487,10 +487,15 @@
 	struct inet6_ifaddr *ifa = NULL;
 	struct rt6_info *rt;
 	int hash;
-	static spinlock_t lock = SPIN_LOCK_UNLOCKED;
 	int err = 0;
 
-	spin_lock_bh(&lock);
+	read_lock_bh(&addrconf_lock);
+	if (idev->dead) {
+		err = -ENODEV;			/*XXX*/
+		goto out2;
+	}
+
+	write_lock(&addrconf_hash_lock);
 
 	/* Ignore adding duplicate addresses on an interface */
 	if (ipv6_chk_same_addr(addr, idev->dev)) {
@@ -524,13 +529,6 @@
 	ifa->flags = flags | IFA_F_TENTATIVE;
 	ifa->cstamp = ifa->tstamp = jiffies;
 
-	read_lock(&addrconf_lock);
-	if (idev->dead) {
-		read_unlock(&addrconf_lock);
-		err = -ENODEV;	/*XXX*/
-		goto out;
-	}
-
 	inet6_ifa_count++;
 	ifa->idev = idev;
 	in6_dev_hold(idev);
@@ -540,35 +538,30 @@
 	/* Add to big hash table */
 	hash = ipv6_addr_hash(addr);
 
-	write_lock_bh(&addrconf_hash_lock);
 	ifa->lst_next = inet6_addr_lst[hash];
 	inet6_addr_lst[hash] = ifa;
 	in6_ifa_hold(ifa);
-	write_unlock_bh(&addrconf_hash_lock);
+	write_unlock(&addrconf_hash_lock);
 
-	write_lock_bh(&idev->lock);
+	write_lock(&idev->lock);
 	/* Add to inet6_dev unicast addr list. */
 	ifa->if_next = idev->addr_list;
 	idev->addr_list = ifa;
 
 #ifdef CONFIG_IPV6_PRIVACY
-	ifa->regen_count = 0;
 	if (ifa->flags&IFA_F_TEMPORARY) {
 		ifa->tmp_next = idev->tempaddr_list;
 		idev->tempaddr_list = ifa;
 		in6_ifa_hold(ifa);
-	} else {
-		ifa->tmp_next = NULL;
 	}
 #endif
 
 	ifa->rt = rt;
 
 	in6_ifa_hold(ifa);
-	write_unlock_bh(&idev->lock);
-	read_unlock(&addrconf_lock);
-out:
-	spin_unlock_bh(&lock);
+	write_unlock(&idev->lock);
+out2:
+	read_unlock_bh(&addrconf_lock);
 
 	if (unlikely(err == 0))
 		notifier_call_chain(&inet6addr_chain, NETDEV_UP, ifa);
@@ -578,6 +571,9 @@
 	}
 
 	return ifa;
+out:
+	write_unlock(&addrconf_hash_lock);
+	goto out;
 }
 
 /* This function wants to get referenced ifp and releases it before return */
