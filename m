From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 02/17] netfilter: add namespace support for l4proto
Date: Thu, 24 May 2012 12:00:40 +0200
Message-ID: <20120524100040.GD13091@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1336985547-31960-3-git-send-email-gaofeng@cn.fujitsu.com>
 <20120523102557.GB2836@1984>
 <4FBD9473.5050304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49289 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754142Ab2EXKAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 06:00:50 -0400
Content-Disposition: inline
In-Reply-To: <4FBD9473.5050304@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 24, 2012 at 09:52:51AM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B405=E6=9C=8823=E6=97=A5 18:25, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > On Mon, May 14, 2012 at 04:52:12PM +0800, Gao feng wrote:
> >> From: Gao feng <gaofeng@cn.fujitus.com>
[...]
> >> @@ -243,137 +253,172 @@ void nf_conntrack_l3proto_unregister(struc=
t nf_conntrack_l3proto *proto)
> >>  }
> >>  EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
> >> =20
> >> -static int nf_ct_l4proto_register_sysctl(struct nf_conntrack_l4pr=
oto *l4proto)
> >> +static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
> >> +					      struct nf_conntrack_l4proto *l4proto)
> >>  {
> >> -	int err =3D 0;
> >> +	if (l4proto->net_id)
> >> +		return net_generic(net, *l4proto->net_id);
> >> +	else
> >> +		return NULL;
> >> +}
> >> =20
> >> +int nf_ct_l4proto_register_sysctl(struct net *net,
> >> +				  struct nf_conntrack_l4proto *l4proto)
> >> +{
> >> +	int err =3D 0;
> >> +	struct nf_proto_net *pn =3D nf_ct_l4proto_net(net, l4proto);
> >> +	if (pn =3D=3D NULL)
> >> +		return 0;
> >>  #ifdef CONFIG_SYSCTL
> >> -	if (l4proto->ctl_table !=3D NULL) {
> >> -		err =3D nf_ct_register_sysctl(l4proto->ctl_table_header,
> >> +	if (pn->ctl_table !=3D NULL) {
> >> +		err =3D nf_ct_register_sysctl(net,
> >> +					    &pn->ctl_table_header,
> >>  					    "net/netfilter",
> >> -					    l4proto->ctl_table,
> >> -					    l4proto->ctl_table_users);
> >> -		if (err < 0)
> >> +					    pn->ctl_table,
> >> +					    &pn->users);
> >> +		if (err < 0) {
> >> +			kfree(pn->ctl_table);
> >> +			pn->ctl_table =3D NULL;
> >                                ^^^^^^^^^^^
> > Do you really need to set this above to NULL? Is there any existing
> > bug trap? If not, it's superfluous, please, remove it.
> >=20
> yes,l4proto_tcp(udp,icmp)'s ctl_table is stored in netns_ct.proto,
> so when we register l4proto_tcp's sysctl failed,ctl_table will still
> point to the kfreed memory. this will cause panic the next
> time we register l4proto_tcp's sysctl.

I see, thanks for the clarification.
