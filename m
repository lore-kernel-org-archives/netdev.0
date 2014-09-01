From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH 1/2] ipv6: add sysctl_mld_qrv to configure query robustness variable
Date: Mon,  1 Sep 2014 21:55:34 +0200
Message-ID: <aa72acbd19015e6db6b2d425fb6ebf6a8fa9c3b5.1409601046.git.hannes@stressinduktion.org>
Cc: Flavio Leitner <fbl@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:57556 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751500AbaIATzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 15:55:45 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id AF57D208DC
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 15:55:42 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new sysctl_mld_qrv knob to configure the mldv1/v2 query
robustness variable. It specifies how many retransmit of unsolicited mld
retransmit should happen. Admins might want to tune this on lossy links.

Also reset mld state on interface down/up, so we pick up new sysctl
settings during interface up event.

IPv6 certification requests this knob to be available.

I didn't make this knob netns specific, as it is mostly a setting in a
physical environment and should be per host.

Cc: Flavio Leitner <fbl@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2) no changes to original version

 Documentation/networking/ip-sysctl.txt |  3 +++
 include/net/ipv6.h                     |  1 +
 net/ipv6/mcast.c                       | 20 ++++++++++++--------
 net/ipv6/sysctl_net_ipv6.c             | 10 ++++++++++
 4 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 3cce8ea..b7fe844 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1152,6 +1152,9 @@ anycast_src_echo_reply - BOOLEAN
 	FALSE: disabled
 	Default: FALSE
 
+mld_qrv - INTEGER
+	Controls the MLD query robustness variable (see RFC3810 9.1).
+
 IPv6 Fragmentation:
 
 ip6frag_high_thresh - INTEGER
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index a2db816..7e247e9 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -121,6 +121,7 @@ struct frag_hdr {
 
 /* sysctls */
 extern int sysctl_mld_max_msf;
+extern int sysctl_mld_qrv;
 
 #define _DEVINC(net, statname, modifier, idev, field)			\
 ({									\
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 7088179..6efb0e5 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -121,6 +121,7 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 #define IPV6_MLD_MAX_MSF	64
 
 int sysctl_mld_max_msf __read_mostly = IPV6_MLD_MAX_MSF;
+int sysctl_mld_qrv __read_mostly = MLD_QRV_DEFAULT;
 
 /*
  *	socket join on multicast group
@@ -1196,7 +1197,7 @@ static void mld_update_qrv(struct inet6_dev *idev,
 	if (mlh2->mld2q_qrv > 0)
 		idev->mc_qrv = mlh2->mld2q_qrv;
 
-	if (unlikely(idev->mc_qrv < 2)) {
+	if (unlikely(idev->mc_qrv < MLD_QRV_DEFAULT)) {
 		net_warn_ratelimited("IPv6: MLD: clamping QRV from %u to %u!\n",
 				     idev->mc_qrv, MLD_QRV_DEFAULT);
 		idev->mc_qrv = MLD_QRV_DEFAULT;
@@ -2478,6 +2479,14 @@ void ipv6_mc_down(struct inet6_dev *idev)
 	mld_clear_delrec(idev);
 }
 
+static void ipv6_mc_reset(struct inet6_dev *idev)
+{
+	idev->mc_qrv = sysctl_mld_qrv;
+	idev->mc_qi = MLD_QI_DEFAULT;
+	idev->mc_qri = MLD_QRI_DEFAULT;
+	idev->mc_v1_seen = 0;
+	idev->mc_maxdelay = unsolicited_report_interval(idev);
+}
 
 /* Device going up */
 
@@ -2488,6 +2497,7 @@ void ipv6_mc_up(struct inet6_dev *idev)
 	/* Install multicast list, except for all-nodes (already installed) */
 
 	read_lock_bh(&idev->lock);
+	ipv6_mc_reset(idev);
 	for (i = idev->mc_list; i; i = i->next)
 		igmp6_group_added(i);
 	read_unlock_bh(&idev->lock);
@@ -2508,13 +2518,7 @@ void ipv6_mc_init_dev(struct inet6_dev *idev)
 			(unsigned long)idev);
 	setup_timer(&idev->mc_dad_timer, mld_dad_timer_expire,
 		    (unsigned long)idev);
-
-	idev->mc_qrv = MLD_QRV_DEFAULT;
-	idev->mc_qi = MLD_QI_DEFAULT;
-	idev->mc_qri = MLD_QRI_DEFAULT;
-
-	idev->mc_maxdelay = unsolicited_report_interval(idev);
-	idev->mc_v1_seen = 0;
+	ipv6_mc_reset(idev);
 	write_unlock_bh(&idev->lock);
 }
 
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 0c56c93..c5c10fa 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -16,6 +16,8 @@
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
 
+static int one = 1;
+
 static struct ctl_table ipv6_table_template[] = {
 	{
 		.procname	= "bindv6only",
@@ -63,6 +65,14 @@ static struct ctl_table ipv6_rotable[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "mld_qrv",
+		.data		= &sysctl_mld_qrv,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one
+	},
 	{ }
 };
 
-- 
1.9.3
