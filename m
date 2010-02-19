From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/2] net:  Fix sysctl restarts...
Date: Fri, 19 Feb 2010 15:22:59 -0800
Message-ID: <m14olcu7xo.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59009 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755745Ab0BSXXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 18:23:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Yuck.  It turns out that when we restart sysctls we were restarting
with the values already changed.  Which unfortunately meant that
the second time through we thought there was no change and skipped
all kinds of work, despite the fact that there was indeed a change.

I have fixed this the simplest way possible by restoring the changed
values when we restart the sysctl write.

One of my coworkers spotted this bug when after disabling forwarding
on an interface pings were still forwarded.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/devinet.c  |    7 ++++++-
 net/ipv6/addrconf.c |   16 ++++++++++++++--
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 014982b..51ca946 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1317,14 +1317,19 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
 {
 	int *valp = ctl->data;
 	int val = *valp;
+	loff_t pos = *ppos;
 	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	if (write && *valp != val) {
 		struct net *net = ctl->extra2;
 
 		if (valp != &IPV4_DEVCONF_DFLT(net, FORWARDING)) {
-			if (!rtnl_trylock())
+			if (!rtnl_trylock()) {
+				/* Restore the original values before restarting */
+				*valp = val;
+				*ppos = pos;
 				return restart_syscall();
+			}
 			if (valp == &IPV4_DEVCONF_ALL(net, FORWARDING)) {
 				inet_forward_change(net);
 			} else if (*valp) {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b0d4a4b..5bcf0d3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -502,8 +502,11 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
 	if (p == &net->ipv6.devconf_dflt->forwarding)
 		return 0;
 
-	if (!rtnl_trylock())
+	if (!rtnl_trylock()) {
+		/* Restore the original values before restarting */
+		*p = old; 
 		return restart_syscall();
+	}
 
 	if (p == &net->ipv6.devconf_all->forwarding) {
 		__s32 newf = net->ipv6.devconf_all->forwarding;
@@ -4042,12 +4045,15 @@ int addrconf_sysctl_forward(ctl_table *ctl, int write,
 {
 	int *valp = ctl->data;
 	int val = *valp;
+	loff_t pos = *ppos;
 	int ret;
 
 	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	if (write)
 		ret = addrconf_fixup_forwarding(ctl, valp, val);
+	if (ret)
+		*ppos = pos;
 	return ret;
 }
 
@@ -4089,8 +4095,11 @@ static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int old)
 	if (p == &net->ipv6.devconf_dflt->disable_ipv6)
 		return 0;
 
-	if (!rtnl_trylock())
+	if (!rtnl_trylock()) {
+		/* Restore the original values before restarting */
+		*p = old; 
 		return restart_syscall();
+	}
 
 	if (p == &net->ipv6.devconf_all->disable_ipv6) {
 		__s32 newf = net->ipv6.devconf_all->disable_ipv6;
@@ -4109,12 +4118,15 @@ int addrconf_sysctl_disable(ctl_table *ctl, int write,
 {
 	int *valp = ctl->data;
 	int val = *valp;
+	loff_t pos = *ppos;
 	int ret;
 
 	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	if (write)
 		ret = addrconf_disable_ipv6(ctl, valp, val);
+	if (ret)
+		*ppos = pos;
 	return ret;
 }
 
-- 
1.6.5.2.143.g8cc62

