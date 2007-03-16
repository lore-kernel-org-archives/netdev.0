From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 3/6] IrDA: IrLAP raw mode
Date: Fri, 16 Mar 2007 11:02:04 +0100
Message-ID: <200703161102.06417.netdev@axxeo.de>
References: <20070314192331.GD3397@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	irda-users@lists.sourceforge.net, Jean Tourrilhes <jt@hpl.hp.com>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:2019 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753448AbXCPKPq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 06:15:46 -0400
In-Reply-To: <20070314192331.GD3397@sortiz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Samuel,

Samuel Ortiz wrote:
> This patch allows us to bypass the IrDA stack down to the IrLAP level.
> Sending and receiving frames is done through a character device.
> This is useful for e.g. doing real IrDA sniffing, testing external IrDA
> stacks and for Lirc (once I will add the framing disabling switch).

Nice!
 
> --- /dev/null
> +++ b/include/net/irda/irlap_raw.h
> @@ -0,0 +1,27 @@
> +/*
> + * Copyright (C) 2007 Samuel Ortiz (samuel@sortiz.org)
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation, version 2.
> + *
> + */
> +
> +#ifndef _IRLAP_RAW_H
> +#define _IRLAP_RAW_H
> +
> +#ifdef CONFIG_IRDA_RAW
> +
> +int irlap_raw_recv_frame(struct sk_buff *skb, struct net_device *dev);
> +int irlap_raw_register_device(struct net_device * dev);
> +int irlap_raw_unregister_device(struct net_device * dev);
> +
> +#else
> +
> +#define irlap_raw_recv_frame(skbuff, netdev)
> +#define irlap_raw_register_device(netdev)
> +#define irlap_raw_unregister_device(netdev)

This stuff is usually done this way (functions, which just check arguments and do nothing):

static inline int irlap_raw_recv_frame(struct sk_buff *skb, struct net_device *dev)
{
	if (skb == NULL)
		return -EINVAL;

	if (dev->atalk_ptr == NULL)
		return -ENODEV;

	return 0;
}

static inline int irlap_raw_register_device(struct net_device * dev)
{
	if (dev == NULL)
		return -ENODEV;
	return 0;
}

statice inline int irlap_raw_unregister_device(struct net_device * dev)
{
	if (dev == NULL)
		return -ENODEV;
	return 0;
}


> --- a/net/irda/irlap_event.c
> +++ b/net/irda/irlap_event.c
> @@ -241,6 +241,11 @@ void irlap_do_event(struct irlap_cb *self, IRLAP_EVENT event,
>  	if (!self || self->magic != LAP_MAGIC)
>  		return;
>  
> +       if (self->raw_mode)
> +               return;
> +#endif
> +

I would suggest a small helper function here, which compiles into a constant, 
if raw_mode is not compiled in.

like

#ifdef CONFIG_IRDA_RAW
static inline int irlap_raw_mod(struct irlap_cb *self)
{
	return self->raw_mode;
}
#else
static inline int irlap_raw_mod(struct irlap_cb *self)
{
	return 0;
}
#endif


Best Regards

Ingo Oeser
