From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH V3 10/16] netback: rework of per-cpu scratch space.
Date: Tue, 31 Jan 2012 02:25:14 +0100
Message-ID: <CAL4WiirrQ+2PqojQ9dnGRF16cxx-1QNRWqcMkVqqZSZwvWC58Q@mail.gmail.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
	<1327934734-8908-11-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	ian.campbell@citrix.com, konrad.wilk@oracle.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44524 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111Ab2AaBZP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 20:25:15 -0500
Received: by mail-iy0-f174.google.com with SMTP id b35so156079iac.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 17:25:15 -0800 (PST)
In-Reply-To: <1327934734-8908-11-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30 janvier 2012 15:45, Wei Liu <wei.liu2@citrix.com> a =E9crit :
> If we allocate large arrays in per-cpu section, multi-page ring
> feature is likely to blow up the per-cpu section. So avoid allocating
> large arrays, instead we only store pointers to scratch spaces in
> per-cpu section.
>
> CPU hotplug event is also taken care of.
>

> =A0}
>
> +static int __create_percpu_scratch_space(unsigned int cpu)
> +{
> + =A0 =A0 =A0 per_cpu(tx_copy_ops, cpu) =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vzalloc(sizeof(struct gnttab_copy) * MA=
X_PENDING_REQS);
> +
> + =A0 =A0 =A0 per_cpu(grant_copy_op, cpu) =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vzalloc(sizeof(struct gnttab_copy)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 2 * XEN_NETIF_RX_RING=
_SIZE);
> +
> + =A0 =A0 =A0 per_cpu(meta, cpu) =3D vzalloc(sizeof(struct xenvif_rx_=
meta)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0* 2 * XEN_NETIF_RX_RING_SIZE);
> +
> + =A0 =A0 =A0 if (!per_cpu(tx_copy_ops, cpu) ||
> + =A0 =A0 =A0 =A0 =A0 !per_cpu(grant_copy_op, cpu) ||
> + =A0 =A0 =A0 =A0 =A0 !per_cpu(meta, cpu))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 return 0;
> +}
> +

Problem is you lost NUMA awareness here.

Please check vzalloc_node()
