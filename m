From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH net 1/1] net sched actions: decrement module reference count after table flush.
Date: Fri, 24 Feb 2017 11:00:32 -0500
Message-ID: <1487952032-508-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36863 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751192AbdBXQBA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 11:01:00 -0500
Received: by mail-it0-f67.google.com with SMTP id w185so4245952ita.3
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 08:00:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tc actions are loaded as a module and no actions have been installed,
flushing them would result in actions removed from the memory, but modules
reference count not being decremented, so that the modules would not be
unloaded.

Following is example with GACT action:

% sudo modprobe act_gact
% lsmod
Module                  Size  Used by
act_gact               16384  0
%
% sudo tc actions ls action gact
%
% sudo tc actions flush action gact
% lsmod
Module                  Size  Used by
act_gact               16384  1
% sudo tc actions flush action gact
% lsmod
Module                  Size  Used by
act_gact               16384  2
% sudo rmmod act_gact
rmmod: ERROR: Module act_gact is in use
....

After the fix:
% lsmod
Module                  Size  Used by
act_gact               16384  0
%
% sudo tc actions add action pass index 1
% sudo tc actions add action pass index 2
% sudo tc actions add action pass index 3
% lsmod
Module                  Size  Used by
act_gact               16384  3
%
% sudo tc actions flush action gact
% lsmod
Module                  Size  Used by
act_gact               16384  0
%
% sudo tc actions flush action gact
% lsmod
Module                  Size  Used by
act_gact               16384  0
% sudo rmmod act_gact
% lsmod
Module                  Size  Used by
%

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index f219ff3..dfe64f8 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -859,10 +859,8 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 		goto out_module_put;
 
 	err = ops->walk(net, skb, &dcb, RTM_DELACTION, ops);
-	if (err < 0)
+	if (err <= 0)
 		goto out_module_put;
-	if (err == 0)
-		goto noflush_out;
 
 	nla_nest_end(skb, nest);
 
@@ -879,7 +877,6 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 out_module_put:
 	module_put(ops->owner);
 err_out:
-noflush_out:
 	kfree_skb(skb);
 	return err;
 }
-- 
1.9.1
