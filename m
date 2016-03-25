From: Neil Horman <nhorman@redhat.com>
Subject: Re: [PATCH v2] netpoll: Fix extra refcount release in
 netpoll_cleanup()
Date: Fri, 25 Mar 2016 07:33:42 -0400
Message-ID: <20160325113342.GA21579@hmsreliant.think-freely.org>
References: <20160325025621.32476.93348.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, Alexander Duyck <aduyck@mirantis.com>,
	linux-kernel@vger.kernel.org
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247AbcCYLdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2016 07:33:45 -0400
Content-Disposition: inline
In-Reply-To: <20160325025621.32476.93348.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 09:56:21PM -0500, Bjorn Helgaas wrote:
> netpoll_setup() does a dev_hold() on np->dev, the netpoll device.  If it
> fails, it correctly does a dev_put() but leaves np->dev set.  If we call
> netpoll_cleanup() after the failure, np->dev is still set so we do another
> dev_put(), which decrements the refcount an extra time.
> 
> It's questionable to call netpoll_cleanup() after netpoll_setup() fails,
> but it can be difficult to find the problem, and we can easily avoid it in
> this case.  The extra decrements can lead to hangs like this:
> 
>   unregister_netdevice: waiting for bond0 to become free. Usage count = -3
> 
> Set and clear np->dev at the points where we dev_hold() and dev_put() the
> device.
> 
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> ---
>  net/core/netpoll.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 94acfc8..a57bd17 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -603,7 +603,6 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
>  	const struct net_device_ops *ops;
>  	int err;
>  
> -	np->dev = ndev;
>  	strlcpy(np->dev_name, ndev->name, IFNAMSIZ);
>  	INIT_WORK(&np->cleanup_work, netpoll_async_cleanup);
>  
> @@ -670,6 +669,7 @@ int netpoll_setup(struct netpoll *np)
>  		goto unlock;
>  	}
>  	dev_hold(ndev);
> +	np->dev = ndev;
>  
>  	if (netdev_master_upper_dev_get(ndev)) {
>  		np_err(np, "%s is a slave device, aborting\n", np->dev_name);
> @@ -770,6 +770,7 @@ int netpoll_setup(struct netpoll *np)
>  	return 0;
>  
>  put:
> +	np->dev = NULL;
>  	dev_put(ndev);
>  unlock:
>  	rtnl_unlock();
> 

Is this safe for stacked devices?  It makes good sense for the typical case, but
if you attempt to setup a netpoll client on a bridge/bond/vlan, etc, the lower
device will get its own netpoll struct registered and have no associated np->dev
pointer.  It not be a real problem in practice, But you probably want to check
to make sure that stacked  devices which recursively call the netpoll api don't
do anyting with the np->dev pointer.

Regards
Neil
