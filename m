From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] [bridge] Fix double-free in br_add_if.
Date: Fri, 25 Sep 2009 14:33:08 -0700
Message-ID: <20090925143308.7f38227d@s6510>
References: <y>
	<1253910324-19006-1-git-send-email-x@jeffhansen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@jeffhansen.com,
	Dave Miller <davem@davemloft.net>,
	Jeff Hansen <x@jeffhansen.com>
To: Jeff Hansen <x@jeffhansen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39939 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803AbZIYVdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2009 17:33:11 -0400
In-Reply-To: <1253910324-19006-1-git-send-email-x@jeffhansen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Sep 2009 14:25:24 -0600
Jeff Hansen <x@jeffhansen.com> wrote:

> There is a potential double-kfree in net/bridge/br_if.c.  If br_fdb_insert
> fails, then the kobject is put back (which calls kfree due to the kobject
> release), and then kfree is called again on the net_bridge_port.  This
> patch fixes the crash.
> 
> Signed-off-by: Jeff Hansen <x@jeffhansen.com>
> ---
>  net/bridge/br_if.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index eb404dc..1becec1 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -368,7 +368,7 @@ done:
>  int br_add_if(struct net_bridge *br, struct net_device *dev)
>  {
>  	struct net_bridge_port *p;
> -	int err = 0;
> +	int err = 0, kobj_initted = 0;
>  
>  	if (dev->flags & IFF_LOOPBACK || dev->type != ARPHRD_ETHER)
>  		return -EINVAL;
> @@ -391,6 +391,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>  				   SYSFS_BRIDGE_PORT_ATTR);
>  	if (err)
>  		goto err0;
> +	kobj_initted = 1;
>  
>  	err = br_fdb_insert(br, p, dev->dev_addr);
>  	if (err)
> @@ -429,7 +430,8 @@ err0:
>  	dev_set_promiscuity(dev, -1);
>  put_back:
>  	dev_put(dev);
> -	kfree(p);
> +	if (!kobj_initted)
> +		kfree(p);
>  	return err;
>  }
>  

I'll look at it, probably needs fixing, but the code style with condition
variables is out of place in this code.
