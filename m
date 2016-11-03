From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] genetlink: fix a memory leak on error path
Date: Thu,  3 Nov 2016 09:42:35 -0700
Message-ID: <1478191356-10386-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jakub Kicinski <kubakici@wp.pl>,
        Johannes Berg <johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35382 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755028AbcKCQmo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 12:42:44 -0400
Received: by mail-pf0-f196.google.com with SMTP id i88so5305536pfk.2
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 09:42:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In __genl_register_family(), when genl_validate_assign_mc_groups()
fails, we forget to free the memory we possibly allocate for
family->attrbuf.

Note, some callers call genl_unregister_family() to clean up
on error path, it doesn't work because the family is inserted
to the global list in the nearly last step.

Cc: Jakub Kicinski <kubakici@wp.pl>
Cc: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/netlink/genetlink.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 23cc126..49c28e8 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -404,7 +404,7 @@ int __genl_register_family(struct genl_family *family)
 
 	err = genl_validate_assign_mc_groups(family);
 	if (err)
-		goto errout_locked;
+		goto errout_free;
 
 	list_add_tail(&family->family_list, genl_family_chain(family->id));
 	genl_unlock_all();
@@ -417,6 +417,8 @@ int __genl_register_family(struct genl_family *family)
 
 	return 0;
 
+errout_free:
+	kfree(family->attrbuf);
 errout_locked:
 	genl_unlock_all();
 errout:
-- 
2.1.0
