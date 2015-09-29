From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: [linux 3.14-stable] ipv6: addrconf: validate new MTU before
 applying it
Date: Tue, 29 Sep 2015 16:01:19 -0400
Message-ID: <1443556879.3494.38.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:35798 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbbI2UBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 16:01:21 -0400
Received: by qkap81 with SMTP id p81so8389920qka.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 13:01:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Leitner <mleitner@redhat.com>

commit 77751427a1ff25b27d47a4c36b12c3c8667855ac upstream.

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

Fixes CVE-2015-0272.

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Chas Williams <3chas3@gmail.com>
---
 net/ipv6/addrconf.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3f0ec06..7b74fca 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4793,6 +4793,21 @@ int addrconf_sysctl_forward(struct ctl_table *ctl, int write,
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
@@ -4944,7 +4959,7 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.mtu6,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_sysctl_mtu,
 		},
 		{
 			.procname	= "accept_ra",
-- 
2.1.0
