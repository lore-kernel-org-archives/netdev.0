From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] bridge: prevent hairpin and STP problems?
Date: Fri, 14 Aug 2009 14:41:33 -0700
Message-ID: <20090814144133.34ac9d94@nehalam>
References: <0199E0D51A61344794750DC57738F58E6D6B0C70D9@GVW1118EXC.americas.hpqcorp.net>
	<20090813.162716.207478915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anna.fischer@hp.com, netdev@vger.kernel.org, ptcongdon@ucdavis.edu,
	evb@yahoogroups.com, bridge@lists.linux-foundation.org,
	kaber@trash.net, arnd@arndb.de, mike.dickson@hp.com,
	adobriyan@gmail.com, bridge@osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42339 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750962AbZHNVmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 17:42:45 -0400
In-Reply-To: <20090813.162716.207478915.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do we need to add this to block Spanning Tree from being enabled
with hairpin mode? I am not sure what the exact usage of hairpin
mode and if it is possible to create loops and get STP confusion.

For comment only, do not apply as is.


--- a/net/bridge/br_ioctl.c	2009-08-14 14:28:19.917690805 -0700
+++ b/net/bridge/br_ioctl.c	2009-08-14 14:29:54.078271361 -0700
@@ -259,8 +259,7 @@ static int old_dev_ioctl(struct net_devi
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		br_stp_set_enabled(br, args[1]);
-		return 0;
+		return br_stp_set_enabled(br, args[1]);
 
 	case BRCTL_SET_BRIDGE_PRIORITY:
 		if (!capable(CAP_NET_ADMIN))
--- a/net/bridge/br_stp_if.c	2009-08-14 14:24:30.022315573 -0700
+++ b/net/bridge/br_stp_if.c	2009-08-14 14:35:25.819566113 -0700
@@ -160,17 +160,26 @@ static void br_stp_stop(struct net_bridg
 	br->stp_enabled = BR_NO_STP;
 }
 
-void br_stp_set_enabled(struct net_bridge *br, unsigned long val)
+int br_stp_set_enabled(struct net_bridge *br, unsigned long val)
 {
 	ASSERT_RTNL();
 
 	if (val) {
+		struct net_bridge_port *p;
+		list_for_each_entry_rcu(p, &br->port_list, list) {
+			if (p->flags & BR_HAIRPIN_MODE)
+				return -EINVAL;
+		}
+
+
 		if (br->stp_enabled == BR_NO_STP)
 			br_stp_start(br);
 	} else {
 		if (br->stp_enabled != BR_NO_STP)
 			br_stp_stop(br);
 	}
+
+	return 0;
 }
 
 /* called under bridge lock */
--- a/net/bridge/br_sysfs_br.c	2009-08-14 14:24:36.874256194 -0700
+++ b/net/bridge/br_sysfs_br.c	2009-08-14 14:33:26.025441102 -0700
@@ -164,6 +164,7 @@ static ssize_t store_stp_state(struct de
 	struct net_bridge *br = to_bridge(d);
 	char *endp;
 	unsigned long val;
+	int ret;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -174,10 +175,11 @@ static ssize_t store_stp_state(struct de
 
 	if (!rtnl_trylock())
 		return restart_syscall();
-	br_stp_set_enabled(br, val);
+
+	ret = br_stp_set_enabled(br, val);
 	rtnl_unlock();
 
-	return len;
+	return (ret == 0) ? len : ret;
 }
 static DEVICE_ATTR(stp_state, S_IRUGO | S_IWUSR, show_stp_state,
 		   store_stp_state);
--- a/net/bridge/br_sysfs_if.c	2009-08-14 14:24:36.888356879 -0700
+++ b/net/bridge/br_sysfs_if.c	2009-08-14 14:34:55.339272738 -0700
@@ -150,10 +150,13 @@ static ssize_t show_hairpin_mode(struct 
 }
 static ssize_t store_hairpin_mode(struct net_bridge_port *p, unsigned long v)
 {
-	if (v)
+	if (!v)
+		p->flags &= ~BR_HAIRPIN_MODE;
+	else if (p->br->stp_enabled == BR_NO_STP)
 		p->flags |= BR_HAIRPIN_MODE;
 	else
-		p->flags &= ~BR_HAIRPIN_MODE;
+		return -EINVAL;
+
 	return 0;
 }
 static BRPORT_ATTR(hairpin_mode, S_IRUGO | S_IWUSR,
--- a/net/bridge/br_private.h	2009-08-14 14:34:05.263278817 -0700
+++ b/net/bridge/br_private.h	2009-08-14 14:34:15.717297908 -0700
@@ -218,7 +218,7 @@ extern void br_become_designated_port(st
 /* br_stp_if.c */
 extern void br_stp_enable_bridge(struct net_bridge *br);
 extern void br_stp_disable_bridge(struct net_bridge *br);
-extern void br_stp_set_enabled(struct net_bridge *br, unsigned long val);
+extern int br_stp_set_enabled(struct net_bridge *br, unsigned long val);
 extern void br_stp_enable_port(struct net_bridge_port *p);
 extern void br_stp_disable_port(struct net_bridge_port *p);
 extern void br_stp_recalculate_bridge_id(struct net_bridge *br);
