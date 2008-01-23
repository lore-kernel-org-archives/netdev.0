From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: [Cbe-oss-dev] [PATCH 4/5] spidernet: fix error interrupt handling
Date: Wed, 23 Jan 2008 14:55:33 +0100
Message-ID: <200801231455.34027.jens@de.ibm.com>
References: <20080111.154614.-345477188.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>, linas@austin.ibm.com,
	netdev@vger.kernel.org
To: cbe-oss-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:50703 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132AbYAWNzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 08:55:39 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0NDtcM8041984
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:55:38 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0NDtc7s4858086
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:55:38 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0NDtYhI020790
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:55:34 GMT
In-Reply-To: <20080111.154614.-345477188.kouish@swc.toshiba.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 11 January 2008, Ishizaki Kou wrote:
> In addition to the value of GHIINT0STS, spidernet interrupt handler
> should check the values of GHIINT1STS/GHIINT2STS registers at the
> beginning of spider_net_interrupt() so as not to drop error
> interrupts.
>=20
> GHIINT1STS/GHIINT2STS registers indicates some of erroneous condition=
s
> in spidernet, and a few bits of GHIINT0STS register reflects these
> conditions. But GHIINT0MSK masks these bits, so you should check thes=
e
> conditions by reading GHIINT1STS/GHIINT2STS registers directly.
>=20
> Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>

Acked-by: Jens Osterkamp <jens@de.ibm.com>

>=20
> Index: linux-powerpc-git/drivers/net/spider_net.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-powerpc-git.orig/drivers/net/spider_net.c
> +++ linux-powerpc-git/drivers/net/spider_net.c
> @@ -1415,18 +1415,12 @@ spider_net_link_reset(struct net_device=20
>   * found when an interrupt is presented
>   */
>  static void
> -spider_net_handle_error_irq(struct spider_net_card *card, u32 status=
_reg)
> +spider_net_handle_error_irq(struct spider_net_card *card, u32 status=
_reg,
> +			    u32 error_reg1, u32 error_reg2)
>  {
> -	u32 error_reg1, error_reg2;
>  	u32 i;
>  	int show_error =3D 1;
>=20
> -	error_reg1 =3D spider_net_read_reg(card, SPIDER_NET_GHIINT1STS);
> -	error_reg2 =3D spider_net_read_reg(card, SPIDER_NET_GHIINT2STS);
> -
> -	error_reg1 &=3D SPIDER_NET_INT1_MASK_VALUE;
> -	error_reg2 &=3D SPIDER_NET_INT2_MASK_VALUE;
> -
>  	/* check GHIINT0STS ************************************/
>  	if (status_reg)
>  		for (i =3D 0; i < 32; i++)
> @@ -1656,12 +1650,15 @@ spider_net_interrupt(int irq, void *ptr)
>  {
>  	struct net_device *netdev =3D ptr;
>  	struct spider_net_card *card =3D netdev_priv(netdev);
> -	u32 status_reg;
> +	u32 status_reg, error_reg1, error_reg2;
>=20
>  	status_reg =3D spider_net_read_reg(card, SPIDER_NET_GHIINT0STS);
> -	status_reg &=3D SPIDER_NET_INT0_MASK_VALUE;
> +	error_reg1 =3D spider_net_read_reg(card, SPIDER_NET_GHIINT1STS);
> +	error_reg2 =3D spider_net_read_reg(card, SPIDER_NET_GHIINT2STS);
>=20
> -	if (!status_reg)
> +	if (!(status_reg & SPIDER_NET_INT0_MASK_VALUE) &&
> +	    !(error_reg1 & SPIDER_NET_INT1_MASK_VALUE) &&
> +	    !(error_reg2 & SPIDER_NET_INT2_MASK_VALUE))
>  		return IRQ_NONE;
>=20
>  	if (status_reg & SPIDER_NET_RXINT ) {
> @@ -1676,7 +1673,8 @@ spider_net_interrupt(int irq, void *ptr)
>  		spider_net_link_reset(netdev);
>=20
>  	if (status_reg & SPIDER_NET_ERRINT )
> -		spider_net_handle_error_irq(card, status_reg);
> +		spider_net_handle_error_irq(card, status_reg,
> +					    error_reg1, error_reg2);
>=20
>  	/* clear interrupt sources */
>  	spider_net_write_reg(card, SPIDER_NET_GHIINT0STS, status_reg);
> _______________________________________________
> cbe-oss-dev mailing list
> cbe-oss-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/cbe-oss-dev
>=20



--=20

Gru=DF,

Jens

IBM Deutschland Entwicklung GmbH
Vorsitzender des Aufsichtsrats: Martin Jetter
Gesch=E4ftsf=FChrung: Herbert Kircher=20
Sitz der Gesellschaft: B=F6blingen
Registergericht: Amtsgericht Stuttgart, HRB 243294
