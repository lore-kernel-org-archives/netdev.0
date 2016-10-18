From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] sched, cls: don't dump kernel addr into tc monitors on delete event
Date: Tue, 18 Oct 2016 22:18:24 +0200
Message-ID: <f7e28cd6ec298a90dc33fcc85e7361eb92025690.1476821268.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        alexei.starovoitov@gmail.com,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56134 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbcJRUSe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 16:18:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While trying out [1][2], I noticed that tc monitor doesn't show the
correct handle on delete:

  $ tc monitor
  qdisc clsact ffff: dev eno1 parent ffff:fff1
  filter dev eno1 ingress protocol all pref 49152 bpf handle 0x2a [...]
  deleted filter dev eno1 ingress protocol all pref 49152 bpf handle 0xf3be0c80

In fact, the shown handle points to a kernel address, in this case
0xffff8807f3be0c80, which points to a struct cls_bpf_prog from bpf
classifier.

The issue is not bpf specific though. tcf_fill_node() sets a fh as
tcm->tcm_handle, which gets overridden on != RTM_DELTFILTER events
only. For RTM_DELTFILTER events, we cannot call the classifier's
dump() handler, since notification is given after delete() handler
returned with success.

At latest when a classifier's dump() handler is called, tm->tcm_handle
is filled with an actual handle. They are currently classifier
internal, meaning a tcf_proto can handle multiple classifiers if
the implementation supports it, so it needs to be queried from the
callback.

For RTM_DELTFILTER, the fh value contains the address of the object
to dump. Commit 4e54c4816bfe ("[NET]: Add tc extensions infrastructure.")
added the logic to assign tcm->tcm_handle = fh. tcm_handle is 32bit
so for 64bit archs, it's stored truncated. Prior to that commit, it
was set to 0. Reintroduce this, so we at least don't leak the kernel
address or parts of it to unprivileged user space listeners.

Since user space cannot make any sense out of this 32bit part,
passing a random number would be just as good. Lets pass 0, since i)
this allows to add the feature at some point for net-next, and ii)
this is also consistent with notifications via tfilter_notify_chain()
when we delete the entire chain.

  [1] http://patchwork.ozlabs.org/patch/682828/
  [2] http://patchwork.ozlabs.org/patch/682829/

Fixes: 4e54c4816bfe ("[NET]: Add tc extensions infrastructure.")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 ( Commit is in -history tree. Jamal, please take a look if you have
   a chance, thanks. )

 net/sched/cls_api.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 2ee29a3..e11bdc5 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -400,12 +400,11 @@ static int tcf_fill_node(struct net *net, struct sk_buff *skb,
 	tcm->tcm__pad2 = 0;
 	tcm->tcm_ifindex = qdisc_dev(tp->q)->ifindex;
 	tcm->tcm_parent = tp->classid;
+	tcm->tcm_handle = 0;
 	tcm->tcm_info = TC_H_MAKE(tp->prio, tp->protocol);
 	if (nla_put_string(skb, TCA_KIND, tp->ops->kind))
 		goto nla_put_failure;
-	tcm->tcm_handle = fh;
 	if (RTM_DELTFILTER != event) {
-		tcm->tcm_handle = 0;
 		if (tp->ops->dump && tp->ops->dump(net, tp, fh, skb, tcm) < 0)
 			goto nla_put_failure;
 	}
-- 
1.9.3
