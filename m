From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 15/17] ieee802154: add two nl802154 helpers
Date: Fri,  6 Nov 2009 15:39:39 +0300
Message-ID: <1257511181-19403-16-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:50133 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485AbZKFMlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:41:04 -0500
Received: by ewy3 with SMTP id 3so975933ewy.37
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:41:08 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two nl802154 helpers: one for starting a reply message, one for sending.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/ieee802154.h |    5 +++++
 net/ieee802154/netlink.c    |   33 +++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/ieee802154.h b/net/ieee802154/ieee802154.h
index 0790eb0..aadec42 100644
--- a/net/ieee802154/ieee802154.h
+++ b/net/ieee802154/ieee802154.h
@@ -38,8 +38,13 @@ void __exit ieee802154_nl_exit(void);
 		.dumpit	= _dump,			\
 	}
 
+struct genl_info;
+
 struct sk_buff *ieee802154_nl_create(int flags, u8 req);
 int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group);
+struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
+		int flags, u8 req);
+int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info);
 
 extern struct genl_family nl802154_family;
 int nl802154_mac_register(void);
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 8a22173..33137b9 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -75,6 +75,39 @@ out:
 	return -ENOBUFS;
 }
 
+struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
+		int flags, u8 req)
+{
+	void *hdr;
+	struct sk_buff *msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+
+	if (!msg)
+		return NULL;
+
+	hdr = genlmsg_put_reply(msg, info,
+			&nl802154_family, flags, req);
+	if (!hdr) {
+		nlmsg_free(msg);
+		return NULL;
+	}
+
+	return msg;
+}
+
+int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info)
+{
+	/* XXX: nlh is right at the start of msg */
+	void *hdr = genlmsg_data(NLMSG_DATA(msg->data));
+
+	if (genlmsg_end(msg, hdr) < 0)
+		goto out;
+
+	return genlmsg_reply(msg, info);
+out:
+	nlmsg_free(msg);
+	return -ENOBUFS;
+}
+
 int __init ieee802154_nl_init(void)
 {
 	int rc;
-- 
1.6.5

