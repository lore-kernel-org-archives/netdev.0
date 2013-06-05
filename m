From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tuntap: fix a possible race between queue selection and
 changing queues
Date: Wed, 5 Jun 2013 13:33:32 +0300
Message-ID: <20130605103332.GD31830@redhat.com>
References: <1370421897-30933-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1370421897-30933-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 05, 2013 at 04:44:57PM +0800, Jason Wang wrote:
> Complier may generate codes that re-read the tun->numqueues during
> tun_select_queue(). This may be a race if vlan->numqueues were changed in the
> same time and can lead unexpected result (e.g. very huge value).
> 
> We need prevent the compiler from generating such codes by adding an
> ACCESS_ONCE() to make sure tun->numqueues were only read once.
> 
> Bug were introduced by commit c8d68e6be1c3b242f1c598595830890b65cea64a
> (tuntap: multiqueue support).
> 
> Reported-by: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

This is a theoretical problem, right?
So no need for stable.

> ---
>  drivers/net/tun.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index f042b03..adfcde7 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -352,7 +352,7 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
>  	u32 numqueues = 0;
>  
>  	rcu_read_lock();
> -	numqueues = tun->numqueues;
> +	numqueues = ACCESS_ONCE(tun->numqueues);
>  
>  	txq = skb_get_rxhash(skb);
>  	if (txq) {
> -- 
> 1.7.1
