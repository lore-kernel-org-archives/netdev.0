From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v3] ipv6: make unsolicited report intervals configurable for mld
Date: Wed, 14 Aug 2013 01:03:46 +0200
Message-ID: <20130813230346.GA16264@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: xiyou.wangcong@gmail.com, william.manley@youview.com,
	bcrl@kvack.org, yoshfuji@linux-ipv6.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49996 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755835Ab3HMXDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 19:03:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit cab70040dfd95ee32144f02fade64f0cb94f31a0 ("net: igmp:
Reduce Unsolicited report interval to 1s when using IGMPv3") and
2690048c01f32bf45d1c1e1ab3079bc10ad2aea7 ("net: igmp: Allow user-space
configuration of igmp unsolicited report interval") by William Manley made
igmp unsolicited report intervals configurable per interface and corrected
the interval of unsolicited igmpv3 report messages resendings to 1s.

Same needs to be done for IPv6:

MLDv1 (RFC2710 7.10.): 10 seconds
MLDv2 (RFC3810 9.11.): 1 second

Both intervals are configurable via new procfs knobs
mldv1_unsolicited_report_interval and mldv2_unsolicited_report_interval.

(also added .force_mld_version to ipv6_devconf_dflt to bring structs in
line without semantic changes)

v2:
a) Joined documentation update for IPv4 and IPv6 MLD/IGMP
   unsolicited_report_interval procfs knobs.
b) incorporate stylistic feedback from William Manley

v3:
a) add new DEVCONF_* values to the end of the enum (thanks to David
   Miller)

Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: William Manley <william.manley@youview.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 Documentation/networking/ip-sysctl.txt | 18 ++++++++++++++++++
 include/linux/ipv6.h                   |  2 ++
 include/uapi/linux/ipv6.h              |  2 ++
 net/ipv6/addrconf.c                    | 25 +++++++++++++++++++++++++
 net/ipv6/mcast.c                       | 17 ++++++++++++++---
 5 files changed, 61 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 36be26b..debfe85 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1039,7 +1039,15 @@ disable_policy - BOOLEAN
 disable_xfrm - BOOLEAN
 	Disable IPSEC encryption on this interface, whatever the policy
 
+igmpv2_unsolicited_report_interval - INTEGER
+	The interval in milliseconds in which the next unsolicited
+	IGMPv1 or IGMPv2 report retransmit will take place.
+	Default: 10000 (10 seconds)
 
+igmpv3_unsolicited_report_interval - INTEGER
+	The interval in milliseconds in which the next unsolicited
+	IGMPv3 report retransmit will take place.
+	Default: 1000 (1 seconds)
 
 tag - INTEGER
 	Allows you to write a number, which can be used as required.
@@ -1331,6 +1339,16 @@ ndisc_notify - BOOLEAN
 	1 - Generate unsolicited neighbour advertisements when device is brought
 	    up or hardware address changes.
 
+mldv1_unsolicited_report_interval - INTEGER
+	The interval in milliseconds in which the next unsolicited
+	MLDv1 report retransmit will take place.
+	Default: 10000 (10 seconds)
+
+mldv2_unsolicited_report_interval - INTEGER
+	The interval in milliseconds in which the next unsolicited
+	MLDv2 report retransmit will take place.
+	Default: 1000 (1 second)
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 850e95b..77a4784 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -19,6 +19,8 @@ struct ipv6_devconf {
 	__s32		rtr_solicit_interval;
 	__s32		rtr_solicit_delay;
 	__s32		force_mld_version;
+	__s32		mldv1_unsolicited_report_interval;
+	__s32		mldv2_unsolicited_report_interval;
 #ifdef CONFIG_IPV6_PRIVACY
 	__s32		use_tempaddr;
 	__s32		temp_valid_lft;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 4bda4cf..d07ac69 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -160,6 +160,8 @@ enum {
 	DEVCONF_ACCEPT_DAD,
 	DEVCONF_FORCE_TLLAO,
 	DEVCONF_NDISC_NOTIFY,
+	DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL,
+	DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7fd8572..ad12f7c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -177,6 +177,8 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.accept_redirects	= 1,
 	.autoconf		= 1,
 	.force_mld_version	= 0,
+	.mldv1_unsolicited_report_interval = 10 * HZ,
+	.mldv2_unsolicited_report_interval = HZ,
 	.dad_transmits		= 1,
 	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
 	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
@@ -211,6 +213,9 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.accept_ra		= 1,
 	.accept_redirects	= 1,
 	.autoconf		= 1,
+	.force_mld_version	= 0,
+	.mldv1_unsolicited_report_interval = 10 * HZ,
+	.mldv2_unsolicited_report_interval = HZ,
 	.dad_transmits		= 1,
 	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
 	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
@@ -4179,6 +4184,10 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_RTR_SOLICIT_DELAY] =
 		jiffies_to_msecs(cnf->rtr_solicit_delay);
 	array[DEVCONF_FORCE_MLD_VERSION] = cnf->force_mld_version;
+	array[DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL] =
+		jiffies_to_msecs(cnf->mldv1_unsolicited_report_interval);
+	array[DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL] =
+		jiffies_to_msecs(cnf->mldv2_unsolicited_report_interval);
 #ifdef CONFIG_IPV6_PRIVACY
 	array[DEVCONF_USE_TEMPADDR] = cnf->use_tempaddr;
 	array[DEVCONF_TEMP_VALID_LFT] = cnf->temp_valid_lft;
@@ -4862,6 +4871,22 @@ static struct addrconf_sysctl_table
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
+		{
+			.procname	= "mldv1_unsolicited_report_interval",
+			.data		=
+				&ipv6_devconf.mldv1_unsolicited_report_interval,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec_ms_jiffies,
+		},
+		{
+			.procname	= "mldv2_unsolicited_report_interval",
+			.data		=
+				&ipv6_devconf.mldv2_unsolicited_report_interval,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec_ms_jiffies,
+		},
 #ifdef CONFIG_IPV6_PRIVACY
 		{
 			.procname	= "use_tempaddr",
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index db25b8e..6c76df9 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -108,7 +108,6 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 			    struct inet6_dev *idev);
 
 
-#define IGMP6_UNSOLICITED_IVAL	(10*HZ)
 #define MLD_QRV_DEFAULT		2
 
 #define MLD_V1_SEEN(idev) (dev_net((idev)->dev)->ipv6.devconf_all->force_mld_version == 1 || \
@@ -129,6 +128,18 @@ int sysctl_mld_max_msf __read_mostly = IPV6_MLD_MAX_MSF;
 	     pmc != NULL;					\
 	     pmc = rcu_dereference(pmc->next))
 
+static int unsolicited_report_interval(struct inet6_dev *idev)
+{
+	int iv;
+
+	if (MLD_V1_SEEN(idev))
+		iv = idev->cnf.mldv1_unsolicited_report_interval;
+	else
+		iv = idev->cnf.mldv2_unsolicited_report_interval;
+
+	return iv > 0 ? iv : 1;
+}
+
 int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 {
 	struct net_device *dev = NULL;
@@ -2158,7 +2169,7 @@ static void igmp6_join_group(struct ifmcaddr6 *ma)
 
 	igmp6_send(&ma->mca_addr, ma->idev->dev, ICMPV6_MGM_REPORT);
 
-	delay = net_random() % IGMP6_UNSOLICITED_IVAL;
+	delay = net_random() % unsolicited_report_interval(ma->idev);
 
 	spin_lock_bh(&ma->mca_lock);
 	if (del_timer(&ma->mca_timer)) {
@@ -2325,7 +2336,7 @@ void ipv6_mc_init_dev(struct inet6_dev *idev)
 	setup_timer(&idev->mc_dad_timer, mld_dad_timer_expire,
 		    (unsigned long)idev);
 	idev->mc_qrv = MLD_QRV_DEFAULT;
-	idev->mc_maxdelay = IGMP6_UNSOLICITED_IVAL;
+	idev->mc_maxdelay = unsolicited_report_interval(idev);
 	idev->mc_v1_seen = 0;
 	write_unlock_bh(&idev->lock);
 }
-- 
1.8.3.1
