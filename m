From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Soft lockup in tc_classify
Date: Wed, 21 Dec 2016 11:15:41 +0100
Message-ID: <585A564D.4030702@iogearbox.net>
References: <c1c394d3-3aea-52a8-89e3-be57d4d46b8e@mellanox.com> <7394f89e-e8a5-5fb2-ee04-63bf1c4ef6e7@mellanox.com> <584EA60B.80803@iogearbox.net> <CAJ3xEMjABmvAMs6h0EqBgPH8QDDwF_x0COx01MkEw2pa+fp7LA@mail.gmail.com> <CAM_iQpVJ_Y5bB-RP2S2tK7sPNo6Atwcz5Ud8sG6bwDOSnq4NnA@mail.gmail.com> <18a64d65-1241-6c72-8333-47b0ae933139@mellanox.com> <CAM_iQpXUQYvvXonEXe0czd4osL5YxZ+G5B-PUddautcHnGOtQw@mail.gmail.com> <5a985705-11e5-1575-a049-723accb97608@mellanox.com> <58591A46.4060703@iogearbox.net> <66a3cb1e-862f-70e6-fff4-5a421766c432@mellanox.com> <CAM_iQpX3jL4URUQn5+-wV+3g2UKHWGBWYHr31wyZk2FQKVCzVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Shahar Klein <shahark@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60853 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754913AbcLUKPq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 05:15:46 -0500
In-Reply-To: <CAM_iQpX3jL4URUQn5+-wV+3g2UKHWGBWYHr31wyZk2FQKVCzVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2016 08:03 AM, Cong Wang wrote:
> On Tue, Dec 20, 2016 at 10:44 PM, Shahar Klein <shahark@mellanox.com> wrote:
[...]
> Looks like you added a debug printk inside tcf_destroy() too,
> which seems racy with filter creation, it should not happen since
> in both cases we take RTNL lock.
>
> Don't know if changing all RCU_INIT_POINTER in that file to
> rcu_assign_pointer could help anything or not. Mind to try?

I don't think at this point that it's RCU related at all.

I have a theory on what is happening. Quoting the piece in question from Shahar's log:

  1: thread-2845[cpu-1] setting tp_created to 1 tp=ffff94b5b0280780 back=ffff94b9ea932060
  2: thread-2856[cpu-1] setting tp_created to 1 tp=ffff94b9ea9322a0 back=ffff94b9ea932060
  3: thread-2843[cpu-1] setting tp_created to 1 tp=ffff94b5b402c960 back=ffff94b9ea932060
  4: destroy ffff94b5b669fea0 tcf_destroy:1905
  5: thread-2853[cpu-1] setting tp_created to 1 tp=ffff94b5b02805a0 back=ffff94b9ea932060
  6: thread-2853[cpu-1] add/change filter by: fl_get [cls_flower] tp=ffff94b5b02805a0 tp->next=ffff94b9ea932060
  7: destroy ffff94b5b0280780 tcf_destroy:1905
  8: thread-2845[cpu-1] add/change filter by: fl_get [cls_flower] tp=ffff94b5b02805a0 tp->next=ffff94b5b02805a0

The interesting thing is that all this happens on CPU1, so as you say we're under rtnl.
In 1), thread-2845 creates tp=ffff94b5b0280780, which is destroyed in 7), presumably also
by thread-2845, and the weird part is why suddenly in 8) thread-2845 adds a created filter
without actually creating it. Plus, thread-2845 got interrupted, which means it must have
dropped rntl in the middle. We drop it in tc_ctl_tfilter() when we do tcf_proto_lookup_ops()
and need to pull in a module, but here this doesn't make sense at all since i) at this
point we haven't created the tp yet and 2) flower was already there. Thus the only explanation
where this must have happened is where we called tp->ops->change(). So here the return
code must have been -EAGAIN, which makes sense because in 7) we destroyed that specific
tp instance. Which means we goto replay but *do not* clear tp_created. I think that is
the bug in question. So, while we dropped rtnl in the meantime, some other tp instance
was added (tp=ffff94b5b02805a0) that we had a match on in round 2, but we still think it
was newly created which wasn't the actual case. So we'd need to deal with the fact that
->change() callback could return -EAGAIN as well. Now looking at flower, I think the call
chain must have been fl_change() -> fl_set_parms() -> tcf_exts_validate() -> tcf_action_init()
-> tcf_action_init_1(). And here one possibility I see is that tc_lookup_action_n()
failed, therefore we shortly dropped rtnl for the request_module() where the module
got loaded successfully and thus error code from there is -EAGAIN that got propagated
all the way through ->change() from tc_ctl_tfilter(). So it looks like a generic issue
not specifically tied to flower.

Shahar, can you test the following? Thanks!

  net/sched/cls_api.c | 4 +++-
  1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 3fbba79..1ecdf80 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -148,13 +148,15 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
  	unsigned long cl;
  	unsigned long fh;
  	int err;
-	int tp_created = 0;
+	int tp_created;

  	if ((n->nlmsg_type != RTM_GETTFILTER) &&
  	    !netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN))
  		return -EPERM;

  replay:
+	tp_created = 0;
+
  	err = nlmsg_parse(n, sizeof(*t), tca, TCA_MAX, NULL);
  	if (err < 0)
  		return err;
-- 
1.9.3
