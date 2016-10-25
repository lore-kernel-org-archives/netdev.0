From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 net 1/1] net sched filters: fix notification of filter delete with proper handle
Date: Mon, 24 Oct 2016 20:18:27 -0400
Message-ID: <1477354707-7210-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com, jiri@resnulli.us,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36071 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941353AbcJYASk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 20:18:40 -0400
Received: by mail-oi0-f66.google.com with SMTP id e12so4349453oib.3
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 17:18:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Daniel says:

While trying out [1][2], I noticed that tc monitor doesn't show the
correct handle on delete:

$ tc monitor
qdisc clsact ffff: dev eno1 parent ffff:fff1
filter dev eno1 ingress protocol all pref 49152 bpf handle 0x2a [...]
deleted filter dev eno1 ingress protocol all pref 49152 bpf handle 0xf3be0c80

some context to explain the above:
The user identity of any tc filter is represented by a 32-bit
identifier encoded in tcm->tcm_handle. Example 0x2a in the bpf filter
above. A user wishing to delete, get or even modify a specific filter
uses this handle to reference it.
Every classifier is free to provide its own semantics for the 32 bit handle.
Example: classifiers like u32 use schemes like 800:1:801 to describe
the semantics of their filters represented as hash table, bucket and
node ids etc.
Classifiers also have internal per-filter representation which is different
from this externally visible identity. Most classifiers set this
internal representation to be a pointer address (which allows fast retrieval
of said filters in their implementations). This internal representation
is referenced with the "fh" variable in the kernel control code.

When a user successfuly deletes a specific filter, by specifying the correct
tcm->tcm_handle, an event is generated to user space which indicates
which specific filter was deleted.

Before this patch, the "fh" value was sent to user space as the identity.
As an example what is shown in the sample bpf filter delete event above
is 0xf3be0c80. This is infact a 32-bit truncation of 0xffff8807f3be0c80
which happens to be a 64-bit memory address of the internal filter
representation (address of the corresponding filter's struct cls_bpf_prog);

After this patch the appropriate user identifiable handle as encoded
in the originating request tcm->tcm_handle is generated in the event.
One of the cardinal rules of netlink rules is to be able to take an
event (such as a delete in this case) and reflect it back to the
kernel and successfully delete the filter. This patch achieves that.

Note, this issue has existed since the original TC action
infrastructure code patch back in 2004 as found in:
https://git.kernel.org/cgit/linux/kernel/git/history/history.git/commit/

[1] http://patchwork.ozlabs.org/patch/682828/
[2] http://patchwork.ozlabs.org/patch/682829/

Fixes: 4e54c4816bfe ("[NET]: Add tc extensions infrastructure.")
Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/cls_api.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 2ee29a3..2b2a797 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -345,7 +345,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 			if (err == 0) {
 				struct tcf_proto *next = rtnl_dereference(tp->next);
 
-				tfilter_notify(net, skb, n, tp, fh,
+				tfilter_notify(net, skb, n, tp,
+					       t->tcm_handle,
 					       RTM_DELTFILTER, false);
 				if (tcf_destroy(tp, false))
 					RCU_INIT_POINTER(*back, next);
-- 
1.9.1
