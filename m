From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 10/12] [DCCP]: Remove unused and redundant validation functions
Date: Thu, 13 Dec 2007 13:06:03 -0200
Message-ID: <1197558365-31134-11-git-send-email-acme@redhat.com>
References: <1197558365-31134-1-git-send-email-acme@redhat.com>
 <1197558365-31134-2-git-send-email-acme@redhat.com>
 <1197558365-31134-3-git-send-email-acme@redhat.com>
 <1197558365-31134-4-git-send-email-acme@redhat.com>
 <1197558365-31134-5-git-send-email-acme@redhat.com>
 <1197558365-31134-6-git-send-email-acme@redhat.com>
 <1197558365-31134-7-git-send-email-acme@redhat.com>
 <1197558365-31134-8-git-send-email-acme@redhat.com>
 <1197558365-31134-9-git-send-email-acme@redhat.com>
 <1197558365-31134-10-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:3275 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761881AbXLMPGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 10:06:23 -0500
Received: by an-out-0708.google.com with SMTP id d31so185725and.103
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 07:06:23 -0800 (PST)
In-Reply-To: <1197558365-31134-10-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This removes two inlines which were both called in a single function only:

 1) dccp_feat_change() is always called with either DCCPO_CHANGE_L or DCCPO_CHANGE_R as argument
    * from dccp_set_socktopt_change() via do_dccp_setsockopt() with DCCP_SOCKOPT_CHANGE_R/L
    * from __dccp_feat_init() via dccp_feat_init() also with DCCP_SOCKOPT_CHANGE_R/L.

    Hence the dccp_feat_is_valid_type() is completely unnecessary and always returns true.

 2) Due to (1), the length test reduces to 'len >= 4', which in turn makes
    dccp_feat_is_valid_length() unnecessary.

Furthermore, the inline function dccp_feat_is_reserved() was unfolded,
since only called in a single place.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/feat.c |   12 ++++--------
 net/dccp/feat.h |   26 --------------------------
 2 files changed, 4 insertions(+), 34 deletions(-)

diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 5ebdd86..084744e 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -24,11 +24,7 @@ int dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
 
 	dccp_feat_debug(type, feature, *val);
 
-	if (!dccp_feat_is_valid_type(type)) {
-		DCCP_WARN("option type %d invalid in negotiation\n", type);
-		return 1;
-	}
-	if (!dccp_feat_is_valid_length(type, feature, len)) {
+	if (len > 3) {
 		DCCP_WARN("invalid length %d\n", len);
 		return 1;
 	}
@@ -637,12 +633,12 @@ const char *dccp_feat_name(const u8 feat)
 		[DCCPF_MIN_CSUM_COVER]	= "Min. Csum Coverage",
 		[DCCPF_DATA_CHECKSUM]	= "Send Data Checksum",
 	};
+	if (feat > DCCPF_DATA_CHECKSUM && feat < DCCPF_MIN_CCID_SPECIFIC)
+		return feature_names[DCCPF_RESERVED];
+
 	if (feat >= DCCPF_MIN_CCID_SPECIFIC)
 		return "CCID-specific";
 
-	if (dccp_feat_is_reserved(feat))
-		return feature_names[DCCPF_RESERVED];
-
 	return feature_names[feat];
 }
 
diff --git a/net/dccp/feat.h b/net/dccp/feat.h
index 177f7de..e272222 100644
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -14,32 +14,6 @@
 #include <linux/types.h>
 #include "dccp.h"
 
-static inline int dccp_feat_is_valid_length(u8 type, u8 feature, u8 len)
-{
-	/* sec. 6.1: Confirm has at least length 3,
-	 * sec. 6.2: Change  has at least length 4 */
-	if (len < 3)
-		return 1;
-	if (len < 4  && (type == DCCPO_CHANGE_L || type == DCCPO_CHANGE_R))
-		return 1;
-	/* XXX: add per-feature length validation (sec. 6.6.8) */
-	return 0;
-}
-
-static inline int dccp_feat_is_reserved(const u8 feat)
-{
-	return (feat > DCCPF_DATA_CHECKSUM &&
-		feat < DCCPF_MIN_CCID_SPECIFIC) ||
-		feat == DCCPF_RESERVED;
-}
-
-/* feature negotiation knows only these four option types (RFC 4340, sec. 6) */
-static inline int dccp_feat_is_valid_type(const u8 optnum)
-{
-	return optnum >= DCCPO_CHANGE_L && optnum <= DCCPO_CONFIRM_R;
-
-}
-
 #ifdef CONFIG_IP_DCCP_DEBUG
 extern const char *dccp_feat_typename(const u8 type);
 extern const char *dccp_feat_name(const u8 feat);
-- 
1.5.3.4

