From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next 2/3] net/sched: Change cls_flower to use IDR
Date: Wed, 30 Aug 2017 12:30:07 +0200
Message-ID: <20170830103006.GB14786@vergenet.net>
References: <1503902477-39829-1-git-send-email-chrism@mellanox.com>
 <1503902477-39829-3-git-send-email-chrism@mellanox.com>
 <20170828113721.GA14697@vergenet.net>
 <VI1PR0501MB2143DEF749AEB68635BEEC0CAB9F0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "mawilcox@microsoft.com" <mawilcox@microsoft.com>
To: Chris Mi <chrism@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38110 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751357AbdH3KaL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 06:30:11 -0400
Received: by mail-wm0-f53.google.com with SMTP id t201so7640471wmt.1
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 03:30:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <VI1PR0501MB2143DEF749AEB68635BEEC0CAB9F0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 03:25:35AM +0000, Chris Mi wrote:
> 
> 
> > -----Original Message-----
> > From: Simon Horman [mailto:simon.horman@netronome.com]
> > Sent: Monday, August 28, 2017 7:37 PM
> > To: Chris Mi <chrism@mellanox.com>
> > Cc: netdev@vger.kernel.org; jhs@mojatatu.com;
> > xiyou.wangcong@gmail.com; jiri@resnulli.us; davem@davemloft.net;
> > mawilcox@microsoft.com
> > Subject: Re: [patch net-next 2/3] net/sched: Change cls_flower to use IDR
> > 
> > On Mon, Aug 28, 2017 at 02:41:16AM -0400, Chris Mi wrote:
> > > Currently, all filters with the same priority are linked in a doubly
> > > linked list. Every filter should have a unique handle. To make the
> > > handle unique, we need to iterate the list every time to see if the
> > > handle exists or not when inserting a new filter. It is time-consuming.
> > > For example, it takes about 5m3.169s to insert 64K rules.
> > >
> > > This patch changes cls_flower to use IDR. With this patch, it takes
> > > about 0m1.127s to insert 64K rules. The improvement is huge.
> > 
> > Very nice :)
> > 
> > > But please note that in this testing, all filters share the same action.
> > > If every filter has a unique action, that is another bottleneck.
> > > Follow-up patch in this patchset addresses that.
> > >
> > > Signed-off-by: Chris Mi <chrism@mellanox.com>
> > > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> > > ---
> > >  net/sched/cls_flower.c | 55
> > > +++++++++++++++++++++-----------------------------
> > >  1 file changed, 23 insertions(+), 32 deletions(-)
> > >
> > > diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c index
> > > bd9dab4..3d041d2 100644
> > > --- a/net/sched/cls_flower.c
> > > +++ b/net/sched/cls_flower.c
> > 
> > ...
> > 
> > > @@ -890,6 +870,7 @@ static int fl_change(struct net *net, struct sk_buff
> > *in_skb,
> > >  	struct cls_fl_filter *fnew;
> > >  	struct nlattr **tb;
> > >  	struct fl_flow_mask mask = {};
> > > +	unsigned long idr_index;
> > >  	int err;
> > >
> > >  	if (!tca[TCA_OPTIONS])
> > > @@ -920,13 +901,21 @@ static int fl_change(struct net *net, struct sk_buff
> > *in_skb,
> > >  		goto errout;
> > >
> > >  	if (!handle) {
> > > -		handle = fl_grab_new_handle(tp, head);
> > > -		if (!handle) {
> > > -			err = -EINVAL;
> > > +		err = idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
> > > +				    1, 0x80000000, GFP_KERNEL);
> > > +		if (err)
> > >  			goto errout;
> > > -		}
> > > +		fnew->handle = idr_index;
> > > +	}
> > > +
> > > +	/* user specifies a handle and it doesn't exist */
> > > +	if (handle && !fold) {
> > > +		err = idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
> > > +				    handle, handle + 1, GFP_KERNEL);
> > > +		if (err)
> > > +			goto errout;
> > > +		fnew->handle = idr_index;
> > >  	}
> > > -	fnew->handle = handle;
> > >
> > >  	if (tb[TCA_FLOWER_FLAGS]) {
> > >  		fnew->flags = nla_get_u32(tb[TCA_FLOWER_FLAGS]);
> > > @@ -980,6 +969,8 @@ static int fl_change(struct net *net, struct sk_buff
> > *in_skb,
> > >  	*arg = fnew;
> > >
> > >  	if (fold) {
> > > +		fnew->handle = handle;
> > 
> > Can it be the case that fold is non-NULL and handle is zero?
> > The handling of that case seem to have changed in this patch.
> I don't think that could happen.  In function tc_ctl_tfilter(),
> 
> fl_get() will be called.  If handle is zero, fl_get() will return NULL.
> That means fold is NULL.

Thanks for the explanation, I see that now.

> > > +		idr_replace_ext(&head->handle_idr, fnew, fnew->handle);
> > >  		list_replace_rcu(&fold->list, &fnew->list);
> > >  		tcf_unbind_filter(tp, &fold->res);
> > >  		call_rcu(&fold->rcu, fl_destroy_filter);
