From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Thu, 10 Mar 2016 11:02:28 -0800
Message-ID: <CAM_iQpWWbj00H-cKvpeaKq6mVWK_D2CFuarXiE6YDQeQX5JupA@mail.gmail.com>
References: <20160310102018.GA21154@uranus.lan>
	<20160310110324.GB21154@uranus.lan>
	<20160310150920.GC21154@uranus.lan>
	<20160310.130138.1302349043066531127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cyrill Gorcunov <gorcunov@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	solar@openwall.com, Vasily Averin <vvs@virtuozzo.com>,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:33673 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbcCJTC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 14:02:29 -0500
In-Reply-To: <20160310.130138.1302349043066531127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 10:01 AM, David Miller <davem@davemloft.net> wrote:
> I'm tempted to say that we should provide these notifier handlers with
> the information they need, explicitly, to handle this case.
>
> Most intdev notifiers actually want to know the individual addresses
> that get removed, one by one.  That's handled by the existing
> NETDEV_DOWN event and the ifa we pass to that.
>
> But some, like this netfilter masq case, would be satisfied with a
> single event that tells them the whole inetdev instance is being torn
> down.  Which is the case we care about here.
>
> We currently don't use NETDEV_UNREGISTER for inetdev notifiers, so
> maybe we could use that.
>
> And that is consistent with the core netdev notifier that triggers
> this call chain in the first place.
>
> Roughly, something like this:
>
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 8c3df2c..6eee5cb 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -292,6 +292,11 @@ static void inetdev_destroy(struct in_device *in_dev)
>
>         in_dev->dead = 1;
>
> +       if (in_dev->ifa_list)
> +               blocking_notifier_call_chain(&inetaddr_chain,
> +                                            NETDEV_UNREGISTER,
> +                                            in_dev->ifa_list);
> +
>         ip_mc_destroy_dev(in_dev);


Hmm, but inetdev_destroy() is only called when NETDEV_UNREGISTER
is happening and masq already registers a netdev notifier...



>
>         while ((ifa = in_dev->ifa_list) != NULL) {
> diff --git a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
> index c6eb421..1bb8026 100644
> --- a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
> +++ b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
> @@ -111,6 +111,10 @@ static int masq_inet_event(struct notifier_block *this,
>         struct net_device *dev = ((struct in_ifaddr *)ptr)->ifa_dev->dev;
>         struct netdev_notifier_info info;
>
> +       if (event != NETDEV_UNREGISTER)
> +               return NOTIFY_DONE;
> +       event = NETDEV_DOWN;
> +
>         netdev_notifier_info_init(&info, dev);
>         return masq_device_event(this, event, &info);
>  }

If masq really doesn't care about inetdev destroy or inetaddr removal,
we should just remove its inetaddr notifier.
