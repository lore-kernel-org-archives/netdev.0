From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [patch v2 04/11] nf_conntrack_netlink: pass
 nf_conntrack_netlink module to netlink_dump_start
Date: Wed, 26 Sep 2012 17:04:30 +0200
Message-ID: <20120926150430.GA12438@1984>
References: <1348648888-24943-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1348648888-24943-4-git-send-email-gaofeng@cn.fujitsu.com>
 <20120926092632.GA21589@1984>
 <5062CE07.1080704@cn.fujitsu.com>
 <20120926095837.GA23815@1984>
 <5062F6A9.7020309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	jengelh-9+2X+4sQBs8@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5062F6A9.7020309-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 26, 2012 at 08:35:53PM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B409=E6=9C=8826=E6=97=A5 17:58, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > On Wed, Sep 26, 2012 at 05:42:31PM +0800, Gao feng wrote:
> >> Hi Pablo:
> >>
> >> =E4=BA=8E 2012=E5=B9=B409=E6=9C=8826=E6=97=A5 17:26, Pablo Neira A=
yuso =E5=86=99=E9=81=93:
> >>> On Wed, Sep 26, 2012 at 04:41:21PM +0800, Gao feng wrote:
> >>>> use proper netlink_dump_control.done and .module to avoid panic.
> >>>>
> >>>> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> >>>> ---
> >>>>  net/netfilter/nf_conntrack_netlink.c |    8 ++++++++
> >>>>  1 files changed, 8 insertions(+), 0 deletions(-)
> >>>>
> >>>> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilte=
r/nf_conntrack_netlink.c
> >>>> index 9807f32..509a257 100644
> >>>> --- a/net/netfilter/nf_conntrack_netlink.c
> >>>> +++ b/net/netfilter/nf_conntrack_netlink.c
> >>>> @@ -706,6 +706,7 @@ static int ctnetlink_done(struct netlink_cal=
lback *cb)
> >>>>  		nf_ct_put((struct nf_conn *)cb->args[1]);
> >>>>  	if (cb->data)
> >>>>  		kfree(cb->data);
> >>>> +	netlink_dump_done(cb);
> >>>
> >>> I think you can call netlink_dump_done from af_netlink.c:
> >>>
> >>> static int netlink_dump(struct sock *sk)=20
> >>>         ...
> >>>         if (cb->done) {
> >>>                 cb->done(cb);
> >>>                 netlink_dump_done(...);
> >>>         }
> >>>
> >>> Thus, you don't need to change netlink_dump_control in every netl=
ink
> >>> subsystem.
> >>
> >> because cb->done is called by netlink_sock_destruct too,it's very =
usefully
> >> when userspace program only send dump request to kernel without re=
ading
> >> data from kernel.
> >=20
> > Then add that to netlink_sock_destruct as well. If possible, I pref=
er
> > if this remains in the netlink core to avoid leaking module refcoun=
t
> > if you forget to call netlink_dump_done.
>=20
> make sense, I will update it in next version.
> Thanks!

Great. Remove also netlink_dump_done and just use module_put instead
after cb->done. That new function you added is so small that there is
no way to justify its addition.

> >=20
> >>>
> >>>>  	return 0;
> >>>>  }
> >>>> =20
> >>>> @@ -1022,6 +1023,7 @@ ctnetlink_get_conntrack(struct sock *ctnl,=
 struct sk_buff *skb,
> >>>>  		struct netlink_dump_control c =3D {
> >>>>  			.dump =3D ctnetlink_dump_table,
> >>>>  			.done =3D ctnetlink_done,
> >>>> +			.module =3D THIS_MODULE,
> >>>
> >>> You can do something similar to:
> >>>
> >>> 9f00d97 netlink: hide struct module parameter in netlink_kernel_c=
reate
> >>>
> >>> by definiting netlink_dump_start as static inline and using
> >>> THIS_MODULE from there.
> >>>
> >>> If I'm not missing anything, with those two changes, you will not=
 need
> >>> to modify any caller and it will result one single patch.
> >>>
> >>
> >> You can see the patch [11/11], THIS_MODULE in infiniband/core/cma.=
c
> >> means module rdma_cm,but we call netlink_dump_start in infiniband/=
core/netlink.c
> >=20
> > You can still use __netlink_dump_start for that case, which allows =
you
> > to specify a custom struct module * parameter. But for most cases,
> > netlink_dump_start (which hides THIS_MODULE) should be fine.
>=20
> I don't know how to deal with module_put in this way.
> and I think my  way is simple enough.

Not sure what problem with module_put you're refering to.

I think you can make this patchset way smaller with the change I'm
proposing.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
