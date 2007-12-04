From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 11/11][IPV6] Eliminate difference in actions of
 sysctl and proc handler for conf.all.forwarding
Date: Tue, 04 Dec 2007 13:19:12 +0300
Message-ID: <475529A0.4010300@openvz.org>
References: <4755256F.9000505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56132 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214AbXLDKTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 05:19:33 -0500
In-Reply-To: <4755256F.9000505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only difference in this case is that updating all.forwarding
causes the update in default.forwarding when done via proc, but
not via the system call.

Besides, this consolidates a good portion of code.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---


diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index dbff389..95cf3aa 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -476,6 +476,21 @@ static void addrconf_forward_change(void)
 	}
 	read_unlock(&dev_base_lock);
 }
+
+static void addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
+{
+	if (p == &ipv6_devconf_dflt.forwarding)
+		return;
+
+	if (p == &ipv6_devconf.forwarding) {
+		ipv6_devconf_dflt.forwarding = ipv6_devconf.forwarding;
+		addrconf_forward_change();
+	} else if ((!*p) ^ (!old))
+		dev_forward_change((struct inet6_dev *)table->extra1);
+
+	if (*p)
+		rt6_purge_dflt_routers();
+}
 #endif
 
 /* Nobody refers to this ifaddr, destroy it */
@@ -3771,22 +3786,8 @@ int addrconf_sysctl_forward(ctl_table *ctl, int write, struct file * filp,
 
 	ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
 
-	if (write && valp != &ipv6_devconf_dflt.forwarding) {
-		if (valp != &ipv6_devconf.forwarding) {
-			if ((!*valp) ^ (!val)) {
-				struct inet6_dev *idev = (struct inet6_dev *)ctl->extra1;
-				if (idev == NULL)
-					return ret;
-				dev_forward_change(idev);
-			}
-		} else {
-			ipv6_devconf_dflt.forwarding = ipv6_devconf.forwarding;
-			addrconf_forward_change();
-		}
-		if (*valp)
-			rt6_purge_dflt_routers();
-	}
-
+	if (write)
+		addrconf_fixup_forwarding(ctl, valp, val);
 	return ret;
 }
 
@@ -3797,6 +3798,7 @@ static int addrconf_sysctl_forward_strategy(ctl_table *table,
 					    void __user *newval, size_t newlen)
 {
 	int *valp = table->data;
+	int val = *valp;
 	int new;
 
 	if (!newval || !newlen)
@@ -3821,26 +3823,8 @@ static int addrconf_sysctl_forward_strategy(ctl_table *table,
 		}
 	}
 
-	if (valp != &ipv6_devconf_dflt.forwarding) {
-		if (valp != &ipv6_devconf.forwarding) {
-			struct inet6_dev *idev = (struct inet6_dev *)table->extra1;
-			int changed;
-			if (unlikely(idev == NULL))
-				return -ENODEV;
-			changed = (!*valp) ^ (!new);
-			*valp = new;
-			if (changed)
-				dev_forward_change(idev);
-		} else {
-			*valp = new;
-			addrconf_forward_change();
-		}
-
-		if (*valp)
-			rt6_purge_dflt_routers();
-	} else
-		*valp = new;
-
+	*valp = new;
+	addrconf_fixup_forwarding(table, valp, val);
 	return 1;
 }
 
-- 
1.5.3.4

