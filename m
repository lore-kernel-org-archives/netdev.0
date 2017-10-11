From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH net-next 2/2] net sched actions: fix module auto-loading
Date: Wed, 11 Oct 2017 10:50:30 -0400
Message-ID: <1507733430-17860-3-git-send-email-mrv@mojatatu.com>
References: <1507733430-17860-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:47261 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752242AbdJKOu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 10:50:58 -0400
Received: by mail-it0-f67.google.com with SMTP id p138so3326393itp.2
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 07:50:58 -0700 (PDT)
In-Reply-To: <1507733430-17860-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macro __stringify_1() can stringify a macro argument, however IFE_META_*
are enums, so they never expand, however request_module expects an integer
in IFE module name, so as a result it always fails to auto-load.

Fixes: ef6980b6becb ("introduce IFE action")
Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 net/sched/act_ife.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 791aeee..e0bc228 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -248,6 +248,20 @@ static int ife_validate_metatype(struct tcf_meta_ops *ops, void *val, int len)
 	return ret;
 }
 
+static const char *ife_meta_id2name(u32 metaid)
+{
+	switch (metaid) {
+	case IFE_META_SKBMARK:
+		return "skbmark";
+	case IFE_META_PRIO:
+		return "skbprio";
+	case IFE_META_TCINDEX:
+		return "tcindex";
+	default:
+		return "unknown";
+	}
+}
+
 /* called when adding new meta information
  * under ife->tcf_lock for existing action
 */
@@ -263,7 +277,7 @@ static int load_metaops_and_vet(struct tcf_ife_info *ife, u32 metaid,
 		if (exists)
 			spin_unlock_bh(&ife->tcf_lock);
 		rtnl_unlock();
-		request_module("ife-meta-%u", metaid);
+		request_module("ife-meta-%s", ife_meta_id2name(metaid));
 		rtnl_lock();
 		if (exists)
 			spin_lock_bh(&ife->tcf_lock);
-- 
1.9.1
