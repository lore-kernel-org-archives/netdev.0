From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net-next 2/6] bridge: make flags sysfs interface a little bit more extensible
Date: Fri, 19 Apr 2013 16:52:46 -0400
Message-ID: <1366404770-28523-3-git-send-email-vyasevic@redhat.com>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754583Ab3DSUw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 16:52:56 -0400
In-Reply-To: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some changes of the flags may need to trigger additional actions.
Make the flag change function generic and have the per-attribute
function call that.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_sysfs_if.c |   39 ++++++++++++++++++++++++++++-----------
 1 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 1f28cd4..606362c 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -25,6 +25,10 @@ struct brport_attribute {
 	ssize_t (*show)(struct net_bridge_port *, char *);
 	int (*store)(struct net_bridge_port *, unsigned long);
 };
+static ssize_t show_flag(struct net_bridge_port *p, char *buf,
+			  unsigned long mask);
+static int store_flag(struct net_bridge_port *p, unsigned long v,
+		     unsigned long mask);
 
 #define BRPORT_ATTR(_name,_mode,_show,_store)		        \
 const struct brport_attribute brport_attr_##_name = { 	        \
@@ -37,24 +41,37 @@ const struct brport_attribute brport_attr_##_name = { 	        \
 #define BRPORT_ATTR_FLAG(_name, _mask)				\
 static ssize_t show_##_name(struct net_bridge_port *p, char *buf) \
 {								\
-	return sprintf(buf, "%d\n", !!(p->flags & _mask));	\
+	return show_flag(p, buf, _mask);			\
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
 
+static ssize_t show_flag(struct net_bridge_port *p, char *buf,
+			  unsigned long mask)
+{
+	return sprintf(buf, "%d\n", !!(p->flags & mask));
+}
+
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
1.7.7.6
