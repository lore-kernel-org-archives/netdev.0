From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 06/34] net: core: use dev->ingress_queue instead
 of tp->q
Date: Tue, 17 Oct 2017 09:42:25 +0200
Message-ID: <20171017074225.GD2112@nanopsycho>
References: <20171012171823.1431-1-jiri@resnulli.us>
 <20171012171823.1431-7-jiri@resnulli.us>
 <59DFE287.2040400@iogearbox.net>
 <20171013063019.GC1952@nanopsycho.orion>
 <59E29B5E.9000304@iogearbox.net>
 <20171015064535.GA1970@nanopsycho.orion>
 <59E51474.2050708@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:46310 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932850AbdJQHm2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:42:28 -0400
Received: by mail-wm0-f67.google.com with SMTP id m72so1902110wmc.1
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 00:42:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <59E51474.2050708@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 16, 2017 at 10:20:04PM CEST, daniel@iogearbox.net wrote:
>On 10/15/2017 08:45 AM, Jiri Pirko wrote:
>> Sun, Oct 15, 2017 at 01:18:54AM CEST, daniel@iogearbox.net wrote:
>> > On 10/13/2017 08:30 AM, Jiri Pirko wrote:
>> > > Thu, Oct 12, 2017 at 11:45:43PM CEST, daniel@iogearbox.net wrote:
>> > > > On 10/12/2017 07:17 PM, Jiri Pirko wrote:
>> > > > > From: Jiri Pirko <jiri@mellanox.com>
>> > > > > 
>> > > > > In sch_handle_egress and sch_handle_ingress, don't use tp->q and use
>> > > > > dev->ingress_queue which stores the same pointer instead.
>> > > > > 
>> > > > > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> > > > > ---
>> > > > >     net/core/dev.c | 21 +++++++++++++++------
>> > > > >     1 file changed, 15 insertions(+), 6 deletions(-)
>> > > > > 
>> > > > > diff --git a/net/core/dev.c b/net/core/dev.c
>> > > > > index fcddccb..cb9e5e5 100644
>> > > > > --- a/net/core/dev.c
>> > > > > +++ b/net/core/dev.c
>> > > > > @@ -3273,14 +3273,18 @@ EXPORT_SYMBOL(dev_loopback_xmit);
>> > > > >     static struct sk_buff *
>> > > > >     sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
>> > > > >     {
>> > > > > +	struct netdev_queue *netdev_queue =
>> > > > > +				rcu_dereference_bh(dev->ingress_queue);
>> > > > >     	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
>> > > > >     	struct tcf_result cl_res;
>> > > > > +	struct Qdisc *q;
>> > > > > 
>> > > > > -	if (!cl)
>> > > > > +	if (!cl || !netdev_queue)
>> > > > >     		return skb;
>> > > > > +	q = netdev_queue->qdisc;
>> > > > 
>> > > > NAK, no additional overhead in the software fast-path of
>> > > > sch_handle_{ingress,egress}() like this. There are users out there
>> > > > that use tc in software only, so performance is critical here.
>> > > 
>> > > Okay, how else do you suggest I can avoid the need to use tp->q?
>> > > I was thinking about storing q directly to net_device, which would safe
>> > > one dereference, resulting in the same amount as current cl->q.
>> > 
>> > Sorry for late reply, mostly off for few days. netdev struct has different
>> > cachelines which are hot on rx and tx (see also the location of the two
>> > lists, ingress_cl_list and egress_cl_list), if you add only one qdisc
>> > pointer there, then you'd at least penalize one of the two w/ potential
>> > cache miss. Can we leave it in cl?
>> 
>> Well that is the whole point of this excercise, to remove it from cl.
>> The thing is, for the shared blocks, cls are shared between multiple
>> qdisc instances, so cl->q makes no longer any sense.
>
>I don't really mind if you want to remove cl->q, but lets do it without
>adding any cost to the fast path. The primary motivation for this set
>is hw offload, but it shouldn't be at the expense to make sw fast path

That is not precise. The reason is not only hw offload. User could use
the block sharing for pure sw solution as well and benefit from that.


>slower. cl->q is only used here for updating stats, one possible option
>could be to take them out for the clsact case into dev at the expense
>for two pointers (e.g. getting rid of ingress_queue would reduce it to
>only one pointer), such that you have percpu {ingress,egress}_cl_stats
>that control path can fetch instead when dumping qdiscs. Could be one,
>but there are probably other options as well to explore.

I'm currently looking at that. Thanks.
