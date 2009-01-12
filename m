From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] smc-ultra: get rid of "eth%d" message
Date: Mon, 12 Jan 2009 08:24:49 -0800
Message-ID: <20090112082449.5cfcd2cb@extreme>
References: <4969CFF2.9020202@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Gortmaker <p_gortmaker@yahoo.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?TsOpbWV0aCBNw6FydG9u?= <nm127@freemail.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57016 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753009AbZALQYv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 11:24:51 -0500
In-Reply-To: <4969CFF2.9020202@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 11 Jan 2009 11:54:42 +0100
N=C3=A9meth M=C3=A1rton <nm127@freemail.hu> wrote:

> From: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>
>=20
> Print out the dev->name only after register_netdev().  If the dev->na=
me is
> printk()ed out before calling register_netdev() the result will be "e=
th%d"
> in the dmesg instead of "eth0".
>=20
> Signed-off-by: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>
> ---
> --- linux-2.6.28/drivers/net/smc-ultra.c.orig	2009-01-10 20:57:36.000=
000000 +0100
> +++ linux-2.6.28/drivers/net/smc-ultra.c	2009-01-10 20:59:48.00000000=
0 +0100
> @@ -228,9 +228,6 @@ static int __init ultra_probe1(struct ne
>  	for (i =3D 0; i < 6; i++)
>  		dev->dev_addr[i] =3D inb(ioaddr + 8 + i);
>=20
> -	printk("%s: %s at %#3x, %s", dev->name, model_name,
> -	       ioaddr, print_mac(mac, dev->dev_addr));
> -
>  	/* Switch from the station address to the alternate register set an=
d
>  	   read the useful registers there. */
>  	outb(0x80 | reg4, ioaddr + 4);
> @@ -253,8 +250,10 @@ static int __init ultra_probe1(struct ne
>  		irq =3D irqmap[((irqreg & 0x40) >> 4) + ((irqreg & 0x0c) >> 2)];
>=20
>  		if (irq =3D=3D 0) {
> -			printk(", failed to detect IRQ line.\n");
> -			retval =3D  -EAGAIN;
> +			printk(KERN_ERR "%s at %#3x, %s, "
> +			       "failed to detect IRQ line.\n", model_name,
> +			       ioaddr, print_mac(mac, dev->dev_addr));
> +			retval =3D -EAGAIN;
>  			goto out;
>  		}
>  		dev->irq =3D irq;
> @@ -280,22 +279,19 @@ static int __init ultra_probe1(struct ne
>=20
>  	ei_status.mem =3D ioremap(dev->mem_start, (ei_status.stop_page - ST=
ART_PG)*256);
>  	if (!ei_status.mem) {
> -		printk(", failed to ioremap.\n");
> -		retval =3D  -ENOMEM;
> +		printk(KERN_ERR "%s at %#3x, %s, failed to ioremap.\n",
> +		       model_name, ioaddr, print_mac(mac, dev->dev_addr));

Use dev_err() instead, it gives useful PCI information.

> +		retval =3D -ENOMEM;
>  		goto out;
>  	}
>=20
>  	dev->mem_end =3D dev->mem_start + (ei_status.stop_page - START_PG)*=
256;
>=20
>  	if (piomode) {
> -		printk(",%s IRQ %d programmed-I/O mode.\n",
> -			   eeprom_irq ? "EEPROM" : "assigned ", dev->irq);
>  		ei_status.block_input =3D &ultra_pio_input;
>  		ei_status.block_output =3D &ultra_pio_output;
>  		ei_status.get_8390_hdr =3D &ultra_pio_get_hdr;
>  	} else {
> -		printk(",%s IRQ %d memory %#lx-%#lx.\n", eeprom_irq ? "" : "assign=
ed ",
> -			   dev->irq, dev->mem_start, dev->mem_end-1);
>  		ei_status.block_input =3D &ultra_block_input;
>  		ei_status.block_output =3D &ultra_block_output;
>  		ei_status.get_8390_hdr =3D &ultra_get_8390_hdr;
> @@ -311,6 +307,21 @@ static int __init ultra_probe1(struct ne
>  	retval =3D register_netdev(dev);
>  	if (retval)
>  		goto out;
> +
> +	if (piomode) {
> +		printk(KERN_INFO "%s: %s at %#3x, %s,"
> +			"%s IRQ %d programmed-I/O mode.\n",
> +			dev->name, model_name, ioaddr,
> +			print_mac(mac, dev->dev_addr),
> +			eeprom_irq ? " EEPROM" : " assigned", dev->irq);
> +	} else {
> +		printk(KERN_INFO "%s: %s at %#3x, %s,"
> +			"%s IRQ %d memory %#lx-%#lx.\n",
> +			dev->name, model_name, ioaddr,
> +			print_mac(mac, dev->dev_addr),
> +			eeprom_irq ? "" : " assigned",
> +			dev->irq, dev->mem_start, dev->mem_end-1);
> +	}
>
dev_info?
