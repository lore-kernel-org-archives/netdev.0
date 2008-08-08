From: jamal <hadi@cyberus.ca>
Subject: [PATCH]:net-sched: Fix actions flushing
Date: Fri, 08 Aug 2008 09:37:22 -0400
Message-ID: <1218202642.4688.51.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-bfM0dGg7HC3yTRXuKSVV"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:6875 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502AbYHHNha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 09:37:30 -0400
Received: by yx-out-2324.google.com with SMTP id 8so232176yxm.1
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2008 06:37:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bfM0dGg7HC3yTRXuKSVV
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Caught by regression testing which i havent run in a loong time.

cheers,
jamal

--=-bfM0dGg7HC3yTRXuKSVV
Content-Disposition: attachment; filename=act_f1
Content-Type: text/plain; name=act_f1; charset=us-ascii
Content-Transfer-Encoding: 7bit

net-sched: Fix actions flushing

Flushing of actions has been broken since we changed
the semantics of netlink parsed tb[X] to mean X is an attribute type.
This makes the flushing work.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 4e13e943acd2aa262e1e10c7779518d3ca18cae3
tree 0d95c9b83575fb39538ad4db13adf6bc5aa09105
parent 8dd4c21ea0029bb6a9c838254460f9b1ca677531
author Jamal Hadi Salim <hadi@cyberus.ca> Fri, 08 Aug 2008 09:20:29 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Fri, 08 Aug 2008 09:20:29 -0400

 net/sched/act_api.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 26c7e1f..88b5733 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -790,6 +790,8 @@ static int tca_action_flush(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
 	err = a->ops->walk(skb, &dcb, RTM_DELACTION, a);
 	if (err < 0)
 		goto nla_put_failure;
+	if (err == 0)
+		goto noflush_out;
 
 	nla_nest_end(skb, nest);
 
@@ -807,6 +809,7 @@ nla_put_failure:
 nlmsg_failure:
 	module_put(a->ops->owner);
 err_out:
+noflush_out:
 	kfree_skb(skb);
 	kfree(a);
 	return err;
@@ -824,8 +827,10 @@ tca_action_gd(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int event)
 		return ret;
 
 	if (event == RTM_DELACTION && n->nlmsg_flags&NLM_F_ROOT) {
-		if (tb[0] != NULL && tb[1] == NULL)
-			return tca_action_flush(tb[0], n, pid);
+		if (tb[1] != NULL)
+			return tca_action_flush(tb[1], n, pid);
+		else
+			return -EINVAL;
 	}
 
 	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {

--=-bfM0dGg7HC3yTRXuKSVV--

