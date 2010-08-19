From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Thu, 19 Aug 2010 08:18:16 +0200
Message-ID: <1282198696.2328.9.camel@edumazet-laptop>
References: <E1OlwR9-0004FI-00.xeb-mail-ru@f275.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33694 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab0HSGSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 02:18:21 -0400
Received: by wwi17 with SMTP id 17so1970060wwi.1
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 23:18:19 -0700 (PDT)
In-Reply-To: <E1OlwR9-0004FI-00.xeb-mail-ru@f275.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 ao=C3=BBt 2010 =C3=A0 08:09 +0400, Dmitry Kozlov a =C3=A9cr=
it :
> This patch contains:
> 1. pptp driver
> 2. gre demultiplexer driver for demultiplexing gre packets with diffe=
rent gre version
>    so ip_gre and pptp may coexists
> 3. ip_gre modification
> 4. other stuff
>=20

Almost done ;)

> =20
> +GRE DEMULTIPLEXER DRIVER
> +M:	Dmitry Kozlov <xeb@xxxxxxx>
> +L:	netdev@xxxxxxxxxxxxxxx
> +S:	Maintained
> +F:	net/ipv4/gre.c
> +F:	include/net/gre.h
> +
> +PPTP DRIVER
> +M:	Dmitry Kozlov <xeb@xxxxxxx>
> +L:	netdev@xxxxxxxxxxxxxxx
> +S:	Maintained
> +F:	drivers/net/pptp.c
> +W:	http://sourceforge.net/projects/accel-pptp
> +


Please fill correct addresses, not xxxxxx

> +
> +static int __init pptp_init_module(void)
> +{
> +	int err =3D 0;
> +	pr_info("PPTP driver version " PPTP_DRIVER_VERSION "\n");
> +
> +	if (gre_add_protocol(&gre_pptp_protocol, GREPROTO_PPTP) < 0) {
> +		pr_err("PPTP: can't add protocol\n");
> +		goto out;
> +	}
> +
> +	err =3D proto_register(&pptp_sk_proto, 0);
> +	if (err) {
> +		pr_err("PPTP: can't register sk_proto\n");
> +		goto out_inet_del_protocol;
> +	}
> +
> +	err =3D register_pppox_proto(PX_PROTO_PPTP, &pppox_pptp_proto);
> +	if (err) {
> +		pr_err("PPTP: can't register pppox_proto\n");
> +		goto out_unregister_sk_proto;
> +	}
> +
+ callid_sock =3D (struct pppox_sock **)__vmalloc((MAX_CALLID + 1) * si=
zeof(void *), GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);

No need for the cast

Please split this to :

	callid_sock =3D __vmalloc((MAX_CALLID + 1) * sizeof(void *),
				GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);


> +	if (!callid_sock) {
> +		pr_err("PPTP: cann't allocate memory\n");
> +		goto out_unregister_pppox_proto;
> +	}
> +
> +out:
> +	return err;
> +out_unregister_pppox_proto:
> +	unregister_pppox_proto(PX_PROTO_PPTP);
> +out_unregister_sk_proto:
> +	proto_unregister(&pptp_sk_proto);
> +out_inet_del_protocol:
> +	gre_del_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
> +	return err;
> +}


You should attempt the vmalloc() at the start of this function (before
proto_register() and register_pppox_proto()), or
maybe another cpu can enter your code and try to dereference null
pointer. Dont forget to vfree() in case of error unwinding.

Thanks


