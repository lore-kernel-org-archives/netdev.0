From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-2.6.26 3/5][SOCK]: Drop per-proto inuse init and fre
 functions (v2).
Date: Fri, 28 Mar 2008 18:18:47 +0100
Message-ID: <47ED2877.7010209@cosmosbay.com>
References: <47ECE605.1050403@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([193.252.22.30]:1982 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754281AbYC1RxY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 13:53:24 -0400
Received: from smtp23.orange.fr (mwinf2348 [10.232.4.148])
	by mwinf2335.orange.fr (SMTP Server) with ESMTP id C7B551C12D32
	for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 18:19:24 +0100 (CET)
In-Reply-To: <47ECE605.1050403@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov a =E9crit :
> Constructive part of the set is finished here. We have to
> remove the pcounter, so start with its init and free
> functions.
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>
>  =20
Acked-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
>  include/net/sock.h |   18 ------------------
>  net/core/sock.c    |   11 +----------
>  2 files changed, 1 insertions(+), 28 deletions(-)
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index ebf9552..1f42942 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -640,31 +640,13 @@ static inline void sk_refcnt_debug_release(cons=
t struct sock *sk)
>  # define REF_PROTO_INUSE(NAME) PCOUNTER_MEMBER_INITIALIZER(NAME, .in=
use)
>  /* Called with local bh disabled */
>  extern void sock_prot_inuse_add(struct proto *prot, int inc);
> -
> -static inline int sock_prot_inuse_init(struct proto *proto)
> -{
> -	return pcounter_alloc(&proto->inuse);
> -}
> -
>  extern int sock_prot_inuse_get(struct proto *proto);
> -
> -static inline void sock_prot_inuse_free(struct proto *proto)
> -{
> -	pcounter_free(&proto->inuse);
> -}
>  #else
>  # define DEFINE_PROTO_INUSE(NAME)
>  # define REF_PROTO_INUSE(NAME)
>  static void inline sock_prot_inuse_add(struct proto *prot, int inc)
>  {
>  }
> -static int inline sock_prot_inuse_init(struct proto *proto)
> -{
> -	return 0;
> -}
> -static void inline sock_prot_inuse_free(struct proto *proto)
> -{
> -}
>  #endif
> =20
> =20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 174c64b..c1ae56e 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1999,11 +1999,6 @@ int proto_register(struct proto *prot, int all=
oc_slab)
>  	char *request_sock_slab_name =3D NULL;
>  	char *timewait_sock_slab_name;
> =20
> -	if (sock_prot_inuse_init(prot) !=3D 0) {
> -		printk(KERN_CRIT "%s: Can't alloc inuse counters!\n", prot->name);
> -		goto out;
> -	}
> -
>  	if (alloc_slab) {
>  		prot->slab =3D kmem_cache_create(prot->name, prot->obj_size, 0,
>  					       SLAB_HWCACHE_ALIGN, NULL);
> @@ -2011,7 +2006,7 @@ int proto_register(struct proto *prot, int allo=
c_slab)
>  		if (prot->slab =3D=3D NULL) {
>  			printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
>  			       prot->name);
> -			goto out_free_inuse;
> +			goto out;
>  		}
> =20
>  		if (prot->rsk_prot !=3D NULL) {
> @@ -2070,8 +2065,6 @@ out_free_request_sock_slab_name:
>  out_free_sock_slab:
>  	kmem_cache_destroy(prot->slab);
>  	prot->slab =3D NULL;
> -out_free_inuse:
> -	sock_prot_inuse_free(prot);
>  out:
>  	return -ENOBUFS;
>  }
> @@ -2085,8 +2078,6 @@ void proto_unregister(struct proto *prot)
>  	list_del(&prot->node);
>  	write_unlock(&proto_list_lock);
> =20
> -	sock_prot_inuse_free(prot);
> -
>  	if (prot->slab !=3D NULL) {
>  		kmem_cache_destroy(prot->slab);
>  		prot->slab =3D NULL;
>  =20




