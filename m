From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] mpls: fix mpls_net_init memory leak
Date: Mon, 31 Aug 2015 10:44:19 -0700
Message-ID: <1441043059-11984-1-git-send-email-razor@blackwall.org>
Cc: ebiederm@xmission.com, roopa@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35154 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755AbbHaRom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 13:44:42 -0400
Received: by pacdd16 with SMTP id dd16so146056302pac.2
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 10:44:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Fix a memory leak in the mpls netns init function in case of failure. If
register_net_sysctl fails then we need to free the ctl_table.

Fixes: 7720c01f3f59 ("mpls: Add a sysctl to control the size of the mpls label table")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 1f93a5978f2a..b1faa2dc0e6a 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1066,8 +1066,10 @@ static int mpls_net_init(struct net *net)
 
 	table[0].data = net;
 	net->mpls.ctl = register_net_sysctl(net, "net/mpls", table);
-	if (net->mpls.ctl == NULL)
+	if (net->mpls.ctl == NULL) {
+		kfree(table);
 		return -ENOMEM;
+	}
 
 	return 0;
 }
-- 
2.4.3
