From: Xianpeng Zhao <xpzhao@aerohive.com>
Subject: [PATCH] When rtnl_trylock failed, wait a time to start another try;
 It can avoid the dead lock caused by the priority reverse
Date: Wed, 17 Feb 2016 07:50:12 +0000
Message-ID: <CY1PR11MB0491FD9134088601302F87B5AAAE0@CY1PR11MB0491.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0112.outbound.protection.outlook.com ([65.55.169.112]:4896
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756859AbcBQIXQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 03:23:16 -0500
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I have find a problem in my system, I found there have a chance that ca=
use the system enter dead loop when try to get the rtnl lock in the sys=
ctl function in net/ipv6/addrconf.c

=A0=A0=A0=A0=A0=A0=A0=A0 The situation should like this, there are 2 pr=
ocesses may need get the rtnl lock, we call them process A and process =
B, A have high priority than B.
B need get the rtnl lock to do something, when B schedule out without r=
elease the lock; At this time, the A start to run "echo 1 > /proc/sys/n=
et/ipv6/conf/<ifname>/disable_ipv6", the echo process will run to this =
code:

=A0=A0=A0 if (!rtnl_trylock())

=A0=A0=A0=A0=A0=A0=A0 return restart_syscall();

Because the rtnl lock was hold by process B, so here the try will be fa=
ilure, and run the restart_syscall to let the sys_write do again, even =
try many times, because the B have very lower priority, the lock was ha=
rd to be released, so the echo process created by A will enter a loop o=
f restart system call.

In my case it is the wireless_nlevent_process in process kworker taken =
the rtnl lock, and another higher priority process need use echo to dis=
able IPv6 met this problem.

I am not very sure, but I think it is better to let the process sleep a=
 while instead of try it again and again without any delay.

Expects, what's your opinions?

Signed-off-by: Xianpeng Zhao <xpzhao@aerohive.com>
---
 net/ipv6/addrconf.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 38eedde..f06a520 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -754,8 +754,10 @@ static int addrconf_fixup_forwarding(struct ctl_ta=
ble *table, int *p, int newf)
 	struct net *net;
 	int old;
=20
-	if (!rtnl_trylock())
+	if (!rtnl_trylock()) {
+		schedule_timeout_uninterruptible(1);
 		return restart_syscall();
+	}
=20
 	net =3D (struct net *)table->extra2;
 	old =3D *p;
@@ -811,8 +813,10 @@ static int addrconf_fixup_linkdown(struct ctl_tabl=
e *table, int *p, int newf)
 	struct net *net;
 	int old;
=20
-	if (!rtnl_trylock())
+	if (!rtnl_trylock()) {
+		schedule_timeout_uninterruptible(1);
 		return restart_syscall();
+	}
=20
 	net =3D (struct net *)table->extra2;
 	old =3D *p;
@@ -5304,8 +5308,10 @@ static int addrconf_disable_ipv6(struct ctl_tabl=
e *table, int *p, int newf)
 	struct net *net;
 	int old;
=20
-	if (!rtnl_trylock())
+	if (!rtnl_trylock()) {
+		schedule_timeout_uninterruptible(1);
 		return restart_syscall();
+	}
=20
 	net =3D (struct net *)table->extra2;
 	old =3D *p;
@@ -5367,8 +5373,10 @@ int addrconf_sysctl_proxy_ndp(struct ctl_table *=
ctl, int write,
 	if (write && old !=3D new) {
 		struct net *net =3D ctl->extra2;
=20
-		if (!rtnl_trylock())
+		if (!rtnl_trylock()) {
+			schedule_timeout_uninterruptible(1);
 			return restart_syscall();
+		}
=20
 		if (valp =3D=3D &net->ipv6.devconf_dflt->proxy_ndp)
 			inet6_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
@@ -5408,8 +5416,10 @@ static int addrconf_sysctl_stable_secret(struct =
ctl_table *ctl, int write,
 	lctl.maxlen =3D IPV6_MAX_STRLEN;
 	lctl.data =3D str;
=20
-	if (!rtnl_trylock())
+	if (!rtnl_trylock()) {
+		schedule_timeout_uninterruptible(1);
 		return restart_syscall();
+	}
=20
 	if (!write && !secret->initialized) {
 		err =3D -EIO;
--=20
1.7.1
