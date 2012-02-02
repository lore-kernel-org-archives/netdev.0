From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH V4 02/13] netback: add module unload function.
Date: Thu, 02 Feb 2012 18:08:44 +0100
Message-ID: <1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	ian.campbell@citrix.com, konrad.wilk@oracle.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:49353 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab2BBRIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 12:08:48 -0500
Received: by wgbgn7 with SMTP id gn7so224796wgb.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 09:08:47 -0800 (PST)
In-Reply-To: <1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 16:49 +0000, Wei Liu a =C3=A9crit =
:
> Enables users to unload netback module.
>=20
> Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/common.h  |    1 +
>  drivers/net/xen-netback/netback.c |   14 ++++++++++++++
>  drivers/net/xen-netback/xenbus.c  |    5 +++++
>  3 files changed, 20 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netba=
ck/common.h
> index 288b2f3..372c7f5 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -126,6 +126,7 @@ void xenvif_get(struct xenvif *vif);
>  void xenvif_put(struct xenvif *vif);
> =20
>  int xenvif_xenbus_init(void);
> +void xenvif_xenbus_exit(void);
> =20
>  int xenvif_schedulable(struct xenvif *vif);
> =20
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netb=
ack/netback.c
> index d11205f..3059684 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1670,5 +1670,19 @@ failed_init:
> =20
>  module_init(netback_init);
> =20

While reviewing this code, I can see current netback_init() is buggy.

It assumes all online cpus xen_netbk_group_nr are numbered from 0 to
xen_netbk_group_nr-1

This is not right.

Instead of using :

xen_netbk =3D vzalloc(sizeof(struct xen_netbk) * xen_netbk_group_nr);

You should use a percpu variable to get proper NUMA properties.

And instead of looping like :

for (group =3D 0; group < xen_netbk_group_nr; group++) {

You must use :

for_each_online_cpu(cpu) {
	...
}

[ and also use kthread_create_on_node() instead of kthread_create() ]
