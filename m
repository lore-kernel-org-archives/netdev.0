From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: act_ipt: fix regression in ipt action
Date: Thu, 01 Feb 2007 00:21:47 +0100
Message-ID: <45C1248B.9040108@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030603040109050000040600"
Cc: jamal <hadi@cyberus.ca>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41524 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933338AbXAaXVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 18:21:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030603040109050000040600
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------030603040109050000040600
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: act_ipt: fix regression in ipt action

The x_tables patch broke target module autoloading in the ipt action
by replacing the ipt_find_target call (which does autoloading) by
xt_find_target (which doesn't do autoloading). Additionally xt_find_target
may return ERR_PTR values in case of an error, which are not handled.

Use xt_request_find_target, which does both autoloading and ERR_PTR
handling properly. Also don't forget to drop the target module reference
again when xt_check_target fails.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0252c2a43dd6b2d14d5c1d95db235d11064f6a0f
tree 441706f4506870381bef87ff46dfe8177749975c
parent 5263bf65d6342e12ab716db8e529501670979321
author Patrick McHardy <kaber@trash.net> Thu, 01 Feb 2007 00:13:51 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 01 Feb 2007 00:13:51 +0100

 net/sched/act_ipt.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index a960806..01e6913 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -55,7 +55,8 @@ static int ipt_init_target(struct ipt_en
 	struct ipt_target *target;
 	int ret = 0;
 
-	target = xt_find_target(AF_INET, t->u.user.name, t->u.user.revision);
+	target = xt_request_find_target(AF_INET, t->u.user.name,
+					t->u.user.revision);
 	if (!target)
 		return -ENOENT;
 
@@ -63,9 +64,10 @@ static int ipt_init_target(struct ipt_en
 
 	ret = xt_check_target(target, AF_INET, t->u.target_size - sizeof(*t),
 			      table, hook, 0, 0);
-	if (ret)
+	if (ret) {
+		module_put(t->u.kernel.target->me);
 		return ret;
-
+	}
 	if (t->u.kernel.target->checkentry
 	    && !t->u.kernel.target->checkentry(table, NULL,
 		    			       t->u.kernel.target, t->data,

--------------030603040109050000040600--
