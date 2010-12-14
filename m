From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 12/12] cxgb4: NUMA-aware Tx queue allocations
Date: Tue, 14 Dec 2010 22:17:59 +0100
Message-ID: <1292361479.2478.2.camel@edumazet-laptop>
References: <1292357896-14339-1-git-send-email-dm@chelsio.com>
	 <1292357896-14339-2-git-send-email-dm@chelsio.com>
	 <1292357896-14339-3-git-send-email-dm@chelsio.com>
	 <1292357896-14339-4-git-send-email-dm@chelsio.com>
	 <1292357896-14339-5-git-send-email-dm@chelsio.com>
	 <1292357896-14339-6-git-send-email-dm@chelsio.com>
	 <1292357896-14339-7-git-send-email-dm@chelsio.com>
	 <1292357896-14339-8-git-send-email-dm@chelsio.com>
	 <1292357896-14339-9-git-send-email-dm@chelsio.com>
	 <1292357896-14339-10-git-send-email-dm@chelsio.com>
	 <1292357896-14339-11-git-send-email-dm@chelsio.com>
	 <1292357896-14339-12-git-send-email-dm@chelsio.com>
	 <1292357896-14339-13-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42115 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756097Ab0LNVSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 16:18:03 -0500
Received: by wyb28 with SMTP id 28so887881wyb.19
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 13:18:02 -0800 (PST)
In-Reply-To: <1292357896-14339-13-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 d=C3=A9cembre 2010 =C3=A0 12:18 -0800, Dimitris Michailidis=
 a =C3=A9crit :
> Allocate Tx queue memory on the node indicated by the new
> netdev_queue_numa_node_read.  If that fails we allocate on any node.
>=20
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
> ---
>  drivers/net/cxgb4/sge.c |   20 +++++++++++++-------
>  1 files changed, 13 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
> index cc0b997..ed98b8a 100644
> --- a/drivers/net/cxgb4/sge.c
> +++ b/drivers/net/cxgb4/sge.c
> @@ -579,6 +579,7 @@ static inline void __refill_fl(struct adapter *ad=
ap, struct sge_fl *fl)
>   *	@phys: the physical address of the allocated ring
>   *	@metadata: address of the array holding the SW state for the ring
>   *	@stat_size: extra space in HW ring for status information
> + *	@node: preferred node for memory allocations
>   *
>   *	Allocates resources for an SGE descriptor ring, such as Tx queues=
,
>   *	free buffer lists, or response queues.  Each SGE ring requires
> @@ -590,7 +591,7 @@ static inline void __refill_fl(struct adapter *ad=
ap, struct sge_fl *fl)
>   */
>  static void *alloc_ring(struct device *dev, size_t nelem, size_t ele=
m_size,
>  			size_t sw_size, dma_addr_t *phys, void *metadata,
> -			size_t stat_size)
> +			size_t stat_size, int node)
>  {
>  	size_t len =3D nelem * elem_size + stat_size;
>  	void *s =3D NULL;
> @@ -599,7 +600,10 @@ static void *alloc_ring(struct device *dev, size=
_t nelem, size_t elem_size,
>  	if (!p)
>  		return NULL;
>  	if (sw_size) {
> -		s =3D kcalloc(nelem, sw_size, GFP_KERNEL);
> +		if (node >=3D 0)
> +			s =3D kzalloc_node(nelem * sw_size, GFP_KERNEL, node);

kzalloc_node() has a fallback, you dont need to retry with kcalloc()

> +		if (!s)
> +			s =3D kcalloc(nelem, sw_size, GFP_KERNEL);
> =20
>  		if (!s) {
>  			dma_free_coherent(dev, len, p, *phys);

Also, I am not sure it is going to work, since we can setup XPS only
after device being setup ?

By the time your driver allocates rings, we probably read
-1/NUMA_NO_NODE



