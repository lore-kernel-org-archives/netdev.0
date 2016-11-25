From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net/sched: cls_flower: verify root pointer before
 dereferncing it
Date: Fri, 25 Nov 2016 01:17:13 +0100
Message-ID: <58378309.2090101@iogearbox.net>
References: <58346C7B.7090006@iogearbox.net>    <20161122161159.GC1819@nanopsycho>      <CAM_iQpVTtqQRg7KgQbMQSxxVJRB8a46DGgfU52m=SxF1uYDFWQ@mail.gmail.com> <20161124.152546.1174938340314080043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, roid@mellanox.com, netdev@vger.kernel.org,
        jiri@mellanox.com, ogerlitz@mellanox.com, cwang@twopensource.com,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com
To: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35323 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750749AbcKYART (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 19:17:19 -0500
In-Reply-To: <20161124.152546.1174938340314080043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/24/2016 09:25 PM, David Miller wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 22 Nov 2016 11:28:37 -0800
>
>> On Tue, Nov 22, 2016 at 8:11 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Tue, Nov 22, 2016 at 05:04:11PM CET, daniel@iogearbox.net wrote:
>>>> Hmm, I don't think we want to have such an additional test in fast
>>>> path for each and every classifier. Can we think of ways to avoid that?
>>>>
>>>> My question is, since we unlink individual instances from such tp-internal
>>>> lists through RCU and release the instance through call_rcu() as well as
>>>> the head (tp->root) via kfree_rcu() eventually, against what are we protecting
>>>> setting RCU_INIT_POINTER(tp->root, NULL) in ->destroy() callback? Something
>>>> not respecting grace period?
>>>
>>> If you call tp->ops->destroy in call_rcu, you don't have to set tp->root
>>> to null.
>>
>> We do need to respect the grace period if we touch the globally visible
>> data structure tp in tcf_destroy(). Therefore Roi's patch is not fixing the
>> right place.
>
> Another idea is to assign tp->root to a dummy static cls_fl_head object,
> instead of NULL, which we just make sure has an ht.elems value of zero.
>
> This avoids having to touch the fast path and also avoids all of these
> complicated changes being discussed wrt. doing things in call_rcu_bh()
> or whatever.

I'm not sure if setting a dummy object for each affected classifier is
making things better. Are you having this in mind as a target for -net?

We do kfree_rcu() the head (tp->root) and likewise do we kfree_rcu() the
tp immediately after the callback. The head object's lifetime for such
classifiers is thus always bound to the tp lifetime. And besides that,
nothing apart from get() checks whether it's actually really NULL (and
that check in get() is odd anyway; some cls do it, some don't).

I took a deeper look into the history, and found that this was not always
the case. For example, d3fa76ee6b4a ("[NET_SCHED]: cls_basic: fix NULL
pointer dereference") moved tp->root initialization into init() routine,
where before it was part of change(), so get() had to deal with head being
NULL back then, so that was indeed a valid case. Also some classify()
callbacks were checking for head being NULL, so destroy would set it to
NULL, f.e. 47a1a1d4be29 ("pkt_sched: remove unnecessary xchg() in packet
classifiers").

For basic, bpf, flow, flower, matchall, I cooked the below diff which
should be usable and small enough for -net.

The remaining pieces from ->destroy() to ->delete() conversion patch from
Cong, we could later on do in -net-next.

Roi, could you check the below for flower with your setup?

(Btw, matchall is still broken besides this fix. mall_delete() sets the
  RCU_INIT_POINTER(head->filter, NULL), so that a mall_delete() plus
  mall_destroy() combo doesn't free head->filter twice, but doing that is
  racy with mall_classify() where head->filter is dereferenced unchecked.
  Requires additional fix.)

  net/sched/cls_basic.c    |  4 ----
  net/sched/cls_bpf.c      |  4 ----
  net/sched/cls_flow.c     |  1 -
  net/sched/cls_flower.c   | 15 +++++++++++----
  net/sched/cls_matchall.c |  1 -
  5 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index eb219b7..5877f60 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -62,9 +62,6 @@ static unsigned long basic_get(struct tcf_proto *tp, u32 handle)
  	struct basic_head *head = rtnl_dereference(tp->root);
  	struct basic_filter *f;

-	if (head == NULL)
-		return 0UL;
-
  	list_for_each_entry(f, &head->flist, link) {
  		if (f->handle == handle) {
  			l = (unsigned long) f;
@@ -109,7 +106,6 @@ static bool basic_destroy(struct tcf_proto *tp, bool force)
  		tcf_unbind_filter(tp, &f->res);
  		call_rcu(&f->rcu, basic_delete_filter);
  	}
-	RCU_INIT_POINTER(tp->root, NULL);
  	kfree_rcu(head, rcu);
  	return true;
  }
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index bb1d5a4..0a47ba5 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -292,7 +292,6 @@ static bool cls_bpf_destroy(struct tcf_proto *tp, bool force)
  		call_rcu(&prog->rcu, __cls_bpf_delete_prog);
  	}

-	RCU_INIT_POINTER(tp->root, NULL);
  	kfree_rcu(head, rcu);
  	return true;
  }
@@ -303,9 +302,6 @@ static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
  	struct cls_bpf_prog *prog;
  	unsigned long ret = 0UL;

-	if (head == NULL)
-		return 0UL;
-
  	list_for_each_entry(prog, &head->plist, link) {
  		if (prog->handle == handle) {
  			ret = (unsigned long) prog;
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index e396723..6575aba 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -596,7 +596,6 @@ static bool flow_destroy(struct tcf_proto *tp, bool force)
  		list_del_rcu(&f->list);
  		call_rcu(&f->rcu, flow_destroy_filter);
  	}
-	RCU_INIT_POINTER(tp->root, NULL);
  	kfree_rcu(head, rcu);
  	return true;
  }
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index f6f40fb..f6a7ae0 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -269,6 +269,15 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
  	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, &tc);
  }

+static void fl_destroy_rcu(struct rcu_head *rcu)
+{
+	struct cls_fl_head *head = container_of(rcu, struct cls_fl_head, rcu);
+
+	if (head->mask_assigned)
+		rhashtable_destroy(&head->ht);
+	kfree(head);
+}
+
  static bool fl_destroy(struct tcf_proto *tp, bool force)
  {
  	struct cls_fl_head *head = rtnl_dereference(tp->root);
@@ -282,10 +291,8 @@ static bool fl_destroy(struct tcf_proto *tp, bool force)
  		list_del_rcu(&f->list);
  		call_rcu(&f->rcu, fl_destroy_filter);
  	}
-	RCU_INIT_POINTER(tp->root, NULL);
-	if (head->mask_assigned)
-		rhashtable_destroy(&head->ht);
-	kfree_rcu(head, rcu);
+
+	call_rcu(&head->rcu, fl_destroy_rcu);
  	return true;
  }

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 25927b6..f935429 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -114,7 +114,6 @@ static bool mall_destroy(struct tcf_proto *tp, bool force)

  		call_rcu(&f->rcu, mall_destroy_filter);
  	}
-	RCU_INIT_POINTER(tp->root, NULL);
  	kfree_rcu(head, rcu);
  	return true;
  }
-- 
1.9.3
