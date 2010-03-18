From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH] net: dev_getfirstbyhwtype() optimization
Date: Thu, 18 Mar 2010 14:54:44 -0700
Message-ID: <97949e3e1003181454p362bf73dl2420f33cf72764bb@mail.gmail.com>
References: <1268947645.2894.166.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:62977 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612Ab0CRVzM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 17:55:12 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o2ILt8Mg010468
	for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 22:55:09 +0100
Received: from gxk4 (gxk4.prod.google.com [10.202.11.4])
	by kpbe17.cbf.corp.google.com with ESMTP id o2ILsQ62030965
	for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 14:55:05 -0700
Received: by gxk4 with SMTP id 4so1347056gxk.5
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 14:55:04 -0700 (PDT)
In-Reply-To: <1268947645.2894.166.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reviewed_by: Laurent Chavey <chavey@google.com>


On Thu, Mar 18, 2010 at 2:27 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Use RCU to avoid RTNL use in dev_getfirstbyhwtype()
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 17b1686..0f2e9fc 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -772,14 +772,17 @@ EXPORT_SYMBOL(__dev_getfirstbyhwtype);
>
> =A0struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned =
short type)
> =A0{
> - =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 struct net_device *dev, *ret =3D NULL;
>
> - =A0 =A0 =A0 rtnl_lock();
> - =A0 =A0 =A0 dev =3D __dev_getfirstbyhwtype(net, type);
> - =A0 =A0 =A0 if (dev)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_hold(dev);
> - =A0 =A0 =A0 rtnl_unlock();
> - =A0 =A0 =A0 return dev;
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 for_each_netdev_rcu(net, dev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dev->type =3D=3D type) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_hold(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D dev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 return ret;
> =A0}
> =A0EXPORT_SYMBOL(dev_getfirstbyhwtype);
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
