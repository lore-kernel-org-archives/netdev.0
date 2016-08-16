From: Andrew Yourtchenko <ayourtch@gmail.com>
Subject: [PATCH 2/2] ipv6: fixup RTF_* flags when restoring RTPROT_RA route from rtnetlink
Date: Tue, 16 Aug 2016 15:59:03 +0200
Message-ID: <1471355943-21288-3-git-send-email-ayourtch@gmail.com>
References: <1471355943-21288-1-git-send-email-ayourtch@gmail.com>
Cc: Andrew Yourtchenko <ayourtch@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33700 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753494AbcHPN70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 09:59:26 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so16645800wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 06:59:24 -0700 (PDT)
In-Reply-To: <1471355943-21288-1-git-send-email-ayourtch@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the flags for RA-derived routes that were saved
via "ip -6 route save" and and subsequently restored via
"ip -6 route restore", allowing the incoming router advertisements
to update them, rather than complain about inability to do so.

Upon the restore of RA-derived saved routes, set the RTF_ADDRCONF
to indicate that the source of the route was originally
a router advertisement, and set the RTF_DEFAULT or RTF_ROUTEINFO
flag depending on prefix length. This can be considered a
sister change of f0396f60d7c165018c9b203fb9b89fb224835578, in
the other direction.

Signed-off-by: Andrew Yourtchenko <ayourtch@gmail.com>
---
 net/ipv6/route.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index dc37017..4da7237 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2769,6 +2769,16 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	cfg->fc_protocol = rtm->rtm_protocol;
 	cfg->fc_type = rtm->rtm_type;
 
+	if (rtm->rtm_protocol == RTPROT_RA) {
+	    /* RA-derived route: set flags accordingly. */
+	    cfg->fc_flags |= RTF_ADDRCONF;
+	    if (rtm->rtm_dst_len == 0) {
+		cfg->fc_flags |= RTF_DEFAULT;
+	    } else {
+		cfg->fc_flags |= RTF_ROUTEINFO;
+	    }
+	}
+
 	if (rtm->rtm_type == RTN_UNREACHABLE ||
 	    rtm->rtm_type == RTN_BLACKHOLE ||
 	    rtm->rtm_type == RTN_PROHIBIT ||
-- 
2.7.4
