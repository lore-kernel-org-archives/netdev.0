From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [git pull] VFS patches, the first series
Date: Sat, 23 Aug 2008 08:24:13 +0100
Message-ID: <20080823072413.GJ28946@ZenIV.linux.org.uk>
References: <20080727012212.GW28946@ZenIV.linux.org.uk> <m1d4k2zui4.fsf@frodo.ebiederm.org> <m1od3mthma.fsf@frodo.ebiederm.org> <m1iqttnc7a.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35043 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbYHWHYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 03:24:18 -0400
Content-Disposition: inline
In-Reply-To: <m1iqttnc7a.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 05:08:25PM -0700, Eric W. Biederman wrote:

> Ok.  The situation is now clear.
> 
> /proc/sys/net/ipv4/neigh/default does not currently exist in network
> namespaces.    This looks like an oversight.
> 
> In my network namespace I have the interfaces lo, sit, veth0
> 
> We have the result that /proc/sys/net/ipv4/neigh/veth0 has /proc/sys/net/ipv4/neigh/lo.
> 
> lo gets unregistered before veth0 when we bring the network namespaces down.
> Then when veth gets unregistered we have a problem.
> 
> I'm not certain what to do about it.

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 16fc6f4..d3c156e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3054,14 +3054,23 @@ static ctl_table ipv4_route_table[] = {
 	{ .ctl_name = 0 }
 };
 
-static __net_initdata struct ctl_path ipv4_route_path[] = {
+static struct ctl_table empty[1];
+
+static struct ctl_table ipv4_skeleton[] =
+{
+	{ .procname = "route", .ctl_name = NET_IPV4_ROUTE,
+	  .child = ipv4_route_table},
+	{ .procname = "neigh", .ctl_name = NET_IPV4_NEIGH,
+	  .child = empty},
+	{ }
+};
+
+static __net_initdata struct ctl_path ipv4_path[] = {
 	{ .procname = "net", .ctl_name = CTL_NET, },
 	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
-	{ .procname = "route", .ctl_name = NET_IPV4_ROUTE, },
 	{ },
 };
 
-
 static struct ctl_table ipv4_route_flush_table[] = {
 	{
 		.ctl_name 	= NET_IPV4_ROUTE_FLUSH,
@@ -3074,6 +3083,13 @@ static struct ctl_table ipv4_route_flush_table[] = {
 	{ .ctl_name = 0 },
 };
 
+static __net_initdata struct ctl_path ipv4_route_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
+	{ .procname = "route", .ctl_name = NET_IPV4_ROUTE, },
+	{ },
+};
+
 static __net_init int sysctl_route_net_init(struct net *net)
 {
 	struct ctl_table *tbl;
@@ -3223,7 +3239,7 @@ int __init ip_rt_init(void)
  */
 void __init ip_static_sysctl_init(void)
 {
-	register_sysctl_paths(ipv4_route_path, ipv4_route_table);
+	register_sysctl_paths(ipv4_path, ipv4_skeleton);
 }
 #endif
 
