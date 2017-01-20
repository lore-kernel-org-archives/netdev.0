From: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Subject: [PATCH v2 iproute2] f_flower: don't set TCA_FLOWER_KEY_ETH_TYPE for
 "protocol all"
Date: Fri, 20 Jan 2017 14:07:38 -0500
Message-ID: <20170120190738.GA17163@nvt-d.home.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
        bcrl@kvack.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:35198 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751497AbdATTHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 14:07:44 -0500
Received: by mail-it0-f54.google.com with SMTP id 203so26485993ith.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 11:07:43 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2 - update to address changes in 00697ca19ae3e1118f2af82c3b41ac4335fe918b.

When using the tc flower filter, rules marked with "protocol all" do not
actually match all packets.  This is due to a bug in f_flower.c that passes
in ETH_P_ALL in the TCA_FLOWER_KEY_ETH_TYPE attribute when adding a rule.
Fix this by omitting TCA_FLOWER_KEY_ETH_TYPE if the protocol is set to
ETH_P_ALL.
    
Fixes: 488b41d020fb ("tc: flower no need to specify the ethertype")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 314c2dd..145a856 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -529,9 +529,11 @@ parse_done:
 	if (ret)
 		return ret;
 
-	ret = addattr16(n, MAX_MSG, TCA_FLOWER_KEY_ETH_TYPE, eth_type);
-	if (ret)
-		return ret;
+	if (eth_type != htons(ETH_P_ALL)) {
+		ret = addattr16(n, MAX_MSG, TCA_FLOWER_KEY_ETH_TYPE, eth_type);
+		if (ret)
+			return ret;
+	}
 
 	tail->rta_len = (((void *)n)+n->nlmsg_len) - (void *)tail;
 
