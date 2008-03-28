From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-2.6.26 1/5][SOCK]: Enumerate struct proto-s to facilitate
 percpu inuse accounting (v2).
Date: Fri, 28 Mar 2008 18:15:51 +0100
Message-ID: <47ED27C7.5000202@cosmosbay.com>
References: <47ECE4B7.40806@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([80.12.242.50]:48352 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757315AbYC1RtO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 13:49:14 -0400
Received: from smtp23.orange.fr (mwinf2348 [10.232.4.148])
	by mwinf2305.orange.fr (SMTP Server) with ESMTP id F35541C25936
	for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 18:16:38 +0100 (CET)
In-Reply-To: <47ECE4B7.40806@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov a =E9crit :
> The inuse counters are going to become a per-cpu array.
> Introduce an index for this array on the struct proto.
>
> To handle the case of proto register-unregister-register
> loop the bitmap is used. All its bits manipulations are
> protected with proto_list_lock and a sanity check for the
> bitmap being exhausted is also added.
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>
>  =20
Acked-by: Eric Dumazet <dada1@cosmosbay.com>

> ---
>  include/net/sock.h |    1 +
>  net/core/sock.c    |   34 ++++++++++++++++++++++++++++++++++
>  2 files changed, 35 insertions(+), 0 deletions(-)
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 1c9d059..abc6341 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -562,6 +562,7 @@ struct proto {
> =20
>  	/* Keeping track of sockets in use */
>  #ifdef CONFIG_PROC_FS
> +	unsigned int		inuse_idx;
>  	struct pcounter		inuse;
>  #endif
> =20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 3ee9506..7d2c8ad 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1940,6 +1940,38 @@ EXPORT_SYMBOL(sk_common_release);
>  static DEFINE_RWLOCK(proto_list_lock);
>  static LIST_HEAD(proto_list);
> =20
> +#ifdef CONFIG_PROC_FS
> +#define PROTO_INUSE_NR	64	/* should be enough for the first time */
> +
> +static DECLARE_BITMAP(proto_inuse_idx, PROTO_INUSE_NR);
> +
> +static void assign_proto_idx(struct proto *prot)
> +{
> +	prot->inuse_idx =3D find_first_zero_bit(proto_inuse_idx, PROTO_INUS=
E_NR);
> +
> +	if (unlikely(prot->inuse_idx =3D=3D PROTO_INUSE_NR - 1)) {
> +		printk(KERN_ERR "PROTO_INUSE_NR exhausted\n");
> +		return;
> +	}
> +
> +	set_bit(prot->inuse_idx, proto_inuse_idx);
> +}
> +
> +static void release_proto_idx(struct proto *prot)
> +{
> +	if (prot->inuse_idx !=3D PROTO_INUSE_NR - 1)
> +		clear_bit(prot->inuse_idx, proto_inuse_idx);
> +}
> +#else
> +static inline void assign_proto_idx(struct proto *prot)
> +{
> +}
> +
> +static inline void release_proto_idx(struct proto *prot)
> +{
> +}
> +#endif
> +
>  int proto_register(struct proto *prot, int alloc_slab)
>  {
>  	char *request_sock_slab_name =3D NULL;
> @@ -2000,6 +2032,7 @@ int proto_register(struct proto *prot, int allo=
c_slab)
> =20
>  	write_lock(&proto_list_lock);
>  	list_add(&prot->node, &proto_list);
> +	assign_proto_idx(prot);
>  	write_unlock(&proto_list_lock);
>  	return 0;
> =20
> @@ -2026,6 +2059,7 @@ EXPORT_SYMBOL(proto_register);
>  void proto_unregister(struct proto *prot)
>  {
>  	write_lock(&proto_list_lock);
> +	release_proto_idx(prot);
>  	list_del(&prot->node);
>  	write_unlock(&proto_list_lock);
> =20
>
>
>  =20




