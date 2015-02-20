From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH net] ipv6: addrconf: validate new MTU before applying it
Date: Fri, 20 Feb 2015 16:24:06 -0200
Message-ID: <60cde83b718e88aa7fcae7239a3aac704e048efc.1424456163.git.mleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753700AbbBTSYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2015 13:24:12 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1KIOBqd004924
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 13:24:12 -0500
Received: from localhost.localdomain.com ([10.3.113.3])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1KIOAFY006549
	for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 13:24:11 -0500
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
 net/ipv6/addrconf.c | 32 +++++++++++++++++++++++++++++++-
 1 file changed, 31 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f7c8bbeb27b704c0106f714d5a0677c27d3346e0..38892228ccacfe8b67b182784723cc0b67ce572b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4863,6 +4863,36 @@ int addrconf_sysctl_forward(struct ctl_table *ctl, int write,
 	return ret;
 }
 
+static
+int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
+			void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int *valp = ctl->data;
+	int val = *valp;
+	loff_t pos = *ppos;
+	struct ctl_table lctl;
+	int ret;
+
+	/* ctl->data points to idev->cnf.mtu6
+	 */
+	lctl = *ctl;
+	lctl.data = &val;
+
+	ret = proc_dointvec(&lctl, write, buffer, lenp, ppos);
+
+	if (write) {
+		struct inet6_dev *idev = ctl->extra1;
+
+		if (val >= IPV6_MIN_MTU && val <= idev->dev->mtu)
+			*valp = val;
+		else
+			ret = -EINVAL;
+	}
+	if (ret)
+		*ppos = pos;
+	return ret;
+}
+
 static void dev_disable_change(struct inet6_dev *idev)
 {
 	struct netdev_notifier_info info;
@@ -5014,7 +5044,7 @@ static struct addrconf_sysctl_table
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
