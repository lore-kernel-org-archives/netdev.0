From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost-net: avoid flush under lock
Date: Thu, 15 Jul 2010 15:37:44 +0300
Message-ID: <20100715123744.GA7831__35249.5698760778$1279197853$gmane$org@redhat.com>
References: <20100715121912.GA7176@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Sridhar Samudrala <samudrala@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43517 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933142Ab0GOMns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jul 2010 08:43:48 -0400
Content-Disposition: inline
In-Reply-To: <20100715121912.GA7176@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 15, 2010 at 03:19:12PM +0300, Michael S. Tsirkin wrote:
> We flush under vq mutex when changing backends.
> This creates a deadlock as workqueue being flushed
> needs this lock as well.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=612421
> 
> Drop the vq mutex before flush: we have the device mutex
> which is sufficient to prevent another ioctl from touching
> the vq.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Dave, just to clarify, I'll send pull request to merge it through my tree,
there's no need for you to bother with this.

> ---
>  drivers/vhost/net.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 28d7786..50df58e6 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -534,11 +534,16 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
>  	rcu_assign_pointer(vq->private_data, sock);
>  	vhost_net_enable_vq(n, vq);
>  done:
> +	mutex_unlock(&vq->mutex);
> +
>  	if (oldsock) {
>  		vhost_net_flush_vq(n, index);
>  		fput(oldsock->file);
>  	}
>  
> +	mutex_unlock(&n->dev.mutex);
> +	return 0;
> +
>  err_vq:
>  	mutex_unlock(&vq->mutex);
>  err:
> -- 
> 1.7.2.rc0.14.g41c1c
