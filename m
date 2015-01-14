From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Wed, 14 Jan 2015 12:17:19 -0700
Message-ID: <1421263039-96198-1-git-send-email-dsahern@gmail.com>
Cc: hannes@redhat.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:39411 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbbANTR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 14:17:26 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so11458604pdi.3
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 11:17:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, ipv6 addresses are flushed when the interface is configured down:

[root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
[root@f20 ~]# ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
    inet6 2000:11:1:1::1/64 scope global tentative
       valid_lft forever preferred_lft forever
[root@f20 ~]# ip link set dev eth1 up
[root@f20 ~]# ip link set dev eth1 down
[root@f20 ~]# ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
    link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff

Add a new sysctl to make this behavior optional. Setting defaults to flush
addresses to maintain backwards compatibility. When reset flushing is bypassed:

[root@f20 ~]# echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_down
[root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
[root@f20 ~]# ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
    link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
    inet6 2000:11:1:1::1/64 scope global tentative
       valid_lft forever preferred_lft forever
[root@f20 ~]#  ip link set dev eth1 up
[root@f20 ~]#  ip link set dev eth1 down
[root@f20 ~]# ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
    link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
    inet6 2000:11:1:1::1/64 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::4:11ff:fe22:3301/64 scope link
       valid_lft forever preferred_lft forever

Suggested-by: Hannes Frederic Sowa <hannes@redhat.com>
Signed-off-by: David Ahern <dsahern@gmail.com>
Cc: Hannes Frederic Sowa <hannes@redhat.com>
---
 include/linux/ipv6.h      |  1 +
 include/uapi/linux/ipv6.h |  1 +
 net/ipv6/addrconf.c       | 15 +++++++++++++++
 3 files changed, 17 insertions(+)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index c694e7baa621..1d726e39f09f 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -52,6 +52,7 @@ struct ipv6_devconf {
 	__s32		force_tllao;
 	__s32           ndisc_notify;
 	__s32		suppress_frag_ndisc;
+	__s32		flush_addr_on_down;
 	void		*sysctl;
 };
 
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index e863d088b9a5..c7cb79e0f0fe 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -165,6 +165,7 @@ enum {
 	DEVCONF_SUPPRESS_FRAG_NDISC,
 	DEVCONF_ACCEPT_RA_FROM_LOCAL,
 	DEVCONF_USE_OPTIMISTIC,
+	DEVCONF_FLUSH_ON_DOWN,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f7c8bbeb27b7..5c0d49073cb1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -201,6 +201,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
 	.suppress_frag_ndisc	= 1,
+	.flush_addr_on_down	= 1,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -238,6 +239,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
 	.suppress_frag_ndisc	= 1,
+	.flush_addr_on_down	= 1,
 };
 
 /* Check if a valid qdisc is available */
@@ -3083,6 +3085,9 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	if (how && del_timer(&idev->regen_timer))
 		in6_dev_put(idev);
 
+	if (!how && !idev->cnf.flush_addr_on_down)
+		goto unlock;
+
 	/* Step 3: clear tempaddr list */
 	while (!list_empty(&idev->tempaddr_list)) {
 		ifa = list_first_entry(&idev->tempaddr_list,
@@ -3123,6 +3128,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		write_lock_bh(&idev->lock);
 	}
 
+unlock:
 	write_unlock_bh(&idev->lock);
 
 	/* Step 5: Discard anycast and multicast list */
@@ -4376,6 +4382,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_NDISC_NOTIFY] = cnf->ndisc_notify;
 	array[DEVCONF_SUPPRESS_FRAG_NDISC] = cnf->suppress_frag_ndisc;
 	array[DEVCONF_ACCEPT_RA_FROM_LOCAL] = cnf->accept_ra_from_local;
+	array[DEVCONF_FLUSH_ON_DOWN] = cnf->flush_addr_on_down;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5253,6 +5260,14 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec,
 		},
 		{
+			.procname       = "flush_addr_on_down",
+			.data           = &ipv6_devconf.flush_addr_on_down,
+			.maxlen         = sizeof(int),
+			.mode           = 0644,
+			.proc_handler   = proc_dointvec,
+
+		},
+		{
 			/* sentinel */
 		}
 	},
-- 
1.9.3 (Apple Git-50)
