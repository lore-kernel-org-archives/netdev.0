From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5] Add loopback checkpoint support
Date: Tue, 16 Feb 2010 17:09:15 +0100
Message-ID: <1266336555.3045.57.camel@edumazet-laptop>
References: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
	 <1266336187-19105-5-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:48574 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933033Ab0BPQJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 11:09:27 -0500
Received: by bwz19 with SMTP id 19so4515082bwz.28
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2010 08:09:25 -0800 (PST)
In-Reply-To: <1266336187-19105-5-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 f=C3=A9vrier 2010 =C3=A0 08:03 -0800, Dan Smith a =C3=A9cri=
t :
> Adds a small ndo_checkpoint() handler for loopback devices to write t=
he
> name and addresses like other interfaces.
>=20
> Signed-off-by: Dan Smith <danms@us.ibm.com>
> ---
>  drivers/net/loopback.c |   41 ++++++++++++++++++++++++++++++++++++++=
---
>  1 files changed, 38 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index b9fcc98..816a527 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -57,6 +57,8 @@
>  #include <linux/ip.h>
>  #include <linux/tcp.h>
>  #include <linux/percpu.h>
> +#include <linux/checkpoint.h>
> +#include <linux/checkpoint_hdr.h>
>  #include <net/net_namespace.h>
> =20
>  struct pcpu_lstats {
> @@ -153,10 +155,43 @@ static void loopback_dev_free(struct net_device=
 *dev)
>  	free_netdev(dev);
>  }
> =20

Dont you have a #ifdef CONFIG_CHECKPOINT or something to avoid this for
small machines ?

> +static int loopback_checkpoint(struct ckpt_ctx *ctx, struct net_devi=
ce *dev)
> +{
> +	struct ckpt_hdr_netdev *h;
> +	struct ckpt_netdev_addr *addrs;
> +	int ret;
> +
> +	h =3D ckpt_netdev_base(ctx, dev, &addrs);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	h->type =3D CKPT_NETDEV_LO;
> +
> +	ret =3D ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret =3D ckpt_write_buffer(ctx, dev->name, IFNAMSIZ);
> +	if (ret < 0)
> +		goto out;
> +
> +	if (h->inet_addrs > 0) {
> +		int len =3D (sizeof(struct ckpt_netdev_addr) * h->inet_addrs);
> +		ret =3D ckpt_write_buffer(ctx, addrs, len);
> +	}
> +
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	kfree(addrs);
> +
> +	return ret;
> +}
> +
>  static const struct net_device_ops loopback_ops =3D {
> -	.ndo_init      =3D loopback_dev_init,
> -	.ndo_start_xmit=3D loopback_xmit,
> -	.ndo_get_stats =3D loopback_get_stats,
> +	.ndo_init       =3D loopback_dev_init,
> +	.ndo_start_xmit =3D loopback_xmit,
> +	.ndo_get_stats  =3D loopback_get_stats,
> +	.ndo_checkpoint =3D loopback_checkpoint,
>  };
> =20
>  /*


