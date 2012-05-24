From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 04/17] netfilter: add namespace support for
 l4proto_generic
Date: Thu, 24 May 2012 11:52:22 +0200
Message-ID: <20120524095222.GA13091@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1336985547-31960-5-git-send-email-gaofeng@cn.fujitsu.com>
 <20120523103232.GD2836@1984>
 <4FBD8B40.4020303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46504 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753788Ab2EXJwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 05:52:33 -0400
Content-Disposition: inline
In-Reply-To: <4FBD8B40.4020303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 24, 2012 at 09:13:36AM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B405=E6=9C=8823=E6=97=A5 18:32, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > On Mon, May 14, 2012 at 04:52:14PM +0800, Gao feng wrote:
> >> implement and export nf_conntrack_proto_generic_[init,fini],
> >> nf_conntrack_[init,cleanup]_net call them to register or unregiste=
r
> >> the sysctl of generic proto.
> >>
> >> implement generic_net_init,it's used to initial the pernet
> >> data for generic proto.
> >>
> >> and use nf_generic_net.timeout to replace nf_ct_generic_timeout in
> >> get_timeouts function.
> >>
> >> Acked-by: Eric W. Biederman <ebiederm@xmission.com>
> >> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> >> ---
> >>  include/net/netfilter/nf_conntrack_l4proto.h |    2 +
> >>  include/net/netns/conntrack.h                |    6 +++
> >>  net/netfilter/nf_conntrack_core.c            |    8 +++-
> >>  net/netfilter/nf_conntrack_proto.c           |   21 +++++-----
> >>  net/netfilter/nf_conntrack_proto_generic.c   |   55 +++++++++++++=
+++++++++++-
> >>  5 files changed, 76 insertions(+), 16 deletions(-)
> >>
> >> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/includ=
e/net/netfilter/nf_conntrack_l4proto.h
> >> index a93dcd5..0d329b9 100644
> >> --- a/include/net/netfilter/nf_conntrack_l4proto.h
> >> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
> >> @@ -118,6 +118,8 @@ struct nf_conntrack_l4proto {
> >> =20
> >>  /* Existing built-in generic protocol */
> >>  extern struct nf_conntrack_l4proto nf_conntrack_l4proto_generic;
> >> +extern int nf_conntrack_proto_generic_init(struct net *net);
> >> +extern void nf_conntrack_proto_generic_fini(struct net *net);
> >> =20
> >>  #define MAX_NF_CT_PROTO 256
> >> =20
> >> diff --git a/include/net/netns/conntrack.h b/include/net/netns/con=
ntrack.h
> >> index 94992e9..3381b80 100644
> >> --- a/include/net/netns/conntrack.h
> >> +++ b/include/net/netns/conntrack.h
> >> @@ -20,7 +20,13 @@ struct nf_proto_net {
> >>  	unsigned int		users;
> >>  };
> >> =20
> >> +struct nf_generic_net {
> >> +	struct nf_proto_net pn;
> >> +	unsigned int timeout;
> >> +};
> >> +
> >>  struct nf_ip_net {
> >> +	struct nf_generic_net   generic;
> >>  #if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_CO=
MPAT)
> >>  	struct ctl_table_header *ctl_table_header;
> >>  	struct ctl_table	*ctl_table;
> >> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_=
conntrack_core.c
> >> index 32c5909..fd33e91 100644
> >> --- a/net/netfilter/nf_conntrack_core.c
> >> +++ b/net/netfilter/nf_conntrack_core.c
> >> @@ -1353,6 +1353,7 @@ static void nf_conntrack_cleanup_net(struct =
net *net)
> >>  	}
> >> =20
> >>  	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
> >> +	nf_conntrack_proto_generic_fini(net);
> >>  	nf_conntrack_helper_fini(net);
> >>  	nf_conntrack_timeout_fini(net);
> >>  	nf_conntrack_ecache_fini(net);
> >> @@ -1586,9 +1587,12 @@ static int nf_conntrack_init_net(struct net=
 *net)
> >>  	ret =3D nf_conntrack_helper_init(net);
> >>  	if (ret < 0)
> >>  		goto err_helper;
> >> -
> >> +	ret =3D nf_conntrack_proto_generic_init(net);
> >> +	if (ret < 0)
> >> +		goto err_generic;
> >>  	return 0;
> >> -
> >> +err_generic:
> >> +	nf_conntrack_helper_fini(net);
> >>  err_helper:
> >>  	nf_conntrack_timeout_fini(net);
> >>  err_timeout:
> >> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf=
_conntrack_proto.c
> >> index 7ee6653..9b4bf6d 100644
> >> --- a/net/netfilter/nf_conntrack_proto.c
> >> +++ b/net/netfilter/nf_conntrack_proto.c
> >> @@ -287,10 +287,16 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unreg=
ister);
> >>  static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
> >>  					      struct nf_conntrack_l4proto *l4proto)
> >>  {
> >> -	if (l4proto->net_id)
> >> -		return net_generic(net, *l4proto->net_id);
> >> -	else
> >> -		return NULL;
> >> +	switch (l4proto->l4proto) {
> >> +	case 255: /* l4proto_generic */
> >> +		return (struct nf_proto_net *)&net->ct.proto.generic;
> >> +	default:
> >> +		if (l4proto->net_id)
> >> +			return net_generic(net, *l4proto->net_id);
> >> +		else
> >> +			return NULL;
> >> +	}
> >> +	return NULL;
> >>  }
> >> =20
> >>  int nf_ct_l4proto_register_sysctl(struct net *net,
> >> @@ -457,11 +463,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregi=
ster);
> >>  int nf_conntrack_proto_init(void)
> >>  {
> >>  	unsigned int i;
> >> -	int err;
> >> -
> >> -	err =3D nf_ct_l4proto_register_sysctl(&init_net, &nf_conntrack_l=
4proto_generic);
> >> -	if (err < 0)
> >> -		return err;
> >=20
> > I like that all protocols sysctl are registered by
> > nf_conntrack_proto_init. Can you keep using that?
>=20
> you mean per-net's generic_proto sysctl are registered by
> nf_conntrack_proto_init?
>=20
> such as
>=20
> int nf_conntrack_proto_init(struct net *net)
> {
> 	...
> 	err =3D nf_ct_l4proto_register_sysctl(net, &nf_conntrack_l4proto_gen=
eric);

Yes, all protocol trackers included in nf_conntrack_proto_init:

        err =3D nf_conntrack_proto_generic_init(net);
        ...
        err =3D nf_conntrack_proto_tcp_init(net);
        ...

and so on.

> 	...
> }
>=20
> if my understanding is right,my answer is yes we can ;)
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
