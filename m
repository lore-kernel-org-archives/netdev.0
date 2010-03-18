From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Thu, 18 Mar 2010 14:32:32 +0200
Message-ID: <20100318123232.GC3364@swordfish.minsk.epam.com>
References: <1268699602.2824.14.camel@edumazet-laptop>
 <20100316145914.GB3332@swordfish.minsk.epam.com>
 <1268751933.3094.45.camel@edumazet-laptop>
 <20100316151023.GC3332@swordfish.minsk.epam.com>
 <1268752826.3094.48.camel@edumazet-laptop>
 <20100316182619.GA3451@swordfish>
 <1268765284.2932.17.camel@edumazet-laptop>
 <20100317072539.GA3579@swordfish>
 <1268811437.2932.66.camel@edumazet-laptop>
 <20100317235505.GA6674@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="w7PDEPdKQumQfZlR"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:46152 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049Ab0CRMbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 08:31:39 -0400
Received: by fxm19 with SMTP id 19so2049793fxm.21
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 05:31:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100317235505.GA6674@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--w7PDEPdKQumQfZlR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

This hunk is rejected. I suppose I should apply patch against unpatched ver=
sion (Eric's patch).
Correct? /* Eric's patch does make sense to my mind. */


@@ -4604,22 +4601,19 @@
        void __iomem *ioaddr =3D tp->mmio_addr;
        int work_done;
=20
+
+       RTL_W16(IntrStatus, tp->napi_event);
+
        work_done =3D rtl8169_rx_interrupt(dev, tp, ioaddr, (u32) budget);
        rtl8169_tx_interrupt(dev, tp, ioaddr);
=20
        if (work_done < budget) {
                napi_complete(napi);
=20
-               /* We need for force the visibility of tp->intr_mask
-                * for other CPUs, as we can loose an MSI interrupt
-                * and potentially wait for a retransmit timeout if we don'=
t.
-                * The posted write to IntrMask is safe, as it will
-                * eventually make it to the chip and we won't loose anythi=
ng
-                * until it does.
-                */
-               tp->intr_mask =3D 0xffff;
-               smp_wmb();
                RTL_W16(IntrMask, tp->intr_event);
+               mmiowb();
+
+               rtl_napi_cond_schedule(tp, RTL_R16(IntrStatus));
        }



	Sergey



On (03/18/10 00:55), Francois Romieu wrote:
> This one should help too if Sergey owns a (MSI) 8168.
>=20
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index dfc3573..721e7f3 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -4532,21 +4532,39 @@ static int rtl8169_rx_interrupt(struct net_device=
 *dev,
>  	return count;
>  }
> =20
> +static void rtl_napi_cond_schedule(struct rtl8169_private *tp, u16 statu=
s)
> +{
> +	if (status & tp->napi_event) {
> +		void __iomem *ioaddr =3D tp->mmio_addr;
> +
> +		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
> +		mmiowb();
> +		napi_schedule(&tp->napi);
> +	}
> +}
> +
>  static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
>  {
>  	struct net_device *dev =3D dev_instance;
>  	struct rtl8169_private *tp =3D netdev_priv(dev);
>  	void __iomem *ioaddr =3D tp->mmio_addr;
>  	int handled =3D 0;
> -	int status;
> +	u16 status;
> =20
>  	/* loop handling interrupts until we have no new ones or
>  	 * we hit a invalid/hotplug case.
>  	 */
>  	status =3D RTL_R16(IntrStatus);
>  	while (status && status !=3D 0xffff) {
> +		u16 acked;
> +
>  		handled =3D 1;
> =20
> +		acked =3D (status & RxFIFOOver) ? (status | RxOverflow) : status;
> +		acked &=3D ~tp->napi_event;
> +
> +		RTL_W16(IntrStatus, acked);
> +
>  		/* Handle all of the error cases first. These will reset
>  		 * the chip, so just exit the loop.
>  		 */
> @@ -4557,7 +4575,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void =
*dev_instance)
> =20
>  		/* Work around for rx fifo overflow */
>  		if (unlikely(status & RxFIFOOver) &&
> -		(tp->mac_version =3D=3D RTL_GIGA_MAC_VER_11)) {
> +		    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_11)) {
>  			netif_stop_queue(dev);
>  			rtl8169_tx_timeout(dev);
>  			break;
> @@ -4571,30 +4589,9 @@ static irqreturn_t rtl8169_interrupt(int irq, void=
 *dev_instance)
>  		if (status & LinkChg)
>  			rtl8169_check_link_status(dev, tp, ioaddr);
> =20
> -		/* We need to see the lastest version of tp->intr_mask to
> -		 * avoid ignoring an MSI interrupt and having to wait for
> -		 * another event which may never come.
> -		 */
> -		smp_rmb();
> -		if (status & tp->intr_mask & tp->napi_event) {
> -			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
> -			tp->intr_mask =3D ~tp->napi_event;
> -
> -			if (likely(napi_schedule_prep(&tp->napi)))
> -				__napi_schedule(&tp->napi);
> -			else
> -				netif_info(tp, intr, dev,
> -					   "interrupt %04x in poll\n", status);
> -		}
> +		rtl_napi_cond_schedule(tp, status);
> =20
> -		/* We only get a new MSI interrupt when all active irq
> -		 * sources on the chip have been acknowledged. So, ack
> -		 * everything we've seen and check if new sources have become
> -		 * active to avoid blocking all interrupts from the chip.
> -		 */
> -		RTL_W16(IntrStatus,
> -			(status & RxFIFOOver) ? (status | RxOverflow) : status);
> -		status =3D RTL_R16(IntrStatus);
> +		break;
>  	}
> =20
>  	return IRQ_RETVAL(handled);
> @@ -4607,22 +4604,19 @@ static int rtl8169_poll(struct napi_struct *napi,=
 int budget)
>  	void __iomem *ioaddr =3D tp->mmio_addr;
>  	int work_done;
> =20
> +
> +	RTL_W16(IntrStatus, tp->napi_event);
> +
>  	work_done =3D rtl8169_rx_interrupt(dev, tp, ioaddr, (u32) budget);
>  	rtl8169_tx_interrupt(dev, tp, ioaddr);
> =20
>  	if (work_done < budget) {
>  		napi_complete(napi);
> =20
> -		/* We need for force the visibility of tp->intr_mask
> -		 * for other CPUs, as we can loose an MSI interrupt
> -		 * and potentially wait for a retransmit timeout if we don't.
> -		 * The posted write to IntrMask is safe, as it will
> -		 * eventually make it to the chip and we won't loose anything
> -		 * until it does.
> -		 */
> -		tp->intr_mask =3D 0xffff;
> -		smp_wmb();
>  		RTL_W16(IntrMask, tp->intr_event);
> +		mmiowb();
> +
> +		rtl_napi_cond_schedule(tp, RTL_R16(IntrStatus));
>  	}
> =20
>  	return work_done;
>=20

--w7PDEPdKQumQfZlR
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkuiHWAACgkQfKHnntdSXjS7rQQAtDCrjuaGRELe7UOGZtVhTthm
Rs4WBfVav3T0q4754aGT16pxCPKfQpFq4PaX334lV7eKzK8ipwl0t9CZekpiCj5y
XI/F986X8cQiqV9L/lj+3e/5cvK4VBveJSNI8jboRmwrEUsbkJvU49t88k1sWVRs
4viJuxM0InN/KRcNc/c=
=pz2Y
-----END PGP SIGNATURE-----

--w7PDEPdKQumQfZlR--
