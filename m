From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next v4] ipvlan: Initial check-in of the IPVLAN driver.
Date: Wed, 26 Nov 2014 15:41:53 +0900
Message-ID: <54757631.8090604@lab.ntt.co.jp>
References: <1416812866-13401-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Mahesh Bandewar <maheshb@google.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:59074 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbaKZGm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 01:42:56 -0500
In-Reply-To: <1416812866-13401-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mahesh,

I found that deleting the last ipvlan device triggers WARN_ON() in
rtmsg_ifinfo().
ipvlan_nl_fillinfo() seems to return -EINVAL in that case.

> +static int ipvlan_nl_fillinfo(struct sk_buff *skb,
> +			      const struct net_device *dev)
> +{
> +	struct ipvl_dev *ipvlan = netdev_priv(dev);
> +	struct ipvl_port *port = ipvlan_port_get_rtnl(ipvlan->phy_dev);
> +	int ret = -EINVAL;
> +
> +	if (!port)
> +		goto err;
> +
> +	ret = -EMSGSIZE;
> +	if (nla_put_u16(skb, IFLA_IPVLAN_MODE, port->mode))
> +		goto err;
> +
> +	return 0;
> +
> +err:
> +	return ret;
> +}

rollback_registered_many() calls rtmsg_ifinfo() after calling ndo_uninit().
ndo_uninit() (ipvlan_uninit() -> ipvlan_port_destroy() ->
netdev_rx_handler_unregister()) sets rx_handler_data into NULL.
So, we cannot dereference "port" in ipvlan_nl_fillinfo().

Maybe "mode" should belong to struct ipvl_dev?

Thanks,
Toshiaki Makita
