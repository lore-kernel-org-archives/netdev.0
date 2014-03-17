From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] ipv6: fix RTNL assert fail in DAD
Date: Mon, 17 Mar 2014 16:18:53 -0700
Message-ID: <20140317161853.2e880469@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:49102 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbaCQXjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 19:39:23 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so6403145pbc.13
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 16:39:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 duplicate address detection is triggering the following assertion
failure when using macvlan + vif + multicast.
 RTNL: assertion failed at net/core/dev.c (4496)

This happens because the DAD timer is adding a multicast address without
acquiring the RTNL mutex. In order to acquire the RTNL mutex, it must be
done in process context; therefore it must be in a workqueue.

Full backtrace:
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
[  541.031261]  [<ffffffff81053531>] ? run_timer_softirq+0x1a1/0x260
[  541.031267]  [<ffffffff810350cf>] ? kvm_clock_read+0x1f/0x30
[  541.031272]  [<ffffffff810132a5>] ? sched_clock+0x5/0x10
[  541.031274]  [<ffffffff81074bd5>] ? sched_clock_local+0x15/0x80
[  541.031276]  [<ffffffff8104d586>] ? __do_softirq+0xd6/0x1b0
[  541.031282]  [<ffffffff8149109c>] ? call_softirq+0x1c/0x30
[  541.031284]  [<ffffffff8100d835>] ? do_softirq+0x75/0xb0
[  541.031286]  [<ffffffff8104d7ed>] ? irq_exit+0xbd/0xc0
[  541.031290]  [<ffffffff8102e718>] ? smp_apic_timer_interrupt+0x68/0xa0
[  541.031292]  [<ffffffff814908dd>] ? apic_timer_interrupt+0x6d/0x80
[  541.031293]  <EOI>  [<ffffffff81013ee0>] ? hard_enable_TSC+0x20/0x20
[  541.031296]  [<ffffffff81035412>] ? native_safe_halt+0x2/0x10
[  541.031298]  [<ffffffff81014619>] ? arch_cpu_idle+0x9/0x30
[  541.031299]  [<ffffffff81013ee5>] ? default_idle+0x5/0x10
[  541.031302]  [<ffffffff8108263a>] ? cpu_startup_entry+0x8a/0x180
[  541.031306]  [<ffffffff818d3e3e>] ? start_kernel+0x3ac/0x3b7
[  541.031309]  [<ffffffff818d38a9>] ? repair_env_string+0x5b/0x5b
[  541.031311]  [<ffffffff818d36bc>] ? x86_64_start_kernel+0xf6/0x105


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Patch is against -net (not net-next) because this is a bug fix.
Should be applied to -stable as well.

--- a/include/net/if_inet6.h	2014-03-17 10:53:06.386453341 -0700
+++ b/include/net/if_inet6.h	2014-03-17 11:01:42.383220298 -0700
@@ -59,6 +59,7 @@ struct inet6_ifaddr {
 	unsigned long		tstamp; /* updated timestamp */
 
 	struct timer_list	dad_timer;
+	struct work_struct	dad_work;
 
 	struct inet6_dev	*idev;
 	struct rt6_info		*rt;
--- a/net/ipv6/addrconf.c	2014-03-17 10:53:06.386453341 -0700
+++ b/net/ipv6/addrconf.c	2014-03-17 15:12:52.785628652 -0700
@@ -150,8 +150,10 @@ static struct rt6_info *addrconf_get_pre
 						  const struct net_device *dev,
 						  u32 flags, u32 noflags);
 
+static struct workqueue_struct *addrconf_wq;
 static void addrconf_dad_start(struct inet6_ifaddr *ifp);
 static void addrconf_dad_timer(unsigned long data);
+static void addrconf_dad_work(struct work_struct *work);
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
 static void addrconf_dad_run(struct inet6_dev *idev);
 static void addrconf_rs_timer(unsigned long data);
@@ -851,6 +853,7 @@ ipv6_add_addr(struct inet6_dev *idev, co
 	spin_lock_init(&ifa->state_lock);
 	setup_timer(&ifa->dad_timer, addrconf_dad_timer,
 		    (unsigned long)ifa);
+	INIT_WORK(&ifa->dad_work, addrconf_dad_work);
 	INIT_HLIST_NODE(&ifa->addr_lst);
 	ifa->scope = scope;
 	ifa->prefix_len = pfxlen;
@@ -3203,6 +3206,18 @@ out:
 	read_unlock_bh(&idev->lock);
 }
 
+/* DAD completion is handled in work queue */
+static void addrconf_dad_work(struct work_struct *work)
+{
+	struct inet6_ifaddr *ifp
+		= container_of(work, struct inet6_ifaddr, dad_work);
+
+	rtnl_lock();
+	addrconf_dad_completed(ifp);
+	rtnl_unlock();
+	in6_ifa_put(ifp);
+}
+
 static void addrconf_dad_timer(unsigned long data)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *) data;
@@ -3234,9 +3249,8 @@ static void addrconf_dad_timer(unsigned
 		spin_unlock(&ifp->lock);
 		write_unlock(&idev->lock);
 
-		addrconf_dad_completed(ifp);
-
-		goto out;
+		queue_work(addrconf_wq, &ifp->dad_work);
+		return;
 	}
 
 	ifp->dad_probes--;
@@ -5244,6 +5258,12 @@ int __init addrconf_init(void)
 	if (err < 0)
 		goto out_addrlabel;
 
+	addrconf_wq = create_workqueue("addrconf");
+	if (!addrconf_wq) {
+		err = -ENOMEM;
+		goto out_nowq;
+	}
+
 	/* The addrconf netdev notifier requires that loopback_dev
 	 * has it's ipv6 private information allocated and setup
 	 * before it can bring up and give link-local addresses
@@ -5302,6 +5322,8 @@ errout:
 	rtnl_af_unregister(&inet6_ops);
 	unregister_netdevice_notifier(&ipv6_dev_notf);
 errlo:
+	destroy_workqueue(addrconf_wq);
+out_nowq:
 	unregister_pernet_subsys(&addrconf_ops);
 out_addrlabel:
 	ipv6_addr_label_cleanup();
@@ -5340,4 +5362,5 @@ void addrconf_cleanup(void)
 
 	del_timer(&addr_chk_timer);
 	rtnl_unlock();
+	destroy_workqueue(addrconf_wq);
 }
