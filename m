From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH v2 net] ipv6: addrconf: validate new MTU before applying it
Date: Mon, 23 Feb 2015 11:17:13 -0300
Message-ID: <463ebd12cf29ddcf17275bdde9fb629444a5fa5b.1424698335.git.mleitner@redhat.com>
Cc: Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752450AbbBWOR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2015 09:17:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we don't check if the new MTU is valid or not and this allows
one to configure a smaller than minimum allowed by RFCs or even bigger
than interface own MTU, which is a problem as it may lead to packet
drops.

If you have a daemon like NetworkManager running, this may be exploited
by remote attackers by forging RA packets with an invalid MTU, possibly
leading to a DoS. (NetworkManager currently only validates for values
too small, but not for too big ones.)

The fix is just to make sure the new value is valid. That is, between
IPV6_MIN_MTU and interface's MTU.

Note that similar check is already performed at
ndisc_router_discovery(), for when kernel itself parses the RA.

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
---

Notes:
    Sabrina, please feel free to add your Signed-off-by if you want.
    
    v1->v2, applied Sabrina's notes:
       use proc_dointvec_minmax instead
       protect against all and default cases, which don't have idev
    
    all and default are simply not used, so we are good to simply ignore the
    max values for them. The default value actually comes from interface MTU
    during creation.

 net/ipv6/addrconf.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 98e4a63d72bb435e1ac1ae7cf2767072eed6db92..b6030025f41197efbcdfd1d8c013e469413550b5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4903,6 +4903,21 @@ int addrconf_sysctl_forward(struct ctl_table *ctl, int write,
 	return ret;
 }
 
+static
+int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
+			void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct inet6_dev *idev = ctl->extra1;
+	int min_mtu = IPV6_MIN_MTU;
+	struct ctl_table lctl;
+
+	lctl = *ctl;
+	lctl.extra1 = &min_mtu;
+	lctl.extra2 = idev ? &idev->dev->mtu : NULL;
+
+	return proc_dointvec_minmax(&lctl, write, buffer, lenp, ppos);
+}
+
 static void dev_disable_change(struct inet6_dev *idev)
 {
 	struct netdev_notifier_info info;
@@ -5054,7 +5069,7 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.mtu6,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_sysctl_mtu,
 		},
 		{
 			.procname	= "accept_ra",
-- 
1.9.3
