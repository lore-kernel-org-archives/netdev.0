From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 12/29] net: Add device lookups by net_ctx
Date: Wed,  4 Feb 2015 18:34:13 -0700
Message-ID: <1423100070-31848-13-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:59990 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756325AbbBEBgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:03 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so35415655iga.1
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:02 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For now it just uses the namespace so the _ctx versions mirror the
current ones. Later patch adds the vrf check.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netdevice.h |  3 +++
 net/core/dev.c            | 35 +++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 55a221fec12b..43bb40260bfa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2164,6 +2164,7 @@ struct net_device *__dev_get_by_flags(struct net *net, unsigned short flags,
 struct net_device *dev_get_by_name(struct net *net, const char *name);
 struct net_device *dev_get_by_name_rcu(struct net *net, const char *name);
 struct net_device *__dev_get_by_name(struct net *net, const char *name);
+struct net_device *__dev_get_by_name_ctx(struct net_ctx *ctx, const char *name);
 int dev_alloc_name(struct net_device *dev, const char *name);
 int dev_open(struct net_device *dev);
 int dev_close(struct net_device *dev);
@@ -2187,7 +2188,9 @@ int init_dummy_netdev(struct net_device *dev);
 
 struct net_device *dev_get_by_index(struct net *net, int ifindex);
 struct net_device *__dev_get_by_index(struct net *net, int ifindex);
+struct net_device *__dev_get_by_index_ctx(struct net_ctx *ctx, int ifindex);
 struct net_device *dev_get_by_index_rcu(struct net *net, int ifindex);
+struct net_device *dev_get_by_index_rcu_ctx(struct net_ctx *ctx, int ifindex);
 int netdev_get_name(struct net *net, char *name, int ifindex);
 int dev_restart(struct net_device *dev);
 int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 1d564d68e31a..624335140857 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -684,6 +684,14 @@ struct net_device *__dev_get_by_name(struct net *net, const char *name)
 }
 EXPORT_SYMBOL(__dev_get_by_name);
 
+struct net_device *__dev_get_by_name_ctx(struct net_ctx *ctx, const char *name)
+{
+	struct net_device *dev = __dev_get_by_name(ctx->net, name);
+
+	return dev;
+}
+EXPORT_SYMBOL(__dev_get_by_name_ctx);
+
 /**
  *	dev_get_by_name_rcu	- find a device by its name
  *	@net: the applicable net namespace
@@ -759,6 +767,14 @@ struct net_device *__dev_get_by_index(struct net *net, int ifindex)
 }
 EXPORT_SYMBOL(__dev_get_by_index);
 
+struct net_device *__dev_get_by_index_ctx(struct net_ctx *ctx, int ifindex)
+{
+	struct net_device *dev = __dev_get_by_index(ctx->net, ifindex);
+
+	return dev;
+}
+EXPORT_SYMBOL(__dev_get_by_index_ctx);
+
 /**
  *	dev_get_by_index_rcu - find a device by its ifindex
  *	@net: the applicable net namespace
@@ -783,6 +799,25 @@ struct net_device *dev_get_by_index_rcu(struct net *net, int ifindex)
 }
 EXPORT_SYMBOL(dev_get_by_index_rcu);
 
+/**
+ *	dev_get_by_index_rcu_ctx - find a device by its ifindex
+ *	@net_ctx: the applicable net context
+ *	@ifindex: index of device
+ *
+ *	Search for an interface by index. Returns %NULL if the device
+ *	is not found or a pointer to the device. The device has not
+ *	had its reference counter increased so the caller must be careful
+ *	about locking. The caller must hold RCU lock.
+ */
+
+struct net_device *dev_get_by_index_rcu_ctx(struct net_ctx *ctx, int ifindex)
+{
+	struct net_device *dev = dev_get_by_index_rcu(ctx->net, ifindex);
+
+	return dev;
+}
+EXPORT_SYMBOL(dev_get_by_index_rcu_ctx);
+
 
 /**
  *	dev_get_by_index - find a device by its ifindex
-- 
1.9.3 (Apple Git-50)
