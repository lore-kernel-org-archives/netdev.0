From: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Subject: [PATCH iproute2] f_flower: don't set TCA_FLOWER_KEY_ETH_TYPE for
 "protocol all"
Date: Thu, 19 Jan 2017 16:51:59 -0500
Message-ID: <20170119215159.GA32126@nvt-d.home.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bcrl@kvack.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f179.google.com ([209.85.213.179]:35377 "EHLO
        mail-yb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751502AbdASVwD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 16:52:03 -0500
Received: by mail-yb0-f179.google.com with SMTP id l23so37908849ybj.2
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 13:52:03 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using the tc filter flower, rules marked with "protocol all" do not
actually match all packets.  This is due to a bug in f_flower.c that passes
in ETH_P_ALL in the TCA_FLOWER_KEY_ETH_TYPE attribute when adding a rule.
Fix this by omitting TCA_FLOWER_KEY_ETH_TYPE if the protocol is set to
ETH_P_ALL.
    
Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 1dbc532..1f90da3 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -527,11 +527,13 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 parse_done:
 	addattr32(n, MAX_MSG, TCA_FLOWER_FLAGS, flags);
 
-	ret = addattr16(n, MAX_MSG, TCA_FLOWER_KEY_ETH_TYPE, eth_type);
-	if (ret) {
-		fprintf(stderr, "Illegal \"eth_type\"(0x%x)\n",
-			ntohs(eth_type));
-		return -1;
+	if (eth_type != htons(ETH_P_ALL)) {
+		ret = addattr16(n, MAX_MSG, TCA_FLOWER_KEY_ETH_TYPE, eth_type);
+		if (ret) {
+			fprintf(stderr, "Illegal \"eth_type\"(0x%x)\n",
+				ntohs(eth_type));
+			return -1;
+		}
 	}
 
 	tail->rta_len = (((void *)n)+n->nlmsg_len) - (void *)tail;
