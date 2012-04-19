From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 13/19] net decnet:  Convert to use register_net_sysctl
Date: Thu, 19 Apr 2012 16:40:37 -0700
Message-ID: <m17gxbffyi.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49238 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520Ab2DSXgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:36:36 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Using an ascii path to register_net_sysctl as opposed to the slightly
awkward ctl_path allows for much simpler code.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/decnet/dn_dev.c            |   19 ++++---------------
 net/decnet/sysctl_net_decnet.c |    8 +-------
 2 files changed, 5 insertions(+), 22 deletions(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index ce8a184..f3924ab 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -209,15 +209,7 @@ static void dn_dev_sysctl_register(struct net_device *dev, struct dn_dev_parms *
 	struct dn_dev_sysctl_table *t;
 	int i;
 
-#define DN_CTL_PATH_DEV	3
-
-	struct ctl_path dn_ctl_path[] = {
-		{ .procname = "net",  },
-		{ .procname = "decnet",  },
-		{ .procname = "conf",  },
-		{ /* to be set */ },
-		{ },
-	};
+	char path[sizeof("net/decnet/conf/") + IFNAMSIZ];
 
 	t = kmemdup(&dn_dev_sysctl, sizeof(*t), GFP_KERNEL);
 	if (t == NULL)
@@ -228,15 +220,12 @@ static void dn_dev_sysctl_register(struct net_device *dev, struct dn_dev_parms *
 		t->dn_dev_vars[i].data = ((char *)parms) + offset;
 	}
 
-	if (dev) {
-		dn_ctl_path[DN_CTL_PATH_DEV].procname = dev->name;
-	} else {
-		dn_ctl_path[DN_CTL_PATH_DEV].procname = parms->name;
-	}
+	snprintf(path, sizeof(path), "net/decnet/conf/%s",
+		dev? dev->name : parms->name);
 
 	t->dn_dev_vars[0].extra1 = (void *)dev;
 
-	t->sysctl_header = register_net_sysctl_table(&init_net, dn_ctl_path, t->dn_dev_vars);
+	t->sysctl_header = register_net_sysctl(&init_net, path, t->dn_dev_vars);
 	if (t->sysctl_header == NULL)
 		kfree(t);
 	else
diff --git a/net/decnet/sysctl_net_decnet.c b/net/decnet/sysctl_net_decnet.c
index 4380b8e..a55eecc 100644
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -351,15 +351,9 @@ static ctl_table dn_table[] = {
 	{ }
 };
 
-static struct ctl_path dn_path[] = {
-	{ .procname = "net", },
-	{ .procname = "decnet", },
-	{ }
-};
-
 void dn_register_sysctl(void)
 {
-	dn_table_header = register_net_sysctl_table(&init_net, dn_path, dn_table);
+	dn_table_header = register_net_sysctl(&init_net, "net/decnet", dn_table);
 }
 
 void dn_unregister_sysctl(void)
-- 
1.7.2.5
