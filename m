From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] vhost-net: avoid flush under lock
Date: Thu, 15 Jul 2010 11:17:57 -0700
Message-ID: <1279217878.8566.6.camel@w-sridhar.beaverton.ibm.com>
References: <20100715121912.GA7176@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:53084 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934047Ab0GOSSC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jul 2010 14:18:02 -0400
In-Reply-To: <20100715121912.GA7176@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-15 at 15:19 +0300, Michael S. Tsirkin wrote:
> We flush under vq mutex when changing backends.
> This creates a deadlock as workqueue being flushed
> needs this lock as well.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=612421
> 
> Drop the vq mutex before flush: we have the device mutex
> which is sufficient to prevent another ioctl from touching
> the vq.

Why do we need to flush the vq when trying to set the backend and
we find that it is already set. Is this just an optimization?

Thanks
Sridhar
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
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

