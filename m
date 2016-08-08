From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vti: flush x-netns xfrm cache when vti interface
 is removed
Date: Mon, 08 Aug 2016 15:35:22 -0700 (PDT)
Message-ID: <20160808.153522.275623399426494584.davem@davemloft.net>
References: <1470694965-17978-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34793 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbcHHWfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 18:35:32 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so25783772pfb.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 15:35:32 -0700 (PDT)
In-Reply-To: <1470694965-17978-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Mon,  8 Aug 2016 18:22:45 -0400

> @@ -392,6 +393,17 @@ static int vti_tunnel_init(struct net_device *dev)
>  	return ip_tunnel_init(dev);
>  }
>  
> +static void vti_tunnel_uninit(struct net_device *dev)
> +{
> +	struct ip_tunnel *tunnel = netdev_priv(dev);
> +	struct net *net = tunnel->net;
> +
> +	ip_tunnel_uninit(dev);
> +
> +	if (!net_eq(net, dev_net(dev)))
> +		xfrm_garbage_collect(net);
> +}

Like the normal netns, this netns should be expunged from the
flow cache on interface down, not uninit.

So like the existing facilities do, you should add a NETDEV_DOWN
notifier that flushes tunnel->net if necessary.
