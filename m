From: Anoop Naravaram <anaravaram@google.com>
Subject: [PATCH 4/5] net: add dscp ranges to net cgroup
Date: Wed, 10 Aug 2016 17:53:17 -0700
Message-ID: <1470876798-4024-5-git-send-email-anaravaram@google.com>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
Cc: edumazet@google.com, maheshb@google.com, weiwan@google.com,
	tom@herbertland.com, Anoop Naravaram <anaravaram@google.com>
To: corbet@lwn.net, tj@kernel.org, lizefan@huawei.com,
	hannes@cmpxchg.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-doc@vger.kernel.org, cgroups@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34295 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbcHKA4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 20:56:22 -0400
Received: by mail-pa0-f53.google.com with SMTP id fi15so20530703pac.1
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 17:56:21 -0700 (PDT)
In-Reply-To: <1470876798-4024-1-git-send-email-anaravaram@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dscp ranges
----------
This property controls which dscp values the processes in a cgroup are
allowed to use. A process in a cgroup will receive an EACCES error if it
tries to do any of these things:
* set a socket's IP_TOS option to a value whose dscp field (bits 7:2) is
  outside the range
* use a socket to send a message in which the IP_TOS ancillary data is
  set to a value whose dscp field is outside the range

This property is exposed to userspace through the 'net.dscp_ranges' file,
similar to the bind and listen port ranges.

Tested: wrote python to attempt to setsockopt the IP_TOS option to a
value with an out-of-range dscp field, and expect a failure

Signed-off-by: Anoop Naravaram <anaravaram@google.com>
---
 Documentation/cgroup-v1/net.txt | 14 ++++++++++++++
 include/net/net_cgroup.h        |  6 ++++++
 net/core/net_cgroup.c           | 34 ++++++++++++++++++++++++++++++++--
 net/ipv4/ip_sockglue.c          | 13 +++++++++++++
 net/ipv6/datagram.c             |  9 +++++++++
 net/ipv6/ipv6_sockglue.c        |  8 ++++++++
 6 files changed, 82 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroup-v1/net.txt b/Documentation/cgroup-v1/net.txt
index a14fd1c..ea2f1db 100644
--- a/Documentation/cgroup-v1/net.txt
+++ b/Documentation/cgroup-v1/net.txt
@@ -30,6 +30,20 @@ This property is exposed to userspace through the 'net.listen_port_ranges' file,
 as ranges of ports that the processes can listen on (as described in the HOW TO
 INTERACT WITH RANGES FILES section).
 
+dscp ranges
+-----------
+This property controls which dscp values the processes in a cgroup are
+allowed to use. A process in a cgroup will receive an EACCES error if it
+tries to do any of these things:
+* set a socket's IP_TOS option to a value whose dscp field (bits 7:2) is
+  outside the range
+* use a socket to send a message in which the IP_TOS ancillary data is
+  set to a value whose dscp field is outside the range
+
+This property is exposed to userspace through the 'net.dscp_ranges' file, as
+ranges of dscp values that the process can use (as described in the HOW TO
+INTERACT WITH RANGES FILES section).
+
 udp port usage and limit
 ------------------------
 This property controls the limit of udp ports that can be used by the
diff --git a/include/net/net_cgroup.h b/include/net/net_cgroup.h
index 25a9def..d89e98d 100644
--- a/include/net/net_cgroup.h
+++ b/include/net/net_cgroup.h
@@ -23,6 +23,7 @@
 enum {
 	NETCG_LISTEN_RANGES,
 	NETCG_BIND_RANGES,
+	NETCG_DSCP_RANGES,
 	NETCG_NUM_RANGE_TYPES
 };
 
@@ -73,6 +74,7 @@ struct net_cgroup {
 
 bool net_cgroup_bind_allowed(u16 port);
 bool net_cgroup_listen_allowed(u16 port);
+bool net_cgroup_dscp_allowed(u8 dscp);
 bool net_cgroup_acquire_udp_port(void);
 void net_cgroup_release_udp_port(void);
 
@@ -85,6 +87,10 @@ static inline bool net_cgroup_listen_allowed(u16 port)
 {
 	return true;
 }
+static inline bool net_cgroup_dscp_allowed(u8 dscp)
+{
+	return true;
+}
 static inline bool net_cgroup_acquire_udp_port(void)
 {
 	return true;
diff --git a/net/core/net_cgroup.c b/net/core/net_cgroup.c
index 2f58e13..73dc5e7 100644
--- a/net/core/net_cgroup.c
+++ b/net/core/net_cgroup.c
@@ -21,6 +21,9 @@
 #define MIN_PORT_VALUE		0
 #define MAX_PORT_VALUE		65535
 
+#define MIN_DSCP_VALUE		0
+#define MAX_DSCP_VALUE		63
+
 /* Deriving MAX_ENTRIES from MAX_WRITE_SIZE as a rough estimate */
 #define MAX_ENTRIES ((MAX_WRITE_SIZE - offsetof(struct net_ranges, range)) /   \
 		     BYTES_PER_ENTRY)
@@ -161,7 +164,10 @@ cgrp_css_alloc(struct cgroup_subsys_state *parent_css)
 				MIN_PORT_VALUE, MAX_PORT_VALUE) ||
 		    alloc_init_net_ranges(
 				&netcg->whitelists[NETCG_LISTEN_RANGES],
-				MIN_PORT_VALUE, MAX_PORT_VALUE)) {
+				MIN_PORT_VALUE, MAX_PORT_VALUE) ||
+		    alloc_init_net_ranges(
+				&netcg->whitelists[NETCG_DSCP_RANGES],
+				MIN_DSCP_VALUE, MAX_DSCP_VALUE)) {
 			free_net_cgroup(netcg);
 			/* if any of these cause an error, return ENOMEM */
 			return ERR_PTR(-ENOMEM);
@@ -178,7 +184,11 @@ cgrp_css_alloc(struct cgroup_subsys_state *parent_css)
 		    alloc_copy_net_ranges(
 				&netcg->whitelists[NETCG_LISTEN_RANGES],
 				MIN_PORT_VALUE, MAX_PORT_VALUE,
-				&parent_netcg->whitelists[NETCG_LISTEN_RANGES])) {
+				&parent_netcg->whitelists[NETCG_LISTEN_RANGES]) ||
+		    alloc_copy_net_ranges(
+				&netcg->whitelists[NETCG_DSCP_RANGES],
+				MIN_DSCP_VALUE, MAX_DSCP_VALUE,
+				&parent_netcg->whitelists[NETCG_DSCP_RANGES])) {
 			free_net_cgroup(netcg);
 			/* if any of these cause an error, return ENOMEM */
 			return ERR_PTR(-ENOMEM);
@@ -237,6 +247,12 @@ bool net_cgroup_listen_allowed(u16 port)
 }
 EXPORT_SYMBOL_GPL(net_cgroup_listen_allowed);
 
+bool net_cgroup_dscp_allowed(u8 dscp)
+{
+	return net_cgroup_value_allowed(dscp, NETCG_DSCP_RANGES);
+}
+EXPORT_SYMBOL_GPL(net_cgroup_dscp_allowed);
+
 static s64 net_udp_read_s64(struct cgroup_subsys_state *css, struct cftype *cft)
 {
 	struct  net_cgroup *netcg = css_to_net_cgroup(css);
@@ -634,6 +650,20 @@ static struct cftype ss_files[] = {
 		.max_write_len	= MAX_WRITE_SIZE,
 	},
 	{
+		.name		= "dscp_ranges",
+		.flags		= CFTYPE_ONLY_ON_ROOT,
+		.seq_show	= net_read_ranges,
+		.private	= NETCG_DSCP_RANGES,
+	},
+	{
+		.name		= "dscp_ranges",
+		.flags		= CFTYPE_NOT_ON_ROOT,
+		.seq_show	= net_read_ranges,
+		.write		= net_write_ranges,
+		.private	= NETCG_DSCP_RANGES,
+		.max_write_len	= MAX_WRITE_SIZE,
+	},
+	{
 		.name		= "udp_limit",
 		.flags		= CFTYPE_ONLY_ON_ROOT,
 		.read_s64	= net_udp_read_s64,
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 71a52f4d..71a4297 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -42,6 +42,7 @@
 #include <net/transp_v6.h>
 #endif
 #include <net/ip_fib.h>
+#include <net/net_cgroup.h>
 
 #include <linux/errqueue.h>
 #include <asm/uaccess.h>
@@ -289,6 +290,11 @@ int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc,
 			val = *(int *)CMSG_DATA(cmsg);
 			if (val < 0 || val > 255)
 				return -EINVAL;
+			/* val is 8-bit tos, we need to rightshift 2 to get the
+			 * 6-bit dscp field
+			 */
+			if (!net_cgroup_dscp_allowed(val >> 2))
+				return -EACCES;
 			ipc->tos = val;
 			ipc->priority = rt_tos2priority(ipc->tos);
 			break;
@@ -727,6 +733,13 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			val &= ~INET_ECN_MASK;
 			val |= inet->tos & INET_ECN_MASK;
 		}
+		/* val is 8-bit tos, we need to rightshift 2 to get the
+		 * 6-bit dscp field
+		 */
+		if (!net_cgroup_dscp_allowed(val >> 2)) {
+			err = -EACCES;
+			break;
+		}
 		if (inet->tos != val) {
 			inet->tos = val;
 			sk->sk_priority = rt_tos2priority(val);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 37874e2..9053b83 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -34,6 +34,7 @@
 
 #include <linux/errqueue.h>
 #include <asm/uaccess.h>
+#include <net/net_cgroup.h>
 
 static bool ipv6_mapped_addr_any(const struct in6_addr *a)
 {
@@ -973,6 +974,14 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 			if (tc < -1 || tc > 0xff)
 				goto exit_f;
 
+			/* tc is 8-bit tclass, we need to rightshift 2 to get
+			 * the 6-bit dscp field
+			 */
+			if (!net_cgroup_dscp_allowed(tc >> 2)) {
+				err = -EACCES;
+				goto exit_f;
+			}
+
 			err = 0;
 			ipc6->tclass = tc;
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index a9895e1..eac3f88 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -52,6 +52,7 @@
 #include <net/udplite.h>
 #include <net/xfrm.h>
 #include <net/compat.h>
+#include <net/net_cgroup.h>
 
 #include <asm/uaccess.h>
 
@@ -339,6 +340,13 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		/* RFC 3542, 6.5: default traffic class of 0x0 */
 		if (val == -1)
 			val = 0;
+		/* val is 8-bit tclass, we need to rightshift 2 to get the 6-bit
+		 * dscp field
+		 */
+		if (!net_cgroup_dscp_allowed(val >> 2)) {
+			retv = -EACCES;
+			break;
+		}
 		np->tclass = val;
 		retv = 0;
 		break;
-- 
2.8.0.rc3.226.g39d4020
