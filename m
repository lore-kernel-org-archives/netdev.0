From: Christoph Lameter <cl@linux.com>
Subject: [PATCH] Multicast: Avoid useless duplication of multicast messages
Date: Tue, 14 Apr 2009 14:48:48 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904141447310.30596@qirst.com>
References: <alpine.DEB.1.10.0904131704120.3517@qirst.com> <20090414132551.GC14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904140946130.5712@qirst.com> <20090414182731.GD14305@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:33826 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756019AbZDNSzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 14:55:32 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CF73682C4B9
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 15:05:12 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7Eks3ohWgfbn for <netdev@vger.kernel.org>;
	Tue, 14 Apr 2009 15:05:08 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3106082C4A9
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 15:05:08 -0400 (EDT)
In-Reply-To: <20090414182731.GD14305@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil: Could you test this?


Subject: Multicast: Avoid useless duplication of multicast messages

If two processes open the same port as a multicast socket and then
join two different multicast groups then traffic for both multicast groups
is forwarded to either process. This means that application will get surprising
data that they did not ask for. Applications will have to filter these out in
order to work correctly if multiple apps run on the same system.

These are pretty strange semantics but they have been around since the
beginning of multicast support on Unix systems.

Add an option

	igmp_mc_socket_based_filtering

that is off by default so that the default behavior stays as is.

If one wants to have sane multicast behavior for the above case
then this option can be set. Thereupon applications will not get
additional traffic forwarded to them if they happen to run on a host
where another application also receives multicast traffic from a
different multicast group.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 Documentation/networking/ip-sysctl.txt |   10 ++++++++++
 include/linux/igmp.h                   |    1 +
 include/linux/sysctl.h                 |    1 +
 net/ipv4/igmp.c                        |    6 +++---
 net/ipv4/sysctl_net_ipv4.c             |    8 ++++++++
 5 files changed, 23 insertions(+), 3 deletions(-)

Index: linux-2.6/net/ipv4/igmp.c
===================================================================
--- linux-2.6.orig/net/ipv4/igmp.c	2009-04-14 13:03:14.000000000 -0500
+++ linux-2.6/net/ipv4/igmp.c	2009-04-14 13:11:38.000000000 -0500
@@ -1419,7 +1419,7 @@ static struct in_device *ip_mc_find_dev(
  */
 int sysctl_igmp_max_memberships __read_mostly = IP_MAX_MEMBERSHIPS;
 int sysctl_igmp_max_msf __read_mostly = IP_MAX_MSF;
-
+int sysctl_igmp_mc_socket_based_filtering = 0;

 static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,
 	__be32 *psfsrc)
@@ -2187,7 +2187,7 @@ int ip_mc_sf_allow(struct sock *sk, __be
 	struct ip_sf_socklist *psl;
 	int i;

-	if (!ipv4_is_multicast(loc_addr))
+	if (ipv4_is_lbcast(loc_addr) || !ipv4_is_multicast(loc_addr))
 		return 1;

 	for (pmc=inet->mc_list; pmc; pmc=pmc->next) {
@@ -2196,7 +2196,7 @@ int ip_mc_sf_allow(struct sock *sk, __be
 			break;
 	}
 	if (!pmc)
-		return 1;
+		return !sysctl_igmp_mc_socket_based_filtering;
 	psl = pmc->sflist;
 	if (!psl)
 		return pmc->sfmode == MCAST_EXCLUDE;
Index: linux-2.6/include/linux/igmp.h
===================================================================
--- linux-2.6.orig/include/linux/igmp.h	2009-04-14 13:13:14.000000000 -0500
+++ linux-2.6/include/linux/igmp.h	2009-04-14 13:41:14.000000000 -0500
@@ -150,6 +150,7 @@ static inline struct igmpv3_query *

 extern int sysctl_igmp_max_memberships;
 extern int sysctl_igmp_max_msf;
+extern int sysctl_igmp_mc_socket_based_filtering;

 struct ip_sf_socklist
 {
Index: linux-2.6/include/linux/sysctl.h
===================================================================
--- linux-2.6.orig/include/linux/sysctl.h	2009-04-14 13:15:57.000000000 -0500
+++ linux-2.6/include/linux/sysctl.h	2009-04-14 13:16:49.000000000 -0500
@@ -435,6 +435,7 @@ enum
 	NET_TCP_ALLOWED_CONG_CONTROL=123,
 	NET_TCP_MAX_SSTHRESH=124,
 	NET_TCP_FRTO_RESPONSE=125,
+	NET_IPV4_IGMP_MC_SOCKET_BASED_FILTERING=126,
 };

 enum {
Index: linux-2.6/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- linux-2.6.orig/net/ipv4/sysctl_net_ipv4.c	2009-04-14 13:13:53.000000000 -0500
+++ linux-2.6/net/ipv4/sysctl_net_ipv4.c	2009-04-14 13:15:44.000000000 -0500
@@ -408,6 +408,14 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.ctl_name	= NET_IPV4_IGMP_MC_SOCKET_BASED_FILTERING,
+		.procname	= "igmp_mc_socked_based_filtering",
+		.data		= &sysctl_igmp_mc_socket_based_filtering,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},

 #endif
 	{
Index: linux-2.6/Documentation/networking/ip-sysctl.txt
===================================================================
--- linux-2.6.orig/Documentation/networking/ip-sysctl.txt	2009-04-14 13:48:09.000000000 -0500
+++ linux-2.6/Documentation/networking/ip-sysctl.txt	2009-04-14 13:53:10.000000000 -0500
@@ -611,6 +611,16 @@ igmp_max_memberships - INTEGER
 	Change the maximum number of multicast groups we can subscribe to.
 	Default: 20

+igmp_mc_socket_based_filtering - INTEGER
+	Use the list of subscribed multicast addresses to filter the traffic
+	going to a multicast socket. If set to zero then multicast traffic
+        is forwarded to any socket subscribed to a port number ignoring the
+        list of multicast groups that a socket has been subscribed to. This mode
+        is the default since it has been done that way in the past.
+	If set to one then only multicast traffic of the multicast groups
+        that a socket has joined are forwarded to the socket.
+	Default: 0
+
 conf/interface/*  changes special settings per interface (where "interface" is
 		  the name of your network interface)
 conf/all/*	  is special, changes the settings for all interfaces
