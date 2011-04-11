From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 2/14] ehea: Update multiqueue support
Date: Mon, 11 Apr 2011 11:13:26 +1000
Message-ID: <1302484406.12482.19.camel@concordia>
References: <20110405212825.6eb85677@kryten>
	 <20110405212956.5eba3495@kryten>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-MnobSOoB9WcgZAmXFeJb"
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45523 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185Ab1DKBN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 21:13:28 -0400
In-Reply-To: <20110405212956.5eba3495@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MnobSOoB9WcgZAmXFeJb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-04-05 at 21:29 +1000, Anton Blanchard wrote:
> The ehea driver had some multiqueue support but was missing the last
> few years of networking stack improvements:

...

> Index: linux-2.6/drivers/net/ehea/ehea_main.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/drivers/net/ehea/ehea_main.c	2011-04-05 20:34:36.30071=
5364 +1000
> +++ linux-2.6/drivers/net/ehea/ehea_main.c	2011-04-05 20:35:36.703818722 =
+1000
> @@ -753,6 +753,8 @@ static int ehea_proc_rwqes(struct net_de
>  				skb_copy_to_linear_data(skb, ((char *)cqe) + 64,
>  						 cqe->num_bytes_transfered - 4);
>  				ehea_fill_skb(dev, skb, cqe);
> +				skb_record_rx_queue(skb,
> +					pr - &pr->port->port_res[0]);
>  			} else if (rq =3D=3D 2) {
>  				/* RQ2 */
>  				skb =3D get_skb_by_index(skb_arr_rq2,
> @@ -763,6 +765,8 @@ static int ehea_proc_rwqes(struct net_de
>  					break;
>  				}
>  				ehea_fill_skb(dev, skb, cqe);
> +				skb_record_rx_queue(skb,
> +					pr - &pr->port->port_res[0]);
>  				processed_rq2++;
>  			} else {
>  				/* RQ3 */
> @@ -774,6 +778,8 @@ static int ehea_proc_rwqes(struct net_de
>  					break;
>  				}
>  				ehea_fill_skb(dev, skb, cqe);
> +				skb_record_rx_queue(skb,
> +					pr - &pr->port->port_res[0]);
>  				processed_rq3++;
>  			}
> =20

Couldn't you call skb_record_rx_queue() in ehea_proc_skb() and save
replicating it three times?

> @@ -909,14 +916,16 @@ static struct ehea_cqe *ehea_proc_cqes(s
>  	ehea_update_feca(send_cq, cqe_counter);
>  	atomic_add(swqe_av, &pr->swqe_avail);
> =20
> -	spin_lock_irqsave(&pr->netif_queue, flags);
> -
> -	if (pr->queue_stopped && (atomic_read(&pr->swqe_avail)
> -				  >=3D pr->swqe_refill_th)) {
> -		netif_wake_queue(pr->port->netdev);
> -		pr->queue_stopped =3D 0;
> +	if (unlikely(netif_tx_queue_stopped(txq) &&
> +		     (atomic_read(&pr->swqe_avail) >=3D pr->swqe_refill_th))) {
> +		__netif_tx_lock(txq, smp_processor_id());
> +		if (netif_tx_queue_stopped(txq) &&
> +		    (atomic_read(&pr->swqe_avail) >=3D pr->swqe_refill_th)) {
> +			netif_tx_wake_queue(txq);
> +			__netif_tx_unlock(txq);
> +		}
>  	}

This potentially leaves the txq locked doesn't it, which I don't think
you want to do?

cheers



--=-MnobSOoB9WcgZAmXFeJb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk2iVbMACgkQdSjSd0sB4dL8MgCeIClT814izBWHjj50FkJSKmGw
H0IAoIWElU9C+j4GzdyTK8ylKBkJFNDA
=NhYF
-----END PGP SIGNATURE-----

--=-MnobSOoB9WcgZAmXFeJb--

