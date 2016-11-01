From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next v2] genetlink: fix error return code in genl_register_family()
Date: Tue,  1 Nov 2016 14:45:52 +0000
Message-ID: <1478011552-24957-1-git-send-email-weiyj.lk@gmail.com>
References: <1477925583-7956-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        Florian Westphal <fw@strlen.de>,
        Johannes Berg <johannes.berg@intel.com>,
        pravin shelar <pshelar@ovn.org>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Matti Vaittinen <matti.vaittinen@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36674 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034847AbcKAOqJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 10:46:09 -0400
Received: by mail-pf0-f195.google.com with SMTP id n85so11856121pfi.3
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 07:46:08 -0700 (PDT)
In-Reply-To: <1477925583-7956-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return a negative error code from the idr_alloc() error handling
case instead of 0, as done elsewhere in this function.

Also fix the return value check of idr_alloc() since idr_alloc return
negative errors on failure, not zero.

Fixes: 2ae0f17df1cd ("genetlink: use idr to track families")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
v1 -> v2: fix the return value check and return idr_alloc's err code
---
 net/netlink/genetlink.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index caf04d7..bbd3bff 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -362,8 +362,10 @@ int genl_register_family(struct genl_family *family)
 
 	family->id = idr_alloc(&genl_fam_idr, family,
 			       start, end + 1, GFP_KERNEL);
-	if (!family->id)
+	if (family->id < 0) {
+		err = family->id;
 		goto errout_locked;
+	}
 
 	err = genl_validate_assign_mc_groups(family);
 	if (err)
