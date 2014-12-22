From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 2/5] genetlink: pass only network namespace to genl_has_listeners()
Date: Mon, 22 Dec 2014 18:56:36 +0100
Message-ID: <1419270999-22165-3-git-send-email-johannes@sipsolutions.net>
References: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35032 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755485AbaLVR4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:56:46 -0500
In-Reply-To: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

There's no point to force the caller to know about the internal
genl_sock to use inside struct net, just have them pass the network
namespace. This doesn't really change code generation since it's
an inline, but makes the caller less magic - there's never any
reason to pass another socket.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h    | 4 ++--
 net/openvswitch/datapath.c | 3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index af10c2cf8a1d..38620da4aa7a 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -395,11 +395,11 @@ static inline int genl_set_err(struct genl_family *family, struct net *net,
 }
 
 static inline int genl_has_listeners(struct genl_family *family,
-				     struct sock *sk, unsigned int group)
+				     struct net *net, unsigned int group)
 {
 	if (WARN_ON_ONCE(group >= family->n_mcgrps))
 		return -EINVAL;
 	group = family->mcgrp_offset + group;
-	return netlink_has_listeners(sk, group);
+	return netlink_has_listeners(net->genl_sock, group);
 }
 #endif	/* __NET_GENERIC_NETLINK_H */
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 332b5a031739..4e9a5f035cbc 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -83,8 +83,7 @@ static bool ovs_must_notify(struct genl_family *family, struct genl_info *info,
 			    unsigned int group)
 {
 	return info->nlhdr->nlmsg_flags & NLM_F_ECHO ||
-	       genl_has_listeners(family, genl_info_net(info)->genl_sock,
-				  group);
+	       genl_has_listeners(family, genl_info_net(info), group);
 }
 
 static void ovs_notify(struct genl_family *family,
-- 
2.1.1
