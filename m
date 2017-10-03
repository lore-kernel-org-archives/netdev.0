From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] net: rtnetlink: fix info leak in RTM_GETSTATS call
Date: Tue,  3 Oct 2017 13:20:48 +0300
Message-ID: <1507026048-13734-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: keescook@chromium.org, dvyukov@google.com, andreyknvl@google.com,
        kcc@google.com, roopa@cumulusnetworks.com, glider@google.com,
        davem@davemloft.net, edumazet@google.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:49935 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdJCKWV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 06:22:21 -0400
Received: by mail-wm0-f42.google.com with SMTP id b189so11757538wmd.4
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 03:22:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When RTM_GETSTATS was added the fields of its header struct were not all
initialized when returning the result thus leaking 4 bytes of information
to user-space per rtnl_fill_statsinfo call, so initialize them now. Thanks
to Alexander Potapenko for the detailed report and bisection.

Reported-by: Alexander Potapenko <glider@google.com>
Fixes: 10c9ead9f3c6 ("rtnetlink: add new RTM_GETSTATS message to dump link stats")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/core/rtnetlink.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a78fd61da0ec..d4bcdcc68e92 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3854,6 +3854,9 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 		return -EMSGSIZE;
 
 	ifsm = nlmsg_data(nlh);
+	ifsm->family = PF_UNSPEC;
+	ifsm->pad1 = 0;
+	ifsm->pad2 = 0;
 	ifsm->ifindex = dev->ifindex;
 	ifsm->filter_mask = filter_mask;
 
-- 
2.1.4
