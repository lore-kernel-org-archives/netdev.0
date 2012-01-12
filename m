From: David Miller <davem@davemloft.net>
Subject: Re: Race condition in ipv6 code
Date: Wed, 11 Jan 2012 22:44:29 -0800 (PST)
Message-ID: <20120111.224429.1750818553057090631.davem@davemloft.net>
References: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
	<1326349911.2741.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fruggeri@aristanetworks.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536Ab2ALGof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 01:44:35 -0500
In-Reply-To: <1326349911.2741.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Jan 2012 07:31:51 +0100

> Real question is : why are we using this horrible thing at all
> 
> if (!rtnl_trylock())
> 	return restart_syscall();

Because:

--------------------
commit 88af182e389097997c5e2a0b42285b3522796759
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Fri Feb 19 13:22:59 2010 +0000

    net: Fix sysctl restarts...
    
    Yuck.  It turns out that when we restart sysctls we were restarting
    with the values already changed.  Which unfortunately meant that
    the second time through we thought there was no change and skipped
    all kinds of work, despite the fact that there was indeed a change.
    
    I have fixed this the simplest way possible by restoring the changed
    values when we restart the sysctl write.
    
    One of my coworkers spotted this bug when after disabling forwarding
    on an interface pings were still forwarded.
    
    Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 040c4f0..26dec2b 100644
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
index de7a194..143791d 100644
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
@@ -4028,12 +4031,15 @@ int addrconf_sysctl_forward(ctl_table *ctl, int write,
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
 
@@ -4075,8 +4081,11 @@ static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int old)
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
@@ -4095,12 +4104,15 @@ int addrconf_sysctl_disable(ctl_table *ctl, int write,
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
 
