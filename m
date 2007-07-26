From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/4 -rev1] Initilize and populate age field
Date: Thu, 26 Jul 2007 08:03:08 +0200
Message-ID: <46A8391C.2020605@cosmosbay.com>
References: <20070726104554.cc95eedd.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, shemminger@linux-foundation.org,
	krkumar2@in.ibm.com
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:39581 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081AbXGZGMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 02:12:50 -0400
In-Reply-To: <20070726104554.cc95eedd.varunc@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Varun Chandramohan a =E9crit :
> The age field is filled with the current time at the time of creation=
 of the route. When the routes are dumped
> then the age value stored in the route structure is subtracted from t=
he current time value and the difference is the age expressed in secs.
>=20
> Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
> ---
>  net/ipv4/fib_hash.c      |    3 +++
>  net/ipv4/fib_lookup.h    |    3 ++-
>  net/ipv4/fib_semantics.c |   16 +++++++++++++---
>  net/ipv4/fib_trie.c      |    1 +
>  4 files changed, 19 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
> index 07e843a..faa7364 100644
> --- a/net/ipv4/fib_hash.c
> +++ b/net/ipv4/fib_hash.c
> @@ -448,6 +448,7 @@ static int fn_hash_insert(struct fib_tab
>  			fa->fa_info =3D fi;
>  			fa->fa_type =3D cfg->fc_type;
>  			fa->fa_scope =3D cfg->fc_scope;
> +			fa->fa_age =3D 0;
>  			state =3D fa->fa_state;
>  			fa->fa_state &=3D ~FA_S_ACCESSED;
>  			fib_hash_genid++;
> @@ -507,6 +508,7 @@ static int fn_hash_insert(struct fib_tab
>  	new_fa->fa_type =3D cfg->fc_type;
>  	new_fa->fa_scope =3D cfg->fc_scope;
>  	new_fa->fa_state =3D 0;
> +	new_fa->fa_age =3D 0;
> =20
>  	/*
>  	 * Insert new entry to the list.
> @@ -697,6 +699,7 @@ fn_hash_dump_bucket(struct sk_buff *skb,
>  					  f->fn_key,
>  					  fz->fz_order,
>  					  fa->fa_tos,
> +					  &fa->fa_age,
>  					  fa->fa_info,
>  					  NLM_F_MULTI) < 0) {
>  				cb->args[4] =3D i;
> diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
> index eef9eec..c9145b5 100644
> --- a/net/ipv4/fib_lookup.h
> +++ b/net/ipv4/fib_lookup.h
> @@ -13,6 +13,7 @@ struct fib_alias {
>  	u8			fa_type;
>  	u8			fa_scope;
>  	u8			fa_state;
> +	time_t			fa_age;
>  };
> =20
>  #define FA_S_ACCESSED	0x01
> @@ -27,7 +28,7 @@ extern struct fib_info *fib_create_info(
>  extern int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)=
;
>  extern int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int =
event,
>  			 u32 tb_id, u8 type, u8 scope, __be32 dst,
> -			 int dst_len, u8 tos, struct fib_info *fi,
> +			 int dst_len, u8 tos, time_t *age, struct fib_info *fi,
>  			 unsigned int);
>  extern void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
>  		      int dst_len, u32 tb_id, struct nl_info *info,
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index c434119..1822d92 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -278,7 +278,8 @@ static inline size_t fib_nlmsg_size(stru
>  			 + nla_total_size(4) /* RTA_TABLE */
>  			 + nla_total_size(4) /* RTA_DST */
>  			 + nla_total_size(4) /* RTA_PRIORITY */
> -			 + nla_total_size(4); /* RTA_PREFSRC */
> +			 + nla_total_size(4) /* RTA_PREFSRC */
> +			 + nla_total_size(4); /*RTA_AGE*/

Not clear to me what happens on platforms where sizeof(time_t) is 8


> =20
>  	/* space for nested metrics */
>  	payload +=3D nla_total_size((RTAX_MAX * nla_total_size(4)));
> @@ -313,7 +314,7 @@ void rtmsg_fib(int event, __be32 key, st
> =20
>  	err =3D fib_dump_info(skb, info->pid, seq, event, tb_id,
>  			    fa->fa_type, fa->fa_scope, key, dst_len,
> -			    fa->fa_tos, fa->fa_info, nlm_flags);
> +			    fa->fa_tos, &fa->fa_age, fa->fa_info, nlm_flags);
>  	if (err < 0) {
>  		/* -EMSGSIZE implies BUG in fib_nlmsg_size() */
>  		WARN_ON(err =3D=3D -EMSGSIZE);
> @@ -940,11 +941,12 @@ __be32 __fib_res_prefsrc(struct fib_resu
>  }
> =20
>  int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
> -		  u32 tb_id, u8 type, u8 scope, __be32 dst, int dst_len, u8 tos,
> +		  u32 tb_id, u8 type, u8 scope, __be32 dst, int dst_len, u8 tos, t=
ime_t *age,
>  		  struct fib_info *fi, unsigned int flags)
>  {
>  	struct nlmsghdr *nlh;
>  	struct rtmsg *rtm;
> +	struct timeval tv;
> =20
>  	nlh =3D nlmsg_put(skb, pid, seq, event, sizeof(*rtm), flags);
>  	if (nlh =3D=3D NULL)
> @@ -985,6 +987,14 @@ int fib_dump_info(struct sk_buff *skb, u
>  			NLA_PUT_U32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid);
>  #endif
>  	}
> +
> +	do_gettimeofday(&tv);
> +	if (!*age) {
> +		*age =3D timeval_to_sec(&tv);
> +		NLA_PUT_U32(skb, RTA_AGE, *age);

here, what happens if sizeof(time_t) is not 4 ?

> +	} else {
> +		NLA_PUT_U32(skb, RTA_AGE, timeval_to_sec(&tv) - *age);
> +	}
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH
>  	if (fi->fib_nhs > 1) {
>  		struct rtnexthop *rtnh;
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 30e332a..be2d1d6 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -1884,6 +1884,7 @@ static int fn_trie_dump_fa(t_key key, in
>  				  xkey,
>  				  plen,
>  				  fa->fa_tos,
> +				  &fa->fa_age,
>  				  fa->fa_info, 0) < 0) {
>  			cb->args[4] =3D i;
>  			return -1;

