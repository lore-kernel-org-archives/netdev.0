From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/13] netfilter: fix problem with proto register
Date: Wed, 27 Jun 2012 10:53:44 +0200
Message-ID: <20120627085344.GA17437@1984>
References: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
 <20120625111253.GA4607@1984>
 <4FE92F1E.9020901@cn.fujitsu.com>
 <20120626143620.GA11165@1984>
 <4FEA6424.90605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4FEA6424.90605@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 27, 2012 at 09:38:44AM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B406=E6=9C=8826=E6=97=A5 22:36, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > On Tue, Jun 26, 2012 at 11:40:14AM +0800, Gao feng wrote:
> >> Hi Pablo:
> >>
> >> =E4=BA=8E 2012=E5=B9=B406=E6=9C=8825=E6=97=A5 19:12, Pablo Neira A=
yuso =E5=86=99=E9=81=93:
> >>> On Thu, Jun 21, 2012 at 10:36:38PM +0800, Gao feng wrote:
> >>>> before commit 2c352f444ccfa966a1aa4fd8e9ee29381c467448
> >>>> (netfilter: nf_conntrack: prepare namespace support for
> >>>> l4 protocol trackers), we register sysctl before register
> >>>> protos, so if sysctl is registered faild, the protos will
> >>>> not be registered.
> >>>>
> >>>> but now, we register protos first, and when register
> >>>> sysctl failed, we can use protos too, it's different
> >>>> from before.
> >>>
> >>> No, this has to be an all-or-nothing game. If one fails, everythi=
ng
> >>> else that you've registered has to be unregistered.
> >>
> >> indeed,this is an all-or-nothing game right now,please look at the=
 ipv4_net_init,
> >> when we register nf_conntrack_l3proto_ipv4 failed,we will unregist=
er the already
> >> registered l4protoes, and in nf_conntrack_l4proto_unregister,we wi=
ll call
> >> nf_ct_l4proto_unregister_sysctl to free the sysctl table.
> >=20
> > I see proto->init_net allocates in->ctl_table, then
> > nf_ct_l3proto_register_sysctl release it if it fails. I got confuse=
d
> > because I did not see where that memory was being freed. Then, it's
> > good.
> >=20
> > Still one more thing:
> >=20
> >>>> so change to register sysctl before register protos.
> >>>>
> >>>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> >>>> ---
> >>>>  net/netfilter/nf_conntrack_proto.c |   36 +++++++++++++++++++++=
++-------------
> >>>>  1 files changed, 23 insertions(+), 13 deletions(-)
> >>>>
> >>>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/=
nf_conntrack_proto.c
> >>>> index 1ea9194..9bd88aa 100644
> >>>> --- a/net/netfilter/nf_conntrack_proto.c
> >>>> +++ b/net/netfilter/nf_conntrack_proto.c
> >>>> @@ -253,18 +253,23 @@ int nf_conntrack_l3proto_register(struct n=
et *net,
> >>>>  {
> >>>>  	int ret =3D 0;
> >>>> =20
> >>>> -	if (net =3D=3D &init_net)
> >>>> -		ret =3D nf_conntrack_l3proto_register_net(proto);
> >>>> +	if (proto->init_net) {
> >=20
> > I think proto->init_net has to be mandatory since all protocol supp=
ort
> > pernet already. We can add BUG_ON at the beginning of the function =
if
> > proto->init_net is not defined.
> >=20
>=20
> we can add BUG_ON at nf_conntrack_l4proto_register,because all of the=
 l4protoes
> have the init_net function.
>=20
> BUT nf_conntrack_l3proto_ipv6 doesn't have init_net function,because =
this proto
> doesn't have pernet data, and nf_conntrack_l3proto_ipv4 has pernet da=
ta only when
> CONFIG_NF_CONNTRACK_PROC_COMPAT is configured.

OK, thanks for the clarification.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
