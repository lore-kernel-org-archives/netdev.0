From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH] net_sched: fix order of queue length updates in
 qdisc_replace()
Date: Sat, 19 Aug 2017 15:42:03 +0300
Message-ID: <70895dd0-cf65-b9bc-ac4f-4098be5a5f97@yandex-team.ru>
References: <150314622756.18396.5215271249872220640.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, stable@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1g.cmail.yandex.net ([87.250.241.190]:48911 "EHLO
        forwardcorp1g.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751004AbdHSMmG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Aug 2017 08:42:06 -0400
In-Reply-To: <150314622756.18396.5215271249872220640.stgit@buzz>
Content-Language: ru-RU
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've seen this as loops in hfsc rb-trees and hungs in hfsc_dequeue() -> rb_first().
Simple debug catched insering already inserted rb-tree nodes and similar mess.

Most likely this could explain warning in hfsc_dequeue()
https://bugzilla.kernel.org/show_bug.cgi?id=109581

On 19.08.2017 15:37, Konstantin Khlebnikov wrote:
> This important to call qdisc_tree_reduce_backlog() after changing queue
> length. Parent qdisc should deactivate class in ->qlen_notify() called from
> qdisc_tree_reduce_backlog() but this happens only if qdisc->q.qlen in zero.
> 
> Missed class deactivations leads to crashes/warnings at picking packets
> from empty qdisc and corrupting state at reactivating this class in future.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 86a7996cc8a0 ("net_sched: introduce qdisc_replace() helper")hfsc_dequeue
> Cc: Stable <stable@vger.kernel.org>
> ---
>   include/net/sch_generic.h |    5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 1c123e2b2415..67f815e5d525 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -806,8 +806,11 @@ static inline struct Qdisc *qdisc_replace(struct Qdisc *sch, struct Qdisc *new,
>   	old = *pold;
>   	*pold = new;
>   	if (old != NULL) {
> -		qdisc_tree_reduce_backlog(old, old->q.qlen, old->qstats.backlog);
> +		unsigned int qlen = old->q.qlen;
> +		unsigned int backlog = old->qstats.backlog;
> +
>   		qdisc_reset(old);
> +		qdisc_tree_reduce_backlog(old, qlen, backlog);
>   	}
>   	sch_tree_unlock(sch);
>   
> 
