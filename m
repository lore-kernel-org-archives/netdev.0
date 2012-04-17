From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 02/12] netfilter: don't register sysctl when register
 proto
Date: Tue, 17 Apr 2012 13:26:34 +0200
Message-ID: <20120417112634.GA2915@1984>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1334631383-12326-3-git-send-email-gaofeng@cn.fujitsu.com>
 <20120417085617.GC2100@1984>
 <4F8D4535.1040509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F8D4535.1040509@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2012 at 06:25:57PM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B404=E6=9C=8817=E6=97=A5 16:56, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > On Tue, Apr 17, 2012 at 10:56:13AM +0800, Gao feng wrote:
> >> delete nf_ct_l[3,4]proto_register_sysctl when register l[3,4]proto=
=2E
> >> and add nf_ct_register_net_sysctl,nf_ct_unregister_net_sysctl to
> >> register the sysctl for net namespace.
> >>
> >> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> >> ---
> >>  net/netfilter/nf_conntrack_proto.c |  109 +++++------------------=
-------------
> >>  1 files changed, 15 insertions(+), 94 deletions(-)
> >>
> >> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf=
_conntrack_proto.c
> >> index be3da2c..207cdd8 100644
> >> --- a/net/netfilter/nf_conntrack_proto.c
> >> +++ b/net/netfilter/nf_conntrack_proto.c
> >> @@ -35,12 +35,15 @@ EXPORT_SYMBOL_GPL(nf_ct_l3protos);
> >>  static DEFINE_MUTEX(nf_ct_proto_mutex);
> >> =20
> >>  #ifdef CONFIG_SYSCTL
> >> -static int
> >> -nf_ct_register_sysctl(struct ctl_table_header **header, struct ct=
l_path *path,
> >> -		      struct ctl_table *table, unsigned int *users)
> >> +int
> >> +nf_ct_register_net_sysctl(struct net *net,=20
> >> +			  struct ctl_table_header **header,
> >> +			  struct ctl_path *path,
> >> +			  struct ctl_table *table,
> >> +			  unsigned int *users)
> >=20
> > Please, don't rename this function. Just add the *net parameter
> > instead.
> >=20
>=20
> OK,i will modify it.
>=20
> >>  {
> >>  	if (*header =3D=3D NULL) {
> >> -		*header =3D register_sysctl_paths(path, table);
> >> +		*header =3D register_net_sysctl_table(net, path, table);
> >>  		if (*header =3D=3D NULL)
> >>  			return -ENOMEM;
> >>  	}
> >> @@ -48,17 +51,21 @@ nf_ct_register_sysctl(struct ctl_table_header =
**header, struct ctl_path *path,
> >>  		(*users)++;
> >>  	return 0;
> >>  }
> >> +EXPORT_SYMBOL_GPL(nf_ct_register_net_sysctl);
> >> =20
> >> -static void
> >> -nf_ct_unregister_sysctl(struct ctl_table_header **header,
> >> -			struct ctl_table *table, unsigned int *users)
> >> +void
> >> +nf_ct_unregister_net_sysctl(struct ctl_table_header **header,
> >> +			    struct ctl_table *table,
> >> +			    unsigned int *users)
> >>  {
> >>  	if (users !=3D NULL && --*users > 0)
> >>  		return;
> >> =20
> >>  	unregister_sysctl_table(*header);
> >> +	kfree(table);
> >>  	*header =3D NULL;
> >>  }
> >> +EXPORT_SYMBOL_GPL(nf_ct_unregister_net_sysctl);
> >>  #endif
> >> =20
> >>  struct nf_conntrack_l4proto *
> >> @@ -161,29 +168,6 @@ static int kill_l4proto(struct nf_conn *i, vo=
id *data)
> >>  	       nf_ct_l3num(i) =3D=3D l4proto->l3proto;
> >>  }
> >> =20
> >> -static int nf_ct_l3proto_register_sysctl(struct nf_conntrack_l3pr=
oto *l3proto)
> >> -{
> >> -	int err =3D 0;
> >> -
> >> -#ifdef CONFIG_SYSCTL
> >> -	if (l3proto->ctl_table !=3D NULL) {
> >> -		err =3D nf_ct_register_sysctl(&l3proto->ctl_table_header,
> >> -					    l3proto->ctl_table_path,
> >> -					    l3proto->ctl_table, NULL);
> >> -	}
> >> -#endif
> >> -	return err;
> >> -}
> >> -
> >> -static void nf_ct_l3proto_unregister_sysctl(struct nf_conntrack_l=
3proto *l3proto)
> >> -{
> >> -#ifdef CONFIG_SYSCTL
> >> -	if (l3proto->ctl_table_header !=3D NULL)
> >> -		nf_ct_unregister_sysctl(&l3proto->ctl_table_header,
> >> -					l3proto->ctl_table, NULL);
> >> -#endif
> >> -}
> >> -
> >>  int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *pr=
oto)
> >>  {
> >>  	int ret =3D 0;
> >> @@ -203,10 +187,6 @@ int nf_conntrack_l3proto_register(struct nf_c=
onntrack_l3proto *proto)
> >>  		goto out_unlock;
> >>  	}
> >> =20
> >> -	ret =3D nf_ct_l3proto_register_sysctl(proto);
> >> -	if (ret < 0)
> >> -		goto out_unlock;
> >> -
> >>  	if (proto->nlattr_tuple_size)
> >>  		proto->nla_size =3D 3 * proto->nlattr_tuple_size();
> >> =20
> >> @@ -230,7 +210,6 @@ void nf_conntrack_l3proto_unregister(struct nf=
_conntrack_l3proto *proto)
> >>  					 ) !=3D proto);
> >>  	rcu_assign_pointer(nf_ct_l3protos[proto->l3proto],
> >>  			   &nf_conntrack_l3proto_generic);
> >> -	nf_ct_l3proto_unregister_sysctl(proto);
> >>  	mutex_unlock(&nf_ct_proto_mutex);
> >> =20
> >>  	synchronize_rcu();
> >> @@ -243,52 +222,6 @@ void nf_conntrack_l3proto_unregister(struct n=
f_conntrack_l3proto *proto)
> >>  }
> >>  EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
> >> =20
> >> -static int nf_ct_l4proto_register_sysctl(struct nf_conntrack_l4pr=
oto *l4proto)
> >> -{
> >> -	int err =3D 0;
> >> -
> >> -#ifdef CONFIG_SYSCTL
> >> -	if (l4proto->ctl_table !=3D NULL) {
> >> -		err =3D nf_ct_register_sysctl(l4proto->ctl_table_header,
> >> -					    nf_net_netfilter_sysctl_path,
> >> -					    l4proto->ctl_table,
> >> -					    l4proto->ctl_table_users);
> >> -		if (err < 0)
> >> -			goto out;
> >> -	}
> >> -#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> >> -	if (l4proto->ctl_compat_table !=3D NULL) {
> >> -		err =3D nf_ct_register_sysctl(&l4proto->ctl_compat_table_header=
,
> >> -					    nf_net_ipv4_netfilter_sysctl_path,
> >> -					    l4proto->ctl_compat_table, NULL);
> >> -		if (err =3D=3D 0)
> >> -			goto out;
> >> -		nf_ct_unregister_sysctl(l4proto->ctl_table_header,
> >> -					l4proto->ctl_table,
> >> -					l4proto->ctl_table_users);
> >> -	}
> >> -#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
> >> -out:
> >> -#endif /* CONFIG_SYSCTL */
> >> -	return err;
> >> -}
> >> -
> >> -static void nf_ct_l4proto_unregister_sysctl(struct nf_conntrack_l=
4proto *l4proto)
> >> -{
> >> -#ifdef CONFIG_SYSCTL
> >> -	if (l4proto->ctl_table_header !=3D NULL &&
> >> -	    *l4proto->ctl_table_header !=3D NULL)
> >> -		nf_ct_unregister_sysctl(l4proto->ctl_table_header,
> >> -					l4proto->ctl_table,
> >> -					l4proto->ctl_table_users);
> >> -#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> >> -	if (l4proto->ctl_compat_table_header !=3D NULL)
> >> -		nf_ct_unregister_sysctl(&l4proto->ctl_compat_table_header,
> >> -					l4proto->ctl_compat_table, NULL);
> >> -#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
> >> -#endif /* CONFIG_SYSCTL */
> >> -}
> >> -
> >=20
> > Where did this function go?
>=20
>=20
> nf_ct_l4proto_unregister_sysctl just register sysctl,and we move this=
 logic
> to the pernet_operations.init, so this function has no use.

I think I prefer if you add struct net *net to all those functions to
reduce the amount of changes in the patch.

Have a look per-net helper registration in this patch:

http://patchwork.ozlabs.org/patch/152096/

We needed to add a new sysctl to disable helper assignment. I made it
in a way that it supports per-net.

I'm pointing to that patch as example because I think it's similar to t=
he
protocol registration. Before, the helper registration was not made
per-net at all.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
