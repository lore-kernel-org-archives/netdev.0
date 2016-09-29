From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] ipv6 addrconf: remove addrconf_sysctl_hop_limit()
Date: Thu, 29 Sep 2016 00:33:43 -0700
Message-ID: <1475134423-23635-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36616 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754816AbcI2HeB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 03:34:01 -0400
Received: by mail-pf0-f195.google.com with SMTP id n24so3192536pfb.3
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 00:34:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

This is an effective no-op in terms of user observable behaviour.

By preventing the overwrite of non-null extra1/extra2 fields
in addrconf_sysctl() we can enable the use of proc_dointvec_minmax().

This allows us to eliminate the constant min/max (1..255) trampoline
function that is addrconf_sysctl_hop_limit().

This is nice because it simplifies the code, and allows future
sysctls with constant min/max limits to also not require trampolines.

We still can't eliminate the trampoline for mtu because it isn't
actually a constant (it depends on other tunables of the device)
and thus requires at-write-time logic to enforce range.

Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 net/ipv6/addrconf.c | 31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2f1f5d439788..8bd2d06eefe7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5467,20 +5467,6 @@ int addrconf_sysctl_forward(struct ctl_table *ctl, int write,
 }
 
 static
-int addrconf_sysctl_hop_limit(struct ctl_table *ctl, int write,
-                              void __user *buffer, size_t *lenp, loff_t *ppos)
-{
-	struct ctl_table lctl;
-	int min_hl = 1, max_hl = 255;
-
-	lctl = *ctl;
-	lctl.extra1 = &min_hl;
-	lctl.extra2 = &max_hl;
-
-	return proc_dointvec_minmax(&lctl, write, buffer, lenp, ppos);
-}
-
-static
 int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
 			void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -5713,6 +5699,9 @@ int addrconf_sysctl_ignore_routes_with_linkdown(struct ctl_table *ctl,
 	return ret;
 }
 
+static const int one = 1;
+static const int two_five_five = 255;
+
 static const struct ctl_table addrconf_sysctl[] = {
 	{
 		.procname	= "forwarding",
@@ -5726,7 +5715,9 @@ static const struct ctl_table addrconf_sysctl[] = {
 		.data		= &ipv6_devconf.hop_limit,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= addrconf_sysctl_hop_limit,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void *)&one,
+		.extra2		= (void *)&two_five_five,
 	},
 	{
 		.procname	= "mtu",
@@ -6044,8 +6035,14 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 
 	for (i = 0; table[i].data; i++) {
 		table[i].data += (char *)p - (char *)&ipv6_devconf;
-		table[i].extra1 = idev; /* embedded; no ref */
-		table[i].extra2 = net;
+		/* If one of these is already set, then it is not safe to
+		 * overwrite either of them: this makes proc_dointvec_minmax
+		 * usable.
+		 */
+		if (!table[i].extra1 && !table[i].extra2) {
+			table[i].extra1 = idev; /* embedded; no ref */
+			table[i].extra2 = net;
+		}
 	}
 
 	snprintf(path, sizeof(path), "net/ipv6/conf/%s", dev_name);
-- 
2.8.0.rc3.226.g39d4020
