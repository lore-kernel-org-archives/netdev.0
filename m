From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net: sched: do not requeue a NULL skb
Date: Wed, 6 Apr 2016 10:14:03 -0700
Message-ID: <CAM_iQpXb9nfTOWkrhVk9NpREfjtE6fDHir-JMD5aw9XB=ur5Pw@mail.gmail.com>
References: <1459948214-735-1-git-send-email-larper@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Lars Persson <larper@axis.com>
To: Lars Persson <lars.persson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:33490 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbcDFROH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 13:14:07 -0400
In-Reply-To: <1459948214-735-1-git-send-email-larper@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2016 at 6:10 AM, Lars Persson <lars.persson@axis.com> wrote:
> A failure in validate_xmit_skb_list() triggered an unconditional call
> to dev_requeue_skb with skb=NULL. This slowly grows the queue
> discipline's qlen count until all traffic through the queue stops.
>

Sounds reasonable.

> Fixes: 55a93b3ea780 ("qdisc: validate skb without holding lock")
> Signed-off-by: Lars Persson <larper@axis.com>
> ---
>  net/sched/sch_generic.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index f18c350..1031536 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -165,6 +165,9 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
>                         skb = dev_hard_start_xmit(skb, dev, txq, &ret);
>
>                 HARD_TX_UNLOCK(dev, txq);
> +       } else {
> +               spin_lock(root_lock);
> +               return qdisc_qlen(q);

I think we should return 0 for this failure case so that qdisc_restart()
will stop. How about teaching dev_requeue_skb() to skip skb==NULL
case?
