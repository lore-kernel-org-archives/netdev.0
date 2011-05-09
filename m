From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] veth: use batched device unregister
Date: Mon, 9 May 2011 08:56:26 +0200
Message-ID: <BANLkTim2e1Gm_jqfY89is-FfRYTu2=G02w@mail.gmail.com>
References: <1304793749.3207.26.camel@edumazet-laptop> <1304838742.3207.45.camel@edumazet-laptop>
 <F57561A93EFF5E88729A8D53@nimrod.local> <7B76F9D75FD26D716624004B@nimrod.local>
 <20110508125028.GK2641@linux.vnet.ibm.com> <B2891EFD056565BBD4DBCE16@nimrod.local>
 <20110508134425.GL2641@linux.vnet.ibm.com> <C449131127D58077CB25C9D8@Ximines.local>
 <20110508144749.GR2641@linux.vnet.ibm.com> <AB9DE9E04289CF29CA79CC67@Ximines.local>
 <20110508154854.GT2641@linux.vnet.ibm.com> <1304888447.3207.66.camel@edumazet-laptop>
 <1304916275.3207.79.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Alex Bligh <alex@alex.org.uk>,
	netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ben Greear <greearb@candelatech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:57827 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab1EIG4r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 02:56:47 -0400
Received: by qyg14 with SMTP id 14so3721919qyg.19
        for <netdev@vger.kernel.org>; Sun, 08 May 2011 23:56:46 -0700 (PDT)
In-Reply-To: <1304916275.3207.79.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/9 Eric Dumazet <eric.dumazet@gmail.com>:
> veth devices dont use the batched device unregisters yet.
>
> Since veth are a pair of devices, it makes sense to use a batch of tw=
o
> unregisters, this roughly divide dismantle time by two.
[...]
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -451,8 +451,16 @@ static void veth_dellink(struct net_device *dev,=
 struct list_head *head)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0priv =3D netdev_priv(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0peer =3D priv->peer;
>
> - =C2=A0 =C2=A0 =C2=A0 unregister_netdevice_queue(dev, head);
> - =C2=A0 =C2=A0 =C2=A0 unregister_netdevice_queue(peer, head);
> + =C2=A0 =C2=A0 =C2=A0 if (head =3D=3D NULL) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LIST_HEAD(list);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* make a batch of=
 two devices to speedup unregister */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unregister_netdevi=
ce_queue(dev, &list);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unregister_netdevi=
ce_queue(peer, &list);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unregister_netdevi=
ce_many(&list);
> + =C2=A0 =C2=A0 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unregister_netdevi=
ce_queue(dev, head);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unregister_netdevi=
ce_queue(peer, head);
> + =C2=A0 =C2=A0 =C2=A0 }

You could change dellink callers to always pass head !=3D NULL. As a
side effect, unregister_netdevice_queue() would do just what its name
suggests.

Best Regards,
Micha=C5=82 Miros=C5=82aw
