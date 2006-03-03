From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH] powerpc: ibmveth: Harden driver initilisation for kexec
Date: Fri, 3 Mar 2006 11:22:45 +1100
Message-ID: <200603031122.51174.michael@ellerman.id.au>
References: <20060131041055.5623C68A46@ozlabs.org>
	<20060131042903.GF28896@krispykreme> <44074A22.8060705@us.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1115760362=="
Cc: linuxppc64-dev@ozlabs.org, netdev@vger.kernel.org, anton@samba.org
Return-path: <linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: jgarzik@pobox.com
In-Reply-To: <44074A22.8060705@us.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============1115760362==
Content-Type: multipart/signed;
  boundary="nextPart2857686.g3iqe1TG2i";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart2857686.g3iqe1TG2i
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Jeff,

I realise it's late, but it'd be really good if you could send this up for=
=20
2.6.16, we're hosed without it.

cheers

On Fri, 3 Mar 2006 06:40, Santiago Leon wrote:
> From: Michael Ellerman <michael@ellerman.id.au>
>
> After a kexec the veth driver will fail when trying to register with the
> Hypervisor because the previous kernel has not unregistered.
>
> So if the registration fails, we unregister and then try again.
>
> Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
> Acked-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Santiago Leon <santil@us.ibm.com>
> ---
>
>   drivers/net/ibmveth.c |   32 ++++++++++++++++++++++++++------
>   1 files changed, 26 insertions(+), 6 deletions(-)
>
> Looks good to me, and has been around for a couple of months.
>
> Index: kexec/drivers/net/ibmveth.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- kexec.orig/drivers/net/ibmveth.c
> +++ kexec/drivers/net/ibmveth.c
> @@ -436,6 +436,31 @@ static void ibmveth_cleanup(struct ibmve
>   		ibmveth_free_buffer_pool(adapter, &adapter->rx_buff_pool[i]);
>   }
>
> +static int ibmveth_register_logical_lan(struct ibmveth_adapter *adapter,
> +		union ibmveth_buf_desc rxq_desc, u64 mac_address)
> +{
> +	int rc, try_again =3D 1;
> +
> +	/* After a kexec the adapter will still be open, so our attempt to
> +	 * open it will fail. So if we get a failure we free the adapter and
> +	 * try again, but only once. */
> +retry:
> +	rc =3D h_register_logical_lan(adapter->vdev->unit_address,
> +			adapter->buffer_list_dma, rxq_desc.desc,
> +			adapter->filter_list_dma, mac_address);
> +
> +	if (rc !=3D H_Success && try_again) {
> +		do {
> +			rc =3D h_free_logical_lan(adapter->vdev->unit_address);
> +		} while (H_isLongBusy(rc) || (rc =3D=3D H_Busy));
> +
> +		try_again =3D 0;
> +		goto retry;
> +	}
> +
> +	return rc;
> +}
> +
>   static int ibmveth_open(struct net_device *netdev)
>   {
>   	struct ibmveth_adapter *adapter =3D netdev->priv;
> @@ -504,12 +529,7 @@ static int ibmveth_open(struct net_devic
>   	ibmveth_debug_printk("filter list @ 0x%p\n", adapter->filter_list_addr=
);
>   	ibmveth_debug_printk("receive q   @ 0x%p\n",
> adapter->rx_queue.queue_addr);
>
> -
> -	lpar_rc =3D h_register_logical_lan(adapter->vdev->unit_address,
> -					 adapter->buffer_list_dma,
> -					 rxq_desc.desc,
> -					 adapter->filter_list_dma,
> -					 mac_address);
> +	lpar_rc =3D ibmveth_register_logical_lan(adapter, rxq_desc, mac_address=
);
>
>   	if(lpar_rc !=3D H_Success) {
>   		ibmveth_error_printk("h_register_logical_lan failed with %ld\n",
> lpar_rc);
>
>
>
> _______________________________________________
> Linuxppc64-dev mailing list
> Linuxppc64-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc64-dev

=2D-=20
Michael Ellerman
IBM OzLabs

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--nextPart2857686.g3iqe1TG2i
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBEB4xbdSjSd0sB4dIRAmBWAKCpRVEkkbQCmsKofwxUAM7kKnlEngCgwJcj
WfsSWXqPRIQO90SadidRuEk=
=xO5d
-----END PGP SIGNATURE-----

--nextPart2857686.g3iqe1TG2i--

--===============1115760362==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc64-dev mailing list
Linuxppc64-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc64-dev

--===============1115760362==--
