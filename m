From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net/sched: cls_flower: verify root pointer
 before dereferncing it
Date: Tue, 22 Nov 2016 15:48:44 +0100
Message-ID: <20161122144844.GB1819@nanopsycho>
References: <1479824726-62607-1-git-send-email-roid@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Cong Wang <cwang@twopensource.com>
To: Roi Dayan <roid@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35563 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755421AbcKVPGB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 10:06:01 -0500
Received: by mail-qk0-f195.google.com with SMTP id n204so4466756qke.2
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 07:06:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1479824726-62607-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 22, 2016 at 03:25:26PM CET, roid@mellanox.com wrote:
>tp->root is being allocated in init() time and kfreed in destroy()
>however it is being dereferenced in classify() path.
>
>We could be in classify() path after destroy() was called and thus 
>tp->root is null. Verifying if tp->root is null in classify() path 
>is enough because it's being freed with kfree_rcu() and classify() 
>path is under rcu_read_lock().
>
>Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
>Signed-off-by: Roi Dayan <roid@mellanox.com>
>Cc: Cong Wang <cwang@twopensource.com>

This is correct

Reviewed-by: Jiri Pirko <jiri@mellanox.com>

The other way to fix this would be to move tp->ops->destroy call to
call_rcu phase. That would require bigger changes though. net-next
perhaps?



>---
>
>Hi Cong, all
>
>As stated above, the issue was introduced with commit 1e052be69d04 ("net_sched: destroy 
>proto tp when all filters are gone"). This patch provides a fix only for cls_flower where 
>I succeeded in reproducing the issue. Cong, if you can/want to come up with a fix that
>will be applicable for all the others classifiners, I am fine with that.
>
>Thanks,
>Roi
>
>
> net/sched/cls_flower.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
>index e8dd09a..88a26c4 100644
>--- a/net/sched/cls_flower.c
>+++ b/net/sched/cls_flower.c
>@@ -135,7 +135,7 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
> 	struct fl_flow_key skb_mkey;
> 	struct ip_tunnel_info *info;
> 
>-	if (!atomic_read(&head->ht.nelems))
>+	if (!head || !atomic_read(&head->ht.nelems))
> 		return -1;
> 
> 	fl_clear_masked_range(&skb_key, &head->mask);
>-- 
>2.7.4
>
