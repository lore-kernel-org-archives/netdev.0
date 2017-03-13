From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v1 for accelerated IPoIB 05/25] IB/ipoib: Support ipoib
 acceleration options callbacks
Date: Mon, 13 Mar 2017 14:10:49 -0600
Message-ID: <20170313201049.GB2738@obsidianresearch.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-6-git-send-email-erezsh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, valex@mellanox.com, leonro@mellanox.com,
        saedm@mellanox.com, erezsh@dev.mellanox.co.il
To: Erez Shitrit <erezsh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:48501 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752980AbdCMUKz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 16:10:55 -0400
Content-Disposition: inline
In-Reply-To: <1489429896-10781-6-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 08:31:16PM +0200, Erez Shitrit wrote:
 
> TODO: We added remote qkey to ipoib_send in order to match send op
> signature.
> In accel mode this param will be used but in regular mode this param is
> redundant. Need to think about better solution.

The flow is backwards, in accel mode the xmit ndo should be owend by
the driver and the driver should call a helper to get all the proper
AH data, including qkey.

> -static int ipoib_dev_init_default(struct net_device *dev, struct ib_device *ca,
> -				  int port)
> +static int ipoib_dev_init_default(struct net_device *dev,
> +				  struct ib_device *hca, int *qp_num)
>  {
> -	struct ipoib_dev_priv *priv = netdev_priv(dev);
> +	struct ipoib_dev_priv *priv = ipoib_priv(dev);
> +
> +	netif_napi_add(dev, &priv->napi, ipoib_poll, NAPI_POLL_WEIGHT);

All these 'default' functions are part of the 'rn driver'. They should
not be calling ipoib_priv, you said you didn't want ipoib_dev_priv
leaking into the drivers.

These _default funcs should use ipoib_dev_priv and all the members of
ipoib_dev_priv that are used exclusively by the 'default'
implementation need to be moved into a dedicated priv struct.

Otherwise the entire scheme become hugely confusing about what in
ipoib_dev_priv is actually valid in accel mode.

I think it would be much easier to maintain if the _default functions were
all in a dedicated files, eg rn_ipoib_ud_verbs.c

I also recommend splitting out the bulk rename of ipoib_priv into a
single patch with a '#define ipoib_priv(dev) netdev_priv(dev)'
shim. That would make this patch much smaller.

IHMO you probably don't need to send the mlx5 stuff until the series
up to here is OK. I think we all understand that mlx5 can implement
this API?

Jason
