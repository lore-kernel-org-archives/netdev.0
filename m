From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 1/7] bridge: Turn flag change macro into a function.
Date: Wed, 26 Feb 2014 10:18:19 -0500
Message-ID: <1393427905-6811-2-git-send-email-vyasevic@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	mst@redhat.com, jhs@mojatatu.com, john.r.fastabend@intel.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbaBZPSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Feb 2014 10:18:45 -0500
In-Reply-To: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn the flag change macro into a function to allow
easier updates and to reduce space.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_sysfs_if.c | 29 +++++++++++++++++++----------
 1 file changed, 19 insertions(+), 10 deletions(-)

diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index dd595bd..7f66aa4 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -25,6 +25,8 @@ struct brport_attribute {
 	ssize_t (*show)(struct net_bridge_port *, char *);
 	int (*store)(struct net_bridge_port *, unsigned long);
 };
+static int store_flag(struct net_bridge_port *p, unsigned long v,
+		     unsigned long mask);
 
 #define BRPORT_ATTR(_name, _mode, _show, _store)		\
 const struct brport_attribute brport_attr_##_name = { 	        \
@@ -41,20 +43,27 @@ static ssize_t show_##_name(struct net_bridge_port *p, char *buf) \
 }								\
 static int store_##_name(struct net_bridge_port *p, unsigned long v) \
 {								\
-	unsigned long flags = p->flags;				\
-	if (v)							\
-		flags |= _mask;					\
-	else							\
-		flags &= ~_mask;				\
-	if (flags != p->flags) {				\
-		p->flags = flags;				\
-		br_ifinfo_notify(RTM_NEWLINK, p);		\
-	}							\
-	return 0;						\
+	return store_flag(p, v, _mask);				\
 }								\
 static BRPORT_ATTR(_name, S_IRUGO | S_IWUSR,			\
 		   show_##_name, store_##_name)
 
+static int store_flag(struct net_bridge_port *p, unsigned long v,
+		     unsigned long mask)
+{
+	unsigned long flags = p->flags;
+
+	if (v)
+		flags |= mask;
+	else
+		flags &= ~mask;
+
+	if (flags != p->flags) {
+		p->flags = flags;
+		br_ifinfo_notify(RTM_NEWLINK, p);
+	}
+	return 0;
+}
 
 static ssize_t show_path_cost(struct net_bridge_port *p, char *buf)
 {
-- 
1.8.5.3
