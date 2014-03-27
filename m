From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v3 net] ipv6: move DAD and addrconf_verify processing to workqueue
Date: Thu, 27 Mar 2014 18:28:07 +0100
Message-ID: <20140327172807.GB11063@order.stressinduktion.org>
References: <20140325142004.7507d310@samsung-9> <20140326000052.GD22086@order.stressinduktion.org> <20140326061745.GE22086@order.stressinduktion.org> <20140327.131549.909533657131515923.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35608 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185AbaC0R2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 13:28:09 -0400
Content-Disposition: inline
In-Reply-To: <20140327.131549.909533657131515923.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addrconf_join_solict and addrconf_join_anycast may cause actions which
need rtnl locked, especially on first address creation.

A new DAD state is introduced which deferres processing of the initial
DAD processing into a workqueue.

To get rtnl lock we need to push the code paths which depend on those
calls up to workqueues, specifically addrconf_verify and the DAD
processing.

(v2)
addrconf_dad_failure needs to be queued up to the workqueue, too. This
patch introduces a new DAD state and stop the DAD processing in the
workqueue (this is because of the possible ipv6_del_addr processing
which removes the solicited multicast address from the device).

addrconf_verify_lock is removed, too. After the transition it is not
needed any more.

As we are not processing in bottom half anymore we need to be a bit more
careful about disabling bottom half out when we lock spin_locks which are also
used in bh.

Relevant backtrace:
[  541.030090] RTNL: assertion failed at net/core/dev.c (4496)
[  541.031143] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O 3.10.33-1-amd64-vyatta #1
[  541.031145] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  541.031146]  ffffffff8148a9f0 000000000000002f ffffffff813c98c1 ffff88007c4451f8
[  541.031148]  0000000000000000 0000000000000000 ffffffff813d3540 ffff88007fc03d18
[  541.031150]  0000880000000006 ffff88007c445000 ffffffffa0194160 0000000000000000
[  541.031152] Call Trace:
[  541.031153]  <IRQ>  [<ffffffff8148a9f0>] ? dump_stack+0xd/0x17
[  541.031180]  [<ffffffff813c98c1>] ? __dev_set_promiscuity+0x101/0x180
[  541.031183]  [<ffffffff813d3540>] ? __hw_addr_create_ex+0x60/0xc0
[  541.031185]  [<ffffffff813cfe1a>] ? __dev_set_rx_mode+0xaa/0xc0
[  541.031189]  [<ffffffff813d3a81>] ? __dev_mc_add+0x61/0x90
[  541.031198]  [<ffffffffa01dcf9c>] ? igmp6_group_added+0xfc/0x1a0 [ipv6]
[  541.031208]  [<ffffffff8111237b>] ? kmem_cache_alloc+0xcb/0xd0
[  541.031212]  [<ffffffffa01ddcd7>] ? ipv6_dev_mc_inc+0x267/0x300 [ipv6]
[  541.031216]  [<ffffffffa01c2fae>] ? addrconf_join_solict+0x2e/0x40 [ipv6]
[  541.031219]  [<ffffffffa01ba2e9>] ? ipv6_dev_ac_inc+0x159/0x1f0 [ipv6]
[  541.031223]  [<ffffffffa01c0772>] ? addrconf_join_anycast+0x92/0xa0 [ipv6]
[  541.031226]  [<ffffffffa01c311e>] ? __ipv6_ifa_notify+0x11e/0x1e0 [ipv6]
[  541.031229]  [<ffffffffa01c3213>] ? ipv6_ifa_notify+0x33/0x50 [ipv6]
[  541.031233]  [<ffffffffa01c36c8>] ? addrconf_dad_completed+0x28/0x100 [ipv6]
[  541.031241]  [<ffffffff81075c1d>] ? task_cputime+0x2d/0x50
[  541.031244]  [<ffffffffa01c38d6>] ? addrconf_dad_timer+0x136/0x150 [ipv6]
[  541.031247]  [<ffffffffa01c37a0>] ? addrconf_dad_completed+0x100/0x100 [ipv6]
[  541.031255]  [<ffffffff8105313a>] ? call_timer_fn.isra.22+0x2a/0x90
[  541.031258]  [<ffffffffa01c37a0>] ? addrconf_dad_completed+0x100/0x100 [ipv6]

Hunks and backtrace stolen from a patch by Stephen Hemminger.

Reported-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v3 (only minor change):
* reword pr_notice in inet6_ifa_finish_destroy (thanks, David!)

 include/net/if_inet6.h |   4 +-
 net/ipv6/addrconf.c    | 193 ++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 145 insertions(+), 52 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 9650a3f..b4956a5 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -31,8 +31,10 @@
 #define IF_PREFIX_AUTOCONF	0x02
 
 enum {
+	INET6_IFADDR_STATE_PREDAD,
 	INET6_IFADDR_STATE_DAD,
 	INET6_IFADDR_STATE_POSTDAD,
+	INET6_IFADDR_STATE_ERRDAD,
 	INET6_IFADDR_STATE_UP,
 	INET6_IFADDR_STATE_DEAD,
 };
@@ -58,7 +60,7 @@ struct inet6_ifaddr {
 	unsigned long		cstamp;	/* created timestamp */
 	unsigned long		tstamp; /* updated timestamp */
 
-	struct timer_list	dad_timer;
+	struct delayed_work	dad_work;
 
 	struct inet6_dev	*idev;
 	struct rt6_info		*rt;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 344e972..6c7fa08 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -133,10 +133,12 @@ static int ipv6_count_addresses(struct inet6_dev *idev);
 static struct hlist_head inet6_addr_lst[IN6_ADDR_HSIZE];
 static DEFINE_SPINLOCK(addrconf_hash_lock);
 
-static void addrconf_verify(unsigned long);
+static void addrconf_verify(void);
+static void addrconf_verify_rtnl(void);
+static void addrconf_verify_work(struct work_struct *);
 
-static DEFINE_TIMER(addr_chk_timer, addrconf_verify, 0, 0);
-static DEFINE_SPINLOCK(addrconf_verify_lock);
+static struct workqueue_struct *addrconf_wq;
+static DECLARE_DELAYED_WORK(addr_chk_work, addrconf_verify_work);
 
 static void addrconf_join_anycast(struct inet6_ifaddr *ifp);
 static void addrconf_leave_anycast(struct inet6_ifaddr *ifp);
@@ -151,7 +153,7 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 						  u32 flags, u32 noflags);
 
 static void addrconf_dad_start(struct inet6_ifaddr *ifp);
-static void addrconf_dad_timer(unsigned long data);
+static void addrconf_dad_work(struct work_struct *w);
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
 static void addrconf_dad_run(struct inet6_dev *idev);
 static void addrconf_rs_timer(unsigned long data);
@@ -247,9 +249,9 @@ static void addrconf_del_rs_timer(struct inet6_dev *idev)
 		__in6_dev_put(idev);
 }
 
-static void addrconf_del_dad_timer(struct inet6_ifaddr *ifp)
+static void addrconf_del_dad_work(struct inet6_ifaddr *ifp)
 {
-	if (del_timer(&ifp->dad_timer))
+	if (cancel_delayed_work(&ifp->dad_work))
 		__in6_ifa_put(ifp);
 }
 
@@ -261,12 +263,12 @@ static void addrconf_mod_rs_timer(struct inet6_dev *idev,
 	mod_timer(&idev->rs_timer, jiffies + when);
 }
 
-static void addrconf_mod_dad_timer(struct inet6_ifaddr *ifp,
-				   unsigned long when)
+static void addrconf_mod_dad_work(struct inet6_ifaddr *ifp,
+				   unsigned long delay)
 {
-	if (!timer_pending(&ifp->dad_timer))
+	if (!delayed_work_pending(&ifp->dad_work))
 		in6_ifa_hold(ifp);
-	mod_timer(&ifp->dad_timer, jiffies + when);
+	mod_delayed_work(addrconf_wq, &ifp->dad_work, delay);
 }
 
 static int snmp6_alloc_dev(struct inet6_dev *idev)
@@ -751,8 +753,9 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 
 	in6_dev_put(ifp->idev);
 
-	if (del_timer(&ifp->dad_timer))
-		pr_notice("Timer is still running, when freeing ifa=%p\n", ifp);
+	if (cancel_delayed_work(&ifp->dad_work))
+		pr_notice("delayed DAD work was pending while freeing ifa=%p\n",
+			  ifp);
 
 	if (ifp->state != INET6_IFADDR_STATE_DEAD) {
 		pr_warn("Freeing alive inet6 address %p\n", ifp);
@@ -849,8 +852,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 
 	spin_lock_init(&ifa->lock);
 	spin_lock_init(&ifa->state_lock);
-	setup_timer(&ifa->dad_timer, addrconf_dad_timer,
-		    (unsigned long)ifa);
+	INIT_DELAYED_WORK(&ifa->dad_work, addrconf_dad_work);
 	INIT_HLIST_NODE(&ifa->addr_lst);
 	ifa->scope = scope;
 	ifa->prefix_len = pfxlen;
@@ -990,6 +992,8 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	enum cleanup_prefix_rt_t action = CLEANUP_PREFIX_RT_NOP;
 	unsigned long expires;
 
+	ASSERT_RTNL();
+
 	spin_lock_bh(&ifp->state_lock);
 	state = ifp->state;
 	ifp->state = INET6_IFADDR_STATE_DEAD;
@@ -1021,7 +1025,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 
 	write_unlock_bh(&ifp->idev->lock);
 
-	addrconf_del_dad_timer(ifp);
+	addrconf_del_dad_work(ifp);
 
 	ipv6_ifa_notify(RTM_DELADDR, ifp);
 
@@ -1604,7 +1608,7 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 {
 	if (ifp->flags&IFA_F_PERMANENT) {
 		spin_lock_bh(&ifp->lock);
-		addrconf_del_dad_timer(ifp);
+		addrconf_del_dad_work(ifp);
 		ifp->flags |= IFA_F_TENTATIVE;
 		if (dad_failed)
 			ifp->flags |= IFA_F_DADFAILED;
@@ -1625,20 +1629,21 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 			spin_unlock_bh(&ifp->lock);
 		}
 		ipv6_del_addr(ifp);
-	} else
+	} else {
 		ipv6_del_addr(ifp);
+	}
 }
 
 static int addrconf_dad_end(struct inet6_ifaddr *ifp)
 {
 	int err = -ENOENT;
 
-	spin_lock(&ifp->state_lock);
+	spin_lock_bh(&ifp->state_lock);
 	if (ifp->state == INET6_IFADDR_STATE_DAD) {
 		ifp->state = INET6_IFADDR_STATE_POSTDAD;
 		err = 0;
 	}
-	spin_unlock(&ifp->state_lock);
+	spin_unlock_bh(&ifp->state_lock);
 
 	return err;
 }
@@ -1671,7 +1676,12 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 		}
 	}
 
-	addrconf_dad_stop(ifp, 1);
+	spin_lock_bh(&ifp->state_lock);
+	/* transition from _POSTDAD to _ERRDAD */
+	ifp->state = INET6_IFADDR_STATE_ERRDAD;
+	spin_unlock_bh(&ifp->state_lock);
+
+	addrconf_mod_dad_work(ifp, 0);
 }
 
 /* Join to solicited addr multicast group. */
@@ -1680,6 +1690,8 @@ void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr)
 {
 	struct in6_addr maddr;
 
+	ASSERT_RTNL();
+
 	if (dev->flags&(IFF_LOOPBACK|IFF_NOARP))
 		return;
 
@@ -1691,6 +1703,8 @@ void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr)
 {
 	struct in6_addr maddr;
 
+	ASSERT_RTNL();
+
 	if (idev->dev->flags&(IFF_LOOPBACK|IFF_NOARP))
 		return;
 
@@ -1701,6 +1715,9 @@ void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr)
 static void addrconf_join_anycast(struct inet6_ifaddr *ifp)
 {
 	struct in6_addr addr;
+
+	ASSERT_RTNL();
+
 	if (ifp->prefix_len >= 127) /* RFC 6164 */
 		return;
 	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
@@ -1712,6 +1729,9 @@ static void addrconf_join_anycast(struct inet6_ifaddr *ifp)
 static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
 {
 	struct in6_addr addr;
+
+	ASSERT_RTNL();
+
 	if (ifp->prefix_len >= 127) /* RFC 6164 */
 		return;
 	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
@@ -2271,11 +2291,13 @@ ok:
 				return;
 			}
 
-			ifp->flags |= IFA_F_MANAGETEMPADDR;
 			update_lft = 0;
 			create = 1;
+			spin_lock_bh(&ifp->lock);
+			ifp->flags |= IFA_F_MANAGETEMPADDR;
 			ifp->cstamp = jiffies;
 			ifp->tokenized = tokenized;
+			spin_unlock_bh(&ifp->lock);
 			addrconf_dad_start(ifp);
 		}
 
@@ -2326,7 +2348,7 @@ ok:
 					 create, now);
 
 			in6_ifa_put(ifp);
-			addrconf_verify(0);
+			addrconf_verify();
 		}
 	}
 	inet6_prefix_notify(RTM_NEWPREFIX, in6_dev, pinfo);
@@ -2475,7 +2497,7 @@ static int inet6_addr_add(struct net *net, int ifindex,
 			manage_tempaddrs(idev, ifp, valid_lft, prefered_lft,
 					 true, jiffies);
 		in6_ifa_put(ifp);
-		addrconf_verify(0);
+		addrconf_verify_rtnl();
 		return 0;
 	}
 
@@ -3011,7 +3033,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		hlist_for_each_entry_rcu(ifa, h, addr_lst) {
 			if (ifa->idev == idev) {
 				hlist_del_init_rcu(&ifa->addr_lst);
-				addrconf_del_dad_timer(ifa);
+				addrconf_del_dad_work(ifa);
 				goto restart;
 			}
 		}
@@ -3049,7 +3071,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	while (!list_empty(&idev->addr_list)) {
 		ifa = list_first_entry(&idev->addr_list,
 				       struct inet6_ifaddr, if_list);
-		addrconf_del_dad_timer(ifa);
+		addrconf_del_dad_work(ifa);
 
 		list_del(&ifa->if_list);
 
@@ -3148,10 +3170,10 @@ static void addrconf_dad_kick(struct inet6_ifaddr *ifp)
 		rand_num = prandom_u32() % (idev->cnf.rtr_solicit_delay ? : 1);
 
 	ifp->dad_probes = idev->cnf.dad_transmits;
-	addrconf_mod_dad_timer(ifp, rand_num);
+	addrconf_mod_dad_work(ifp, rand_num);
 }
 
-static void addrconf_dad_start(struct inet6_ifaddr *ifp)
+static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 {
 	struct inet6_dev *idev = ifp->idev;
 	struct net_device *dev = idev->dev;
@@ -3203,25 +3225,68 @@ out:
 	read_unlock_bh(&idev->lock);
 }
 
-static void addrconf_dad_timer(unsigned long data)
+static void addrconf_dad_start(struct inet6_ifaddr *ifp)
 {
-	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *) data;
+	bool begin_dad = false;
+
+	spin_lock_bh(&ifp->state_lock);
+	if (ifp->state != INET6_IFADDR_STATE_DEAD) {
+		ifp->state = INET6_IFADDR_STATE_PREDAD;
+		begin_dad = true;
+	}
+	spin_unlock_bh(&ifp->state_lock);
+
+	if (begin_dad)
+		addrconf_mod_dad_work(ifp, 0);
+}
+
+static void addrconf_dad_work(struct work_struct *w)
+{
+	struct inet6_ifaddr *ifp = container_of(to_delayed_work(w),
+						struct inet6_ifaddr,
+						dad_work);
 	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr mcaddr;
 
+	enum {
+		DAD_PROCESS,
+		DAD_BEGIN,
+		DAD_ABORT,
+	} action = DAD_PROCESS;
+
+	rtnl_lock();
+
+	spin_lock_bh(&ifp->state_lock);
+	if (ifp->state == INET6_IFADDR_STATE_PREDAD) {
+		action = DAD_BEGIN;
+		ifp->state = INET6_IFADDR_STATE_DAD;
+	} else if (ifp->state == INET6_IFADDR_STATE_ERRDAD) {
+		action = DAD_ABORT;
+		ifp->state = INET6_IFADDR_STATE_POSTDAD;
+	}
+	spin_unlock_bh(&ifp->state_lock);
+
+	if (action == DAD_BEGIN) {
+		addrconf_dad_begin(ifp);
+		goto out;
+	} else if (action == DAD_ABORT) {
+		addrconf_dad_stop(ifp, 1);
+		goto out;
+	}
+
 	if (!ifp->dad_probes && addrconf_dad_end(ifp))
 		goto out;
 
-	write_lock(&idev->lock);
+	write_lock_bh(&idev->lock);
 	if (idev->dead || !(idev->if_flags & IF_READY)) {
-		write_unlock(&idev->lock);
+		write_unlock_bh(&idev->lock);
 		goto out;
 	}
 
 	spin_lock(&ifp->lock);
 	if (ifp->state == INET6_IFADDR_STATE_DEAD) {
 		spin_unlock(&ifp->lock);
-		write_unlock(&idev->lock);
+		write_unlock_bh(&idev->lock);
 		goto out;
 	}
 
@@ -3232,7 +3297,7 @@ static void addrconf_dad_timer(unsigned long data)
 
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC|IFA_F_DADFAILED);
 		spin_unlock(&ifp->lock);
-		write_unlock(&idev->lock);
+		write_unlock_bh(&idev->lock);
 
 		addrconf_dad_completed(ifp);
 
@@ -3240,16 +3305,17 @@ static void addrconf_dad_timer(unsigned long data)
 	}
 
 	ifp->dad_probes--;
-	addrconf_mod_dad_timer(ifp,
-			       NEIGH_VAR(ifp->idev->nd_parms, RETRANS_TIME));
+	addrconf_mod_dad_work(ifp,
+			      NEIGH_VAR(ifp->idev->nd_parms, RETRANS_TIME));
 	spin_unlock(&ifp->lock);
-	write_unlock(&idev->lock);
+	write_unlock_bh(&idev->lock);
 
 	/* send a neighbour solicitation for our addr */
 	addrconf_addr_solict_mult(&ifp->addr, &mcaddr);
 	ndisc_send_ns(ifp->idev->dev, NULL, &ifp->addr, &mcaddr, &in6addr_any);
 out:
 	in6_ifa_put(ifp);
+	rtnl_unlock();
 }
 
 /* ifp->idev must be at least read locked */
@@ -3276,7 +3342,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 	struct in6_addr lladdr;
 	bool send_rs, send_mld;
 
-	addrconf_del_dad_timer(ifp);
+	addrconf_del_dad_work(ifp);
 
 	/*
 	 *	Configure the address for reception. Now it is valid.
@@ -3517,23 +3583,23 @@ int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr)
  *	Periodic address status verification
  */
 
-static void addrconf_verify(unsigned long foo)
+static void addrconf_verify_rtnl(void)
 {
 	unsigned long now, next, next_sec, next_sched;
 	struct inet6_ifaddr *ifp;
 	int i;
 
+	ASSERT_RTNL();
+
 	rcu_read_lock_bh();
-	spin_lock(&addrconf_verify_lock);
 	now = jiffies;
 	next = round_jiffies_up(now + ADDR_CHECK_FREQUENCY);
 
-	del_timer(&addr_chk_timer);
+	cancel_delayed_work(&addr_chk_work);
 
 	for (i = 0; i < IN6_ADDR_HSIZE; i++) {
 restart:
-		hlist_for_each_entry_rcu_bh(ifp,
-					 &inet6_addr_lst[i], addr_lst) {
+		hlist_for_each_entry_rcu_bh(ifp, &inet6_addr_lst[i], addr_lst) {
 			unsigned long age;
 
 			/* When setting preferred_lft to a value not zero or
@@ -3628,13 +3694,22 @@ restart:
 
 	ADBG(KERN_DEBUG "now = %lu, schedule = %lu, rounded schedule = %lu => %lu\n",
 	      now, next, next_sec, next_sched);
-
-	addr_chk_timer.expires = next_sched;
-	add_timer(&addr_chk_timer);
-	spin_unlock(&addrconf_verify_lock);
+	mod_delayed_work(addrconf_wq, &addr_chk_work, next_sched - now);
 	rcu_read_unlock_bh();
 }
 
+static void addrconf_verify_work(struct work_struct *w)
+{
+	rtnl_lock();
+	addrconf_verify_rtnl();
+	rtnl_unlock();
+}
+
+static void addrconf_verify(void)
+{
+	mod_delayed_work(addrconf_wq, &addr_chk_work, 0);
+}
+
 static struct in6_addr *extract_addr(struct nlattr *addr, struct nlattr *local,
 				     struct in6_addr **peer_pfx)
 {
@@ -3691,6 +3766,8 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 	bool was_managetempaddr;
 	bool had_prefixroute;
 
+	ASSERT_RTNL();
+
 	if (!valid_lft || (prefered_lft > valid_lft))
 		return -EINVAL;
 
@@ -3756,7 +3833,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 				 !was_managetempaddr, jiffies);
 	}
 
-	addrconf_verify(0);
+	addrconf_verify_rtnl();
 
 	return 0;
 }
@@ -4386,6 +4463,8 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 	bool update_rs = false;
 	struct in6_addr ll_addr;
 
+	ASSERT_RTNL();
+
 	if (token == NULL)
 		return -EINVAL;
 	if (ipv6_addr_any(token))
@@ -4434,7 +4513,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 	}
 
 	write_unlock_bh(&idev->lock);
-	addrconf_verify(0);
+	addrconf_verify_rtnl();
 	return 0;
 }
 
@@ -4636,6 +4715,9 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 {
 	struct net *net = dev_net(ifp->idev->dev);
 
+	if (event)
+		ASSERT_RTNL();
+
 	inet6_ifa_notify(event ? : RTM_NEWADDR, ifp);
 
 	switch (event) {
@@ -5244,6 +5326,12 @@ int __init addrconf_init(void)
 	if (err < 0)
 		goto out_addrlabel;
 
+	addrconf_wq = create_workqueue("ipv6_addrconf");
+	if (!addrconf_wq) {
+		err = -ENOMEM;
+		goto out_nowq;
+	}
+
 	/* The addrconf netdev notifier requires that loopback_dev
 	 * has it's ipv6 private information allocated and setup
 	 * before it can bring up and give link-local addresses
@@ -5274,7 +5362,7 @@ int __init addrconf_init(void)
 
 	register_netdevice_notifier(&ipv6_dev_notf);
 
-	addrconf_verify(0);
+	addrconf_verify();
 
 	rtnl_af_register(&inet6_ops);
 
@@ -5302,6 +5390,8 @@ errout:
 	rtnl_af_unregister(&inet6_ops);
 	unregister_netdevice_notifier(&ipv6_dev_notf);
 errlo:
+	destroy_workqueue(addrconf_wq);
+out_nowq:
 	unregister_pernet_subsys(&addrconf_ops);
 out_addrlabel:
 	ipv6_addr_label_cleanup();
@@ -5337,7 +5427,8 @@ void addrconf_cleanup(void)
 	for (i = 0; i < IN6_ADDR_HSIZE; i++)
 		WARN_ON(!hlist_empty(&inet6_addr_lst[i]));
 	spin_unlock_bh(&addrconf_hash_lock);
-
-	del_timer(&addr_chk_timer);
+	cancel_delayed_work(&addr_chk_work);
 	rtnl_unlock();
+
+	destroy_workqueue(addrconf_wq);
 }
-- 
1.8.5.3
