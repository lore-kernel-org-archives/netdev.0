From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] flow_dissector: Fix GRE header error path
Date: Mon,  6 Mar 2017 16:39:53 +0100
Message-ID: <1488814795-5152-4-git-send-email-jiri@resnulli.us>
References: <1488814795-5152-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, tom@herbertland.com,
        simon.horman@netronome.com, eric.dumazet@gmail.com,
        dinan.gunawardena@netronome.com, hadarh@mellanox.com, e@erig.me,
        fgao@ikuai8.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36608 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932105AbdCFPkI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 10:40:08 -0500
Received: by mail-wr0-f193.google.com with SMTP id l37so22186427wrc.3
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 07:40:07 -0800 (PST)
In-Reply-To: <1488814795-5152-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Now, when an unexpected element in the GRE header appears, we break so
the l4 ports are processed. But since the ports are processed
unconditionally, there will be certainly random values dissected. Fix
this by just bailing out in such situations.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/flow_dissector.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 8d01298..cefaf23 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -479,18 +479,18 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 
 		/* Only look inside GRE without routing */
 		if (hdr->flags & GRE_ROUTING)
-			break;
+			goto out_good;
 
 		/* Only look inside GRE for version 0 and 1 */
 		gre_ver = ntohs(hdr->flags & GRE_VERSION);
 		if (gre_ver > 1)
-			break;
+			goto out_good;
 
 		proto = hdr->protocol;
 		if (gre_ver) {
 			/* Version1 must be PPTP, and check the flags */
 			if (!(proto == GRE_PROTO_PPP && (hdr->flags & GRE_KEY)))
-				break;
+				goto out_good;
 		}
 
 		offset += sizeof(struct gre_base_hdr);
-- 
2.7.4
