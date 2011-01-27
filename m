From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Wed, 26 Jan 2011 22:04:11 -0800
Message-ID: <1296108251.2448.183.camel@Joe-Laptop>
References: <1296062517.2899.86.camel@edumazet-laptop>
	 <1296063823.6115.37.camel@Joe-Laptop>
	 <20110126.115530.226756606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3403 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750764Ab1A0GEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jan 2011 01:04:12 -0500
In-Reply-To: <20110126.115530.226756606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-26 at 11:55 -0800, David Miller wrote: 
> From: Joe Perches <joe@perches.com>
> Date: Wed, 26 Jan 2011 09:43:43 -0800
> > On Wed, 2011-01-26 at 18:21 +0100, Eric Dumazet wrote:
> >> mqprio_dump() should make sure all fields of struct tc_mqprio_qopt are
> >> initialized.
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >> CC: John Fastabend <john.r.fastabend@intel.com>
> >> ---
> >>  net/sched/sch_mqprio.c |    2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >> 
> >> diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
> >> index fbc6f53..effd4ee 100644
> >> --- a/net/sched/sch_mqprio.c
> >> +++ b/net/sched/sch_mqprio.c
> >> @@ -215,7 +215,7 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
> >>  	struct net_device *dev = qdisc_dev(sch);
> >>  	struct mqprio_sched *priv = qdisc_priv(sch);
> >>  	unsigned char *b = skb_tail_pointer(skb);
> >> -	struct tc_mqprio_qopt opt;
> >> +	struct tc_mqprio_qopt opt = { 0 };
> > I think the best style to use memset so that any
> > possible struct padding is guaranteed to be zeroed.
> Such padding does not exist, and we won't add such padding since this is
> a user visible data structure and thus whose layout is cast in stone.

/* MQPRIO */
#define TC_QOPT_BITMASK 15
#define TC_QOPT_MAX_QUEUE 16

struct tc_mqprio_qopt {
__u8 num_tc;
__u8 prio_tc_map[TC_QOPT_BITMASK + 1];
__u8 hw;
__u16 count[TC_QOPT_MAX_QUEUE];
__u16 offset[TC_QOPT_MAX_QUEUE];
};

I believe this struct needs to be declared __packed.

It could otherwise be 24 bytes not 22.
Or if char array declarations have a different
alignment requirement, could be any size.

memset is better than {0}.

cheers, Joe

