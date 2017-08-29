From: Chris Mi <chrism@mellanox.com>
Subject: RE: [patch net-next 2/3] net/sched: Change cls_flower to use IDR
Date: Tue, 29 Aug 2017 03:25:35 +0000
Message-ID: <VI1PR0501MB2143DEF749AEB68635BEEC0CAB9F0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
References: <1503902477-39829-1-git-send-email-chrism@mellanox.com>
 <1503902477-39829-3-git-send-email-chrism@mellanox.com>
 <20170828113721.GA14697@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "mawilcox@microsoft.com" <mawilcox@microsoft.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40049.outbound.protection.outlook.com ([40.107.4.49]:43856
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751218AbdH2DZi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 23:25:38 -0400
In-Reply-To: <20170828113721.GA14697@vergenet.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Simon Horman [mailto:simon.horman@netronome.com]
> Sent: Monday, August 28, 2017 7:37 PM
> To: Chris Mi <chrism@mellanox.com>
> Cc: netdev@vger.kernel.org; jhs@mojatatu.com;
> xiyou.wangcong@gmail.com; jiri@resnulli.us; davem@davemloft.net;
> mawilcox@microsoft.com
> Subject: Re: [patch net-next 2/3] net/sched: Change cls_flower to use IDR
>=20
> On Mon, Aug 28, 2017 at 02:41:16AM -0400, Chris Mi wrote:
> > Currently, all filters with the same priority are linked in a doubly
> > linked list. Every filter should have a unique handle. To make the
> > handle unique, we need to iterate the list every time to see if the
> > handle exists or not when inserting a new filter. It is time-consuming.
> > For example, it takes about 5m3.169s to insert 64K rules.
> >
> > This patch changes cls_flower to use IDR. With this patch, it takes
> > about 0m1.127s to insert 64K rules. The improvement is huge.
>=20
> Very nice :)
>=20
> > But please note that in this testing, all filters share the same action=
.
> > If every filter has a unique action, that is another bottleneck.
> > Follow-up patch in this patchset addresses that.
> >
> > Signed-off-by: Chris Mi <chrism@mellanox.com>
> > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> > ---
> >  net/sched/cls_flower.c | 55
> > +++++++++++++++++++++-----------------------------
> >  1 file changed, 23 insertions(+), 32 deletions(-)
> >
> > diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c index
> > bd9dab4..3d041d2 100644
> > --- a/net/sched/cls_flower.c
> > +++ b/net/sched/cls_flower.c
>=20
> ...
>=20
> > @@ -890,6 +870,7 @@ static int fl_change(struct net *net, struct sk_buf=
f
> *in_skb,
> >  	struct cls_fl_filter *fnew;
> >  	struct nlattr **tb;
> >  	struct fl_flow_mask mask =3D {};
> > +	unsigned long idr_index;
> >  	int err;
> >
> >  	if (!tca[TCA_OPTIONS])
> > @@ -920,13 +901,21 @@ static int fl_change(struct net *net, struct sk_b=
uff
> *in_skb,
> >  		goto errout;
> >
> >  	if (!handle) {
> > -		handle =3D fl_grab_new_handle(tp, head);
> > -		if (!handle) {
> > -			err =3D -EINVAL;
> > +		err =3D idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
> > +				    1, 0x80000000, GFP_KERNEL);
> > +		if (err)
> >  			goto errout;
> > -		}
> > +		fnew->handle =3D idr_index;
> > +	}
> > +
> > +	/* user specifies a handle and it doesn't exist */
> > +	if (handle && !fold) {
> > +		err =3D idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
> > +				    handle, handle + 1, GFP_KERNEL);
> > +		if (err)
> > +			goto errout;
> > +		fnew->handle =3D idr_index;
> >  	}
> > -	fnew->handle =3D handle;
> >
> >  	if (tb[TCA_FLOWER_FLAGS]) {
> >  		fnew->flags =3D nla_get_u32(tb[TCA_FLOWER_FLAGS]);
> > @@ -980,6 +969,8 @@ static int fl_change(struct net *net, struct sk_buf=
f
> *in_skb,
> >  	*arg =3D fnew;
> >
> >  	if (fold) {
> > +		fnew->handle =3D handle;
>=20
> Can it be the case that fold is non-NULL and handle is zero?
> The handling of that case seem to have changed in this patch.
I don't think that could happen.  In function tc_ctl_tfilter(),

fl_get() will be called.  If handle is zero, fl_get() will return NULL.
That means fold is NULL.

>=20
> > +		idr_replace_ext(&head->handle_idr, fnew, fnew->handle);
> >  		list_replace_rcu(&fold->list, &fnew->list);
> >  		tcf_unbind_filter(tp, &fold->res);
> >  		call_rcu(&fold->rcu, fl_destroy_filter);
> > --
> > 1.8.3.1
> >
