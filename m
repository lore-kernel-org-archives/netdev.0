From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] ipv6 addrconf: implement RFC7559 router solicitation backoff
Date: Tue, 27 Sep 2016 23:57:58 -0700
Message-ID: <1475045878-30455-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32953 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbcI1G6O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 02:58:14 -0400
Received: by mail-pf0-f196.google.com with SMTP id q2so1752015pfj.0
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 23:58:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

This implements:
  https://tools.ietf.org/html/rfc7559

Backoff is performed according to RFC3315 section 14:
  https://tools.ietf.org/html/rfc3315#section-14

We allow setting /proc/sys/net/ipv6/conf/*/router_solicitations
to a negative value meaning an unlimited number of retransmits,
and we make this the new default (inline with the RFC).

We also add a new setting:
  /proc/sys/net/ipv6/conf/*/router_solicitation_max_interval
defaulting to 1 hour (per RFC recommendation).

Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 include/linux/ipv6.h      |  1 +
 include/net/addrconf.h    |  3 ++-
 include/net/if_inet6.h    |  1 +
 include/uapi/linux/ipv6.h |  1 +
 net/ipv6/addrconf.c       | 51 ++++++++++++++++++++++++++++++++++++++++-------
 5 files changed, 49 insertions(+), 8 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index c6dbcd84a2c7..7e9a789be5e0 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -18,6 +18,7 @@ struct ipv6_devconf {
 	__s32		dad_transmits;
 	__s32		rtr_solicits;
 	__s32		rtr_solicit_interval;
+	__s32		rtr_solicit_max_interval;
 	__s32		rtr_solicit_delay;
 	__s32		force_mld_version;
 	__s32		mldv1_unsolicited_report_interval;
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 9826d3a9464c..f2d072787947 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -1,8 +1,9 @@
 #ifndef _ADDRCONF_H
 #define _ADDRCONF_H
 
-#define MAX_RTR_SOLICITATIONS		3
+#define MAX_RTR_SOLICITATIONS		-1		/* unlimited */
 #define RTR_SOLICITATION_INTERVAL	(4*HZ)
+#define RTR_SOLICITATION_MAX_INTERVAL	(3600*HZ)	/* 1 hour */
 
 #define MIN_VALID_LIFETIME		(2*3600)	/* 2 hours */
 
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 1c8b6820b694..515352c6280a 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -201,6 +201,7 @@ struct inet6_dev {
 	struct ipv6_devstat	stats;
 
 	struct timer_list	rs_timer;
+	__s32			rs_interval;	/* in jiffies */
 	__u8			rs_probes;
 
 	__u8			addr_gen_mode;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 395876060f50..8c2772340c3f 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -177,6 +177,7 @@ enum {
 	DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
 	DEVCONF_DROP_UNSOLICITED_NA,
 	DEVCONF_KEEP_ADDR_ON_DOWN,
+	DEVCONF_RTR_SOLICIT_MAX_INTERVAL,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2f1f5d439788..49bee9bc5ff3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -112,6 +112,27 @@ static inline u32 cstamp_delta(unsigned long cstamp)
 	return (cstamp - INITIAL_JIFFIES) * 100UL / HZ;
 }
 
+static inline s32 rfc3315_s14_backoff_init(s32 irt)
+{
+	/* multiply 'initial retransmission time' by 0.9 .. 1.1 */
+	u64 tmp = (900000 + prandom_u32() % 200001) * (u64)irt;
+	do_div(tmp, 1000000);
+	return (s32)tmp;
+}
+
+static inline s32 rfc3315_s14_backoff_update(s32 rt, s32 mrt)
+{
+	/* multiply 'retransmission timeout' by 1.9 .. 2.1 */
+	u64 tmp = (1900000 + prandom_u32() % 200001) * (u64)rt;
+	do_div(tmp, 1000000);
+	if ((s32)tmp > mrt) {
+		/* multiply 'maximum retransmission time' by 0.9 .. 1.1 */
+		tmp = (900000 + prandom_u32() % 200001) * (u64)mrt;
+		do_div(tmp, 1000000);
+	}
+	return (s32)tmp;
+}
+
 #ifdef CONFIG_SYSCTL
 static int addrconf_sysctl_register(struct inet6_dev *idev);
 static void addrconf_sysctl_unregister(struct inet6_dev *idev);
@@ -187,6 +208,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.dad_transmits		= 1,
 	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
 	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
+	.rtr_solicit_max_interval = RTR_SOLICITATION_MAX_INTERVAL,
 	.rtr_solicit_delay	= MAX_RTR_SOLICITATION_DELAY,
 	.use_tempaddr		= 0,
 	.temp_valid_lft		= TEMP_VALID_LIFETIME,
@@ -232,6 +254,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.dad_transmits		= 1,
 	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
 	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
+	.rtr_solicit_max_interval = RTR_SOLICITATION_MAX_INTERVAL,
 	.rtr_solicit_delay	= MAX_RTR_SOLICITATION_DELAY,
 	.use_tempaddr		= 0,
 	.temp_valid_lft		= TEMP_VALID_LIFETIME,
@@ -3687,7 +3710,7 @@ static void addrconf_rs_timer(unsigned long data)
 	if (idev->if_flags & IF_RA_RCVD)
 		goto out;
 
-	if (idev->rs_probes++ < idev->cnf.rtr_solicits) {
+	if (idev->rs_probes++ < idev->cnf.rtr_solicits || idev->cnf.rtr_solicits < 0) {
 		write_unlock(&idev->lock);
 		if (!ipv6_get_lladdr(dev, &lladdr, IFA_F_TENTATIVE))
 			ndisc_send_rs(dev, &lladdr,
@@ -3696,11 +3719,13 @@ static void addrconf_rs_timer(unsigned long data)
 			goto put;
 
 		write_lock(&idev->lock);
+		idev->rs_interval = rfc3315_s14_backoff_update(
+			idev->rs_interval, idev->cnf.rtr_solicit_max_interval);
 		/* The wait after the last probe can be shorter */
 		addrconf_mod_rs_timer(idev, (idev->rs_probes ==
 					     idev->cnf.rtr_solicits) ?
 				      idev->cnf.rtr_solicit_delay :
-				      idev->cnf.rtr_solicit_interval);
+				      idev->rs_interval);
 	} else {
 		/*
 		 * Note: we do not support deprecated "all on-link"
@@ -3949,7 +3974,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 	send_mld = ifp->scope == IFA_LINK && ipv6_lonely_lladdr(ifp);
 	send_rs = send_mld &&
 		  ipv6_accept_ra(ifp->idev) &&
-		  ifp->idev->cnf.rtr_solicits > 0 &&
+		  ifp->idev->cnf.rtr_solicits != 0 &&
 		  (dev->flags&IFF_LOOPBACK) == 0;
 	read_unlock_bh(&ifp->idev->lock);
 
@@ -3971,10 +3996,11 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 
 		write_lock_bh(&ifp->idev->lock);
 		spin_lock(&ifp->lock);
+		ifp->idev->rs_interval = rfc3315_s14_backoff_init(
+			ifp->idev->cnf.rtr_solicit_interval);
 		ifp->idev->rs_probes = 1;
 		ifp->idev->if_flags |= IF_RS_SENT;
-		addrconf_mod_rs_timer(ifp->idev,
-				      ifp->idev->cnf.rtr_solicit_interval);
+		addrconf_mod_rs_timer(ifp->idev, ifp->idev->rs_interval);
 		spin_unlock(&ifp->lock);
 		write_unlock_bh(&ifp->idev->lock);
 	}
@@ -4891,6 +4917,8 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_RTR_SOLICITS] = cnf->rtr_solicits;
 	array[DEVCONF_RTR_SOLICIT_INTERVAL] =
 		jiffies_to_msecs(cnf->rtr_solicit_interval);
+	array[DEVCONF_RTR_SOLICIT_MAX_INTERVAL] =
+		jiffies_to_msecs(cnf->rtr_solicit_max_interval);
 	array[DEVCONF_RTR_SOLICIT_DELAY] =
 		jiffies_to_msecs(cnf->rtr_solicit_delay);
 	array[DEVCONF_FORCE_MLD_VERSION] = cnf->force_mld_version;
@@ -5099,7 +5127,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 		return -EINVAL;
 	if (!ipv6_accept_ra(idev))
 		return -EINVAL;
-	if (idev->cnf.rtr_solicits <= 0)
+	if (idev->cnf.rtr_solicits == 0)
 		return -EINVAL;
 
 	write_lock_bh(&idev->lock);
@@ -5128,8 +5156,10 @@ update_lft:
 
 	if (update_rs) {
 		idev->if_flags |= IF_RS_SENT;
+		idev->rs_interval = rfc3315_s14_backoff_init(
+			idev->cnf.rtr_solicit_interval);
 		idev->rs_probes = 1;
-		addrconf_mod_rs_timer(idev, idev->cnf.rtr_solicit_interval);
+		addrconf_mod_rs_timer(idev, idev->rs_interval);
 	}
 
 	/* Well, that's kinda nasty ... */
@@ -5778,6 +5808,13 @@ static const struct ctl_table addrconf_sysctl[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
+		.procname	= "router_solicitation_max_interval",
+		.data		= &ipv6_devconf.rtr_solicit_max_interval,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
 		.procname	= "router_solicitation_delay",
 		.data		= &ipv6_devconf.rtr_solicit_delay,
 		.maxlen		= sizeof(int),
-- 
2.8.0.rc3.226.g39d4020
