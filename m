From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH v5 3/7] ipv6 addrconf: rtr_solicits == -1 means unlimited
Date: Tue, 27 Sep 2016 02:52:39 -0700
Message-ID: <1474969963-17402-4-git-send-email-zenczykowski@gmail.com>
References: <CANP3RGfHPZLHFnp4Rq8_dRNCro6Uh8O8767NgoGu7gvzu5h9BQ@mail.gmail.com>
 <1474969963-17402-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35480 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933451AbcI0Jw7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 05:52:59 -0400
Received: by mail-pf0-f194.google.com with SMTP id 6so528329pfl.2
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 02:52:59 -0700 (PDT)
In-Reply-To: <1474969963-17402-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

This allows setting /proc/sys/net/ipv6/conf/*/router_solicitations
to -1 meaning an unlimited number of retransmits.

Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 net/ipv6/addrconf.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8bd2d06eefe7..1e59c0034916 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3687,7 +3687,7 @@ static void addrconf_rs_timer(unsigned long data)
 	if (idev->if_flags & IF_RA_RCVD)
 		goto out;
 
-	if (idev->rs_probes++ < idev->cnf.rtr_solicits) {
+	if (idev->rs_probes++ < idev->cnf.rtr_solicits || idev->cnf.rtr_solicits == -1) {
 		write_unlock(&idev->lock);
 		if (!ipv6_get_lladdr(dev, &lladdr, IFA_F_TENTATIVE))
 			ndisc_send_rs(dev, &lladdr,
@@ -3949,7 +3949,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 	send_mld = ifp->scope == IFA_LINK && ipv6_lonely_lladdr(ifp);
 	send_rs = send_mld &&
 		  ipv6_accept_ra(ifp->idev) &&
-		  ifp->idev->cnf.rtr_solicits > 0 &&
+		  ifp->idev->cnf.rtr_solicits != 0 &&
 		  (dev->flags&IFF_LOOPBACK) == 0;
 	read_unlock_bh(&ifp->idev->lock);
 
@@ -5099,7 +5099,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 		return -EINVAL;
 	if (!ipv6_accept_ra(idev))
 		return -EINVAL;
-	if (idev->cnf.rtr_solicits <= 0)
+	if (idev->cnf.rtr_solicits == 0)
 		return -EINVAL;
 
 	write_lock_bh(&idev->lock);
@@ -5699,6 +5699,7 @@ int addrconf_sysctl_ignore_routes_with_linkdown(struct ctl_table *ctl,
 	return ret;
 }
 
+static const int minus_one = -1;
 static const int one = 1;
 static const int two_five_five = 255;
 
@@ -5759,7 +5760,8 @@ static const struct ctl_table addrconf_sysctl[] = {
 		.data		= &ipv6_devconf.rtr_solicits,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void *)&minus_one,
 	},
 	{
 		.procname	= "router_solicitation_interval",
-- 
2.8.0.rc3.226.g39d4020
