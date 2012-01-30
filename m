From: Viral Mehta <viral.vkm@gmail.com>
Subject: Re: [RFC PATCH V3 04/16] netback: switch to per-cpu scratch space.
Date: Mon, 30 Jan 2012 11:49:11 -0500
Message-ID: <CANX6Dak_1VQ1J8hRK+yd1-FmGOnd75BkNm2uUVKd_TNTiNLtxg@mail.gmail.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
	<1327934734-8908-5-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	ian.campbell@citrix.com, konrad.wilk@oracle.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:47698 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752975Ab2A3QtN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 11:49:13 -0500
Received: by wics10 with SMTP id s10so3605679wic.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 08:49:11 -0800 (PST)
In-Reply-To: <1327934734-8908-5-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Jan 30, 2012 at 9:45 AM, Wei Liu <wei.liu2@citrix.com> wrote:
>
> =A0 =A0 =A0 =A0skb_queue_head_init(&rxq);
> @@ -534,13 +527,16 @@ void xen_netbk_rx_action(struct xen_netbk *netb=
k)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 BUG_ON(npo.meta_prod > ARRAY_SIZE(netbk->meta));
> + =A0 =A0 =A0 BUG_ON(npo.meta_prod > MAX_PENDING_REQS);

While you are already here,
how about having WARN_ON() ?

>
> - =A0 =A0 =A0 if (!npo.copy_prod)
> + =A0 =A0 =A0 if (!npo.copy_prod) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_cpu_ptr(gco);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_cpu_ptr(m);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 BUG_ON(npo.copy_prod > ARRAY_SIZE(netbk->grant_copy_op)=
);
> - =A0 =A0 =A0 ret =3D HYPERVISOR_grant_table_op(GNTTABOP_copy, &netbk=
->grant_copy_op,
> + =A0 =A0 =A0 BUG_ON(npo.copy_prod > (2 * XEN_NETIF_RX_RING_SIZE));

And may be here, too...

If there is serious bug, may be system will crash at a later point
But, IMHO, WARN_ON() is the correct function for drivers at least.

> + =A0 =A0 =A0 ret =3D HYPERVISOR_grant_table_op(GNTTABOP_copy, gco,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0npo.copy_prod);
> =A0 =A0 =A0 =A0BUG_ON(ret !=3D 0);
>
--=20
Thanks,
Viral Mehta
