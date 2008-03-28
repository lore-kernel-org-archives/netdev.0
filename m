From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-2.6.26 1/5][SOCK]: Enumerate struct proto-s to facilitate
 percpu inuse accounting.
Date: Fri, 28 Mar 2008 10:43:55 +0100
Message-ID: <47ECBDDB.2040203@cosmosbay.com>
References: <47ECB362.5050104@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.151]:45103 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752696AbYC1JoE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 05:44:04 -0400
In-Reply-To: <47ECB362.5050104@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov a =E9crit :
> This add the inuse_idx to struct proto and generates one in proto_reg=
ister.
> The ++ in generator is protected with write-locked proto_list_lock.
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>
> ---
>  include/net/sock.h |    1 +
>  net/core/sock.c    |   10 ++++++++++
>  2 files changed, 11 insertions(+), 0 deletions(-)
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
> index 3ee9506..a7faf30 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1940,6 +1940,15 @@ EXPORT_SYMBOL(sk_common_release);
>  static DEFINE_RWLOCK(proto_list_lock);
>  static LIST_HEAD(proto_list);
> =20
> +static void assign_proto_idx(struct proto *prot)
> +{
> +#ifdef CONFIG_PROC_FS
> +	static unsigned int idx =3D 0;
> +
>  =20
I believe some protocols can be registered, then unregistered, then=20
re-registered (module loads, unloads, ...)

So you probably want to use a bitmap instead of a counter that will=20
eventually reach PROTO_INUSE_NR

assign_proto_idx() should find a zero bit, and you should free this bit=
=20
at proto_unregister() time

> +	prot->inuse_idx =3D idx++;
> +#endif
> +}
> +
>  int proto_register(struct proto *prot, int alloc_slab)
>  {
>  	char *request_sock_slab_name =3D NULL;
> @@ -2000,6 +2009,7 @@ int proto_register(struct proto *prot, int allo=
c_slab)
> =20
>  	write_lock(&proto_list_lock);
>  	list_add(&prot->node, &proto_list);
> +	assign_proto_idx(prot);
>  	write_unlock(&proto_list_lock);
>  	return 0;
> =20
>  =20




