From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 09/12] openvswitch: Add key_attrs to struct sw_flow_match
Date: Wed, 28 Sep 2016 14:42:59 +0200
Message-ID: <1475066582-1971-10-git-send-email-simon.horman@netronome.com>
References: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37676 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932366AbcI1MnV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:43:21 -0400
Received: by mail-wm0-f46.google.com with SMTP id b130so69647047wmc.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:43:20 -0700 (PDT)
In-Reply-To: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is in preparation for using key_attrs outside of their current context
to allow quickly checking which attributes are set. This is in turn in
preparation for prototyping programming Open vSwitch (-like) flows into
hardware.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/openvswitch/flow.h         |  1 +
 net/openvswitch/flow_netlink.c | 14 +++++++++-----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 0c70c3532469..eb6bb7908e2d 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -72,6 +72,7 @@ struct sw_flow_match {
 	struct sw_flow_key *key;
 	struct sw_flow_key_range range;
 	struct sw_flow_mask *mask;
+	u64 key_attrs;
 };
 
 #define MAX_UFID_LENGTH 16 /* 128 bits */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index ae25ded82b3b..89c20bdc2cc7 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -121,10 +121,13 @@ static void update_range(struct sw_flow_match *match,
 	} while (0)
 
 static bool match_validate(const struct sw_flow_match *match,
-			   u64 key_attrs, u64 mask_attrs, bool log)
+			   u64 mask_attrs, bool log)
 {
 	u64 key_expected = 1 << OVS_KEY_ATTR_ETHERNET;
-	u64 mask_allowed = key_attrs;  /* At most allow all key attributes */
+	u64 mask_allowed;
+
+	/* At most allow all key attributes */
+	mask_allowed = match->key_attrs;
 
 	/* The following mask attributes allowed only if they
 	 * pass the validation tests. */
@@ -237,10 +240,10 @@ static bool match_validate(const struct sw_flow_match *match,
 		}
 	}
 
-	if ((key_attrs & key_expected) != key_expected) {
+	if ((match->key_attrs & key_expected) != key_expected) {
 		/* Key attributes check failed. */
 		OVS_NLERR(log, "Missing key (keys=%llx, expected=%llx)",
-			  (unsigned long long)key_attrs,
+			  (unsigned long long)match->key_attrs,
 			  (unsigned long long)key_expected);
 		return false;
 	}
@@ -1399,7 +1402,8 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 			goto free_newmask;
 	}
 
-	if (!match_validate(match, key_attrs, mask_attrs, log))
+	match->key_attrs = key_attrs;
+	if (!match_validate(match, mask_attrs, log))
 		err = -EINVAL;
 
 free_newmask:
-- 
2.7.0.rc3.207.g0ac5344
