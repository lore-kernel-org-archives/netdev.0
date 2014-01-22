From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [PATCH 1/2] net/ipv4: queue work on power efficient wq
Date: Wed, 22 Jan 2014 12:23:32 +0530
Message-ID: <c24546776d8ec32afd1c084dd1d2a72fc96c6519.1390373223.git.viresh.kumar@linaro.org>
Cc: linaro-kernel@lists.linaro.org, patches@linaro.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Viresh Kumar <viresh.kumar@linaro.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Workqueue used in ipv4 layer have no real dependency of scheduling these on the
cpu which scheduled them.

On a idle system, it is observed that an idle cpu wakes up many times just to
service this work. It would be better if we can schedule it on a cpu which the
scheduler believes to be the most appropriate one.

This patch replaces normal workqueues with power efficient versions. This
doesn't change existing behavior of code unless CONFIG_WQ_POWER_EFFICIENT is
enabled.

Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
Initial support for power-efficient workqueues was added here:
https://lkml.org/lkml/2013/4/24/215

 net/ipv4/devinet.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 646023b..ac2dff3 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -474,7 +474,7 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 	inet_hash_insert(dev_net(in_dev->dev), ifa);
 
 	cancel_delayed_work(&check_lifetime_work);
-	schedule_delayed_work(&check_lifetime_work, 0);
+	queue_delayed_work(system_power_efficient_wq, &check_lifetime_work, 0);
 
 	/* Send message first, then call notifier.
 	   Notifier will trigger FIB update, so that
@@ -684,7 +684,8 @@ static void check_lifetime(struct work_struct *work)
 	if (time_before(next_sched, now + ADDRCONF_TIMER_FUZZ_MAX))
 		next_sched = now + ADDRCONF_TIMER_FUZZ_MAX;
 
-	schedule_delayed_work(&check_lifetime_work, next_sched - now);
+	queue_delayed_work(system_power_efficient_wq, &check_lifetime_work,
+			next_sched - now);
 }
 
 static void set_ifa_lifetime(struct in_ifaddr *ifa, __u32 valid_lft,
@@ -842,7 +843,8 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		ifa = ifa_existing;
 		set_ifa_lifetime(ifa, valid_lft, prefered_lft);
 		cancel_delayed_work(&check_lifetime_work);
-		schedule_delayed_work(&check_lifetime_work, 0);
+		queue_delayed_work(system_power_efficient_wq,
+				&check_lifetime_work, 0);
 		rtmsg_ifa(RTM_NEWADDR, ifa, nlh, NETLINK_CB(skb).portid);
 		blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
 	}
@@ -2322,7 +2324,7 @@ void __init devinet_init(void)
 	register_gifconf(PF_INET, inet_gifconf);
 	register_netdevice_notifier(&ip_netdev_notifier);
 
-	schedule_delayed_work(&check_lifetime_work, 0);
+	queue_delayed_work(system_power_efficient_wq, &check_lifetime_work, 0);
 
 	rtnl_af_register(&inet_af_ops);
 
-- 
1.7.12.rc2.18.g61b472e
