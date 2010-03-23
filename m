From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] rps: memory leak due to forget to release rx queues
Date: Mon, 22 Mar 2010 23:44:08 -0700
Message-ID: <65634d661003222344s662000e8ode1b4f49ff73b345@mail.gmail.com>
References: <4BA85A33.6050004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:16938 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753720Ab0CWGoL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 02:44:11 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [10.3.21.6])
	by smtp-out.google.com with ESMTP id o2N6i988021502
	for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 07:44:09 +0100
Received: from fxm6 (fxm6.prod.google.com [10.184.13.6])
	by hpaq6.eem.corp.google.com with ESMTP id o2N6i8sk012160
	for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 07:44:09 +0100
Received: by fxm6 with SMTP id 6so128960fxm.18
        for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 23:44:08 -0700 (PDT)
In-Reply-To: <4BA85A33.6050004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/3/22 Changli Gao <xiaosuo@gmail.com>:
> memory leak due to forget to release rx queues.
>
> rx queues is allocated in alloc_netdev_mq(), but they aren't released=
 in
> free_netdev(), and the field rps_map is also miss.
>

rx_queues can't be free from free_netdev since they contain kobjects
(only freed when refcnt goes to zero).  They should be freed when the
device kobject is freed (netdev_unregister_kobject).

Tom

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
> net/core/dev.c | 8 ++++++++
> 1 file changed, 8 insertions(+)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index c0e2608..51b86e0 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5746,6 +5746,14 @@ void free_netdev(struct net_device *dev)
>
> =A0 =A0 =A0 =A0release_net(dev_net(dev));
>
> + =A0 =A0 =A0 if (dev->num_rx_queues) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < dev->num_rx_queues; i=
++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(dev->_rx[i].rps_m=
ap);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(dev->_rx);
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0kfree(dev->_tx);
>
> =A0 =A0 =A0 =A0/* Flush device addresses */
>
>
>
