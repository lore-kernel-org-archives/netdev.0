From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH/RFC] make unregister_netdev() delete more than 4 interfaces
 per second
Date: Sun, 18 Oct 2009 06:26:22 +0200
Message-ID: <4ADA98EE.9040509@gmail.com>
References: <20091017221857.GG1925@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49245 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbZJRE0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 00:26:24 -0400
In-Reply-To: <20091017221857.GG1925@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise a =E9crit :
> Hi folks,
>=20
> Below is a patch that changes the interaction between netdev_wait_all=
refs()=20
> and dev_put() to replace an msleep(250) with a wait_event() on the fi=
nal=20
> dev_put().  This change reduces the time spent sleeping during an=20
> unregister_netdev(), causing the system to go from <1% CPU time to so=
mething=20
> more CPU bound (50+% in a test vm).  This increases the speed of a bu=
lk=20
> unregister_netdev() from 4 interfaces per second to over 500 per seco=
nd on=20
> my test system.  The requirement comes from handling thousands of L2T=
P=20
> sessions where a tunnel flap results in all interfaces being torn dow=
n at=20
> one time.
>=20
> Note that there is still more work to be done in this area.
>=20
> 		-ben
> =20

> +DECLARE_WAIT_QUEUE_HEAD(netdev_refcnt_wait);
> +
> +void dev_put(struct net_device *dev)
> +{
> +        if (atomic_dec_and_test(&dev->refcnt))
> +		wake_up(&netdev_refcnt_wait);
> +}
> +EXPORT_SYMBOL(dev_put);
> +


Unfortunatly this slow down fast path by an order of magnitude.

atomic_dec() is pretty cheap (and eventually could use a per_cpu thing,
now we have a new and sexy per_cpu allocator), but atomic_dec_and_test(=
)
is not that cheap and more important forbids a per_cpu conversion.

