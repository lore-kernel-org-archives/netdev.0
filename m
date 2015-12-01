From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH] net: ipv6: restrict hop_limit sysctl setting to range [1;255]
Date: Tue,  1 Dec 2015 22:45:15 +0100
Message-ID: <1449006315-11175-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:45663 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756358AbbLAVpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 16:45:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting a value bigger than 255 resulted in using only the lower eight
bits of that value as it is assigned to the u8 header field. To avoid
this unexpected result, reject such values.

Setting a value of zero is technically possible, but hosts receiving
such a packet have to treat it like hop_limit was set to one, according
to RFC2460. Therefore I don't see a use-case for that.

Setting a route's hop_limit to zero in iproute2 means to use the sysctl
default, which is not the case here: Setting e.g.
net.conf.eth0.hop_limit=0 will not make the kernel use
net.conf.all.hop_limit for outgoing packets on eth0. To avoid these
kinds of confusion, reject zero.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/ipv6/addrconf.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d84742f003a9f..a5de1a616c12a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5200,6 +5200,20 @@ int addrconf_sysctl_forward(struct ctl_table *ctl, int write,
 }
 
 static
+int addrconf_sysctl_hop_limit(struct ctl_table *ctl, int write,
+                              void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct ctl_table lctl;
+	int min_hl = 1, max_hl = 255;
+
+	lctl = *ctl;
+	lctl.extra1 = &min_hl;
+	lctl.extra2 = &max_hl;
+
+	return proc_dointvec_minmax(&lctl, write, buffer, lenp, ppos);
+}
+
+static
 int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
 			void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -5454,7 +5468,7 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.hop_limit,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_sysctl_hop_limit,
 		},
 		{
 			.procname	= "mtu",
-- 
2.1.2
