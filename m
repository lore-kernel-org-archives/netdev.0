From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net/sched: cls_flower: verify root pointer
 before dereferncing it
Date: Tue, 22 Nov 2016 17:11:59 +0100
Message-ID: <20161122161159.GC1819@nanopsycho>
References: <1479824726-62607-1-git-send-email-roid@mellanox.com>
 <20161122144844.GB1819@nanopsycho>
 <58346C7B.7090006@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roi Dayan <roid@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Cong Wang <cwang@twopensource.com>, john.fastabend@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33101 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754238AbcKVQMo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 11:12:44 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so4827508wmu.0
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 08:12:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <58346C7B.7090006@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 22, 2016 at 05:04:11PM CET, daniel@iogearbox.net wrote:
>[ + John ]
>
>On 11/22/2016 03:48 PM, Jiri Pirko wrote:
>> Tue, Nov 22, 2016 at 03:25:26PM CET, roid@mellanox.com wrote:
>> > tp->root is being allocated in init() time and kfreed in destroy()
>> > however it is being dereferenced in classify() path.
>> > 
>> > We could be in classify() path after destroy() was called and thus
>> > tp->root is null. Verifying if tp->root is null in classify() path
>> > is enough because it's being freed with kfree_rcu() and classify()
>> > path is under rcu_read_lock().
>> > 
>> > Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
>> > Signed-off-by: Roi Dayan <roid@mellanox.com>
>> > Cc: Cong Wang <cwang@twopensource.com>
>> 
>> This is correct
>> 
>> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
>> 
>> The other way to fix this would be to move tp->ops->destroy call to
>> call_rcu phase. That would require bigger changes though. net-next
>> perhaps?
>
>Hmm, I don't think we want to have such an additional test in fast
>path for each and every classifier. Can we think of ways to avoid that?
>
>My question is, since we unlink individual instances from such tp-internal
>lists through RCU and release the instance through call_rcu() as well as
>the head (tp->root) via kfree_rcu() eventually, against what are we protecting
>setting RCU_INIT_POINTER(tp->root, NULL) in ->destroy() callback? Something
>not respecting grace period?

If you call tp->ops->destroy in call_rcu, you don't have to set tp->root
to null.


>
>The only thing that actually checks if tp->root is NULL right now is the
>get() callback. Is that the reason why tp->root is RCU'ified? John?
>
>Thanks,
>Daniel
>
>> > Hi Cong, all
>> > 
>> > As stated above, the issue was introduced with commit 1e052be69d04 ("net_sched: destroy
>> > proto tp when all filters are gone"). This patch provides a fix only for cls_flower where
>> > I succeeded in reproducing the issue. Cong, if you can/want to come up with a fix that
>> > will be applicable for all the others classifiners, I am fine with that.
>> > 
>> > Thanks,
>> > Roi
>> > 
>> > 
>> > net/sched/cls_flower.c | 2 +-
>> > 1 file changed, 1 insertion(+), 1 deletion(-)
>> > 
>> > diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
>> > index e8dd09a..88a26c4 100644
>> > --- a/net/sched/cls_flower.c
>> > +++ b/net/sched/cls_flower.c
>> > @@ -135,7 +135,7 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>> > 	struct fl_flow_key skb_mkey;
>> > 	struct ip_tunnel_info *info;
>> > 
>> > -	if (!atomic_read(&head->ht.nelems))
>> > +	if (!head || !atomic_read(&head->ht.nelems))
>> > 		return -1;
>> > 
>> > 	fl_clear_masked_range(&skb_key, &head->mask);
>> > --
>> > 2.7.4
>> > 
>
