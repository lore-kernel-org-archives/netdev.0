From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 5/5] veth: implement ndo_set_rx_headroom
Date: Tue, 23 Feb 2016 11:21:26 -0800
Message-ID: <CAOrHB_BzDhT_MTXPoEm-AaaVA++u_p_AdapMygMuw0gzgDUcyw@mail.gmail.com>
References: <cover.1456163137.git.pabeni@redhat.com>
	<193cf433bb4b8dac52ca1a76477b651c47e01ed3.1456163137.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:38519 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754364AbcBWTV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 14:21:29 -0500
Received: from mfilter49-d.gandi.net (mfilter49-d.gandi.net [217.70.178.180])
	by relay4-d.mail.gandi.net (Postfix) with ESMTP id AFAF4172098
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 20:21:28 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
	by mfilter49-d.gandi.net (mfilter49-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id dtebMrH_46lY for <netdev@vger.kernel.org>;
	Tue, 23 Feb 2016 20:21:27 +0100 (CET)
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	(Authenticated sender: pshelar@ovn.org)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 2E4461720B8
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 20:21:27 +0100 (CET)
Received: by mail-io0-f172.google.com with SMTP id l127so223432814iof.3
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 11:21:27 -0800 (PST)
In-Reply-To: <193cf433bb4b8dac52ca1a76477b651c47e01ed3.1456163137.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 4:53 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> The rx headroom for veth dev is the peer device needed_headroom.
> Avoid ping-pong updates setting the private flag IFF_PHONY_HEADROOM.
>
> This avoids skb head reallocation when forwarding from a veth dev
> towards a device adding some kind of encapsulation.
>
> When forwarding frames below the MTU size towards a vxlan device,
> this gives about 10% performance speed-up when OVS is used to connect
> the veth and the vxlan device and a little more when using a
> plain Linux bridge.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  drivers/net/veth.c | 26 ++++++++++++++++++++++++++
>  1 file changed, 26 insertions(+)
>
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index ba21d07..4f30a6a 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -35,6 +35,7 @@ struct pcpu_vstats {
>  struct veth_priv {
>         struct net_device __rcu *peer;
>         atomic64_t              dropped;
> +       unsigned                requested_headroom;
>  };
>
>  /*
> @@ -271,6 +272,29 @@ static int veth_get_iflink(const struct net_device *dev)
>         return iflink;
>  }
>
> +static void veth_set_rx_headroom(struct net_device *dev, int new_hr)
> +{
> +       struct veth_priv *peer_priv, *priv = netdev_priv(dev);
> +       struct net_device *peer;
> +
> +       if (new_hr < 0)
> +               new_hr = 0;
> +
> +       rcu_read_lock();
> +       peer = rcu_dereference(priv->peer);
> +       if (unlikely(!peer))
> +               goto out;
> +
> +       peer_priv = netdev_priv(peer);
> +       priv->requested_headroom = new_hr;
> +       new_hr = max(priv->requested_headroom, peer_priv->requested_headroom);
> +       dev->needed_headroom = new_hr;
> +       peer->needed_headroom = new_hr;
> +
> +out:
> +       rcu_read_unlock();
> +}
> +
I am not sure why new priv->requested_headroom is introduced. I think
you can just compare new_hr with dev->needed_headroom and set the max
value to both devices.
