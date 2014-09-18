From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC repost 2/8] netlink: Allow suppression of warnings for duplicate attributes
Date: Thu, 18 Sep 2014 10:55:05 +0900
Message-ID: <1411005311-11752-3-git-send-email-simon.horman@netronome.com>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:40470 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757052AbaIRB5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 21:57:41 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so353148pab.4
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 18:57:40 -0700 (PDT)
In-Reply-To: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a multiple field to struct nl_policy which if set suppresses
warning of duplicate attributes in nl_parse_nested().

As is the case without this patch only the last occurrence of an
attribute is stored in attrs by nl_parse_nested(). As such
if the multiple field of struct nl_policy is set then it
is up to the caller to parse the message to extract all the attributes.

This is in preparation for allowing multiple OVS_SELECT_GROUP_ATTR_BUCKET
attributes in a nested OVS_ACTION_ATTR_SELECT_GROUP attribute.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 lib/netlink.c | 2 +-
 lib/netlink.h | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/netlink.c b/lib/netlink.c
index 24b2168..bc30248 100644
--- a/lib/netlink.c
+++ b/lib/netlink.c
@@ -743,7 +743,7 @@ nl_policy_parse(const struct ofpbuf *msg, size_t nla_offset,
             if (!nl_attr_validate(nla, e)) {
                 return false;
             }
-            if (attrs[type]) {
+            if (attrs[type] && !e->multiple) {
                 VLOG_DBG_RL(&rl, "duplicate attr %"PRIu16, type);
             }
             attrs[type] = nla;
diff --git a/lib/netlink.h b/lib/netlink.h
index f9234da..b0a72fd 100644
--- a/lib/netlink.h
+++ b/lib/netlink.h
@@ -195,6 +195,7 @@ struct nl_policy
     enum nl_attr_type type;
     size_t min_len, max_len;
     bool optional;
+    bool multiple;
 };
 
 #define NL_POLICY_FOR(TYPE) \
-- 
2.0.1
