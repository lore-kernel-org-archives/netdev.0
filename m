From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-2.6.26 2/5][SOCK]: Introduce a percpu inuse counters
 array (v2).
Date: Fri, 28 Mar 2008 18:17:49 +0100
Message-ID: <47ED283D.9040902@cosmosbay.com>
References: <47ECE58E.5030407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([193.252.22.30]:1592 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754410AbYC1RxE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 13:53:04 -0400
Received: from smtp23.orange.fr (mwinf2348 [10.232.4.148])
	by mwinf2335.orange.fr (SMTP Server) with ESMTP id D18161C197BB
	for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 18:18:27 +0100 (CET)
In-Reply-To: <47ECE58E.5030407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov a =E9crit :
> And redirect sock_prot_inuse_add and _get to use one.
>
> As far as the dereferences are concerned. Before the patch we made
> 1 dereference to proto->inuse.add call, the call itself and then
> called the __get_cpu_var() on a static variable. After the patch we=20
> make a direct call, then one dereference to proto->inuse_idx and=20
> then the same __get_cpu_var() on a still static variable. So this=20
> patch doesn't seem to produce performance penalty on SMP.
>
> This is not per-net yet, but I will deliberately make NET_NS=3Dy case
> separated from NET_NS=3Dn one, since it'll cost us one-or-two more=20
> dereferences to get the struct net and the inuse counter.
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>
>  =20

Acked-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
>  include/net/sock.h |   13 +++++--------
>  net/core/sock.c    |   22 ++++++++++++++++++++++
>  2 files changed, 27 insertions(+), 8 deletions(-)
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index abc6341..ebf9552 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -639,18 +639,15 @@ static inline void sk_refcnt_debug_release(cons=
t struct sock *sk)
>  # define DEFINE_PROTO_INUSE(NAME) DEFINE_PCOUNTER(NAME)
>  # define REF_PROTO_INUSE(NAME) PCOUNTER_MEMBER_INITIALIZER(NAME, .in=
use)
>  /* Called with local bh disabled */
> -static inline void sock_prot_inuse_add(struct proto *prot, int inc)
> -{
> -	pcounter_add(&prot->inuse, inc);
> -}
> +extern void sock_prot_inuse_add(struct proto *prot, int inc);
> +
>  static inline int sock_prot_inuse_init(struct proto *proto)
>  {
>  	return pcounter_alloc(&proto->inuse);
>  }
> -static inline int sock_prot_inuse_get(struct proto *proto)
> -{
> -	return pcounter_getval(&proto->inuse);
> -}
> +
> +extern int sock_prot_inuse_get(struct proto *proto);
> +
>  static inline void sock_prot_inuse_free(struct proto *proto)
>  {
>  	pcounter_free(&proto->inuse);
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 7d2c8ad..174c64b 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1942,8 +1942,30 @@ static LIST_HEAD(proto_list);
> =20
>  #ifdef CONFIG_PROC_FS
>  #define PROTO_INUSE_NR	64	/* should be enough for the first time */
> +struct prot_inuse {
> +	int val[PROTO_INUSE_NR];
> +};
> =20
>  static DECLARE_BITMAP(proto_inuse_idx, PROTO_INUSE_NR);
> +static DEFINE_PER_CPU(struct prot_inuse, prot_inuse);
> +
> +void sock_prot_inuse_add(struct proto *prot, int val)
> +{
> +	__get_cpu_var(prot_inuse).val[prot->inuse_idx] +=3D val;
> +}
> +EXPORT_SYMBOL_GPL(sock_prot_inuse_add);
> +
> +int sock_prot_inuse_get(struct proto *prot)
> +{
> +	int cpu, idx =3D prot->inuse_idx;
> +	int res =3D 0;
> +
> +	for_each_possible_cpu(cpu)
> +		res +=3D per_cpu(prot_inuse, cpu).val[idx];
> +
> +	return res >=3D 0 ? res : 0;
> +}
> +EXPORT_SYMBOL_GPL(sock_prot_inuse_get);
> =20
>  static void assign_proto_idx(struct proto *prot)
>  {
>  =20




