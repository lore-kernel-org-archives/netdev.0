From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net V2] tuntap: correctly wake up process during uninit
Date: Thu, 19 May 2016 14:51:23 +0300
Message-ID: <20160519145115-mutt-send-email-mst@redhat.com>
References: <1463636211-3573-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Xi Wang <xii@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1463636211-3573-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2016 at 01:36:51PM +0800, Jason Wang wrote:
> We used to check dev->reg_state against NETREG_REGISTERED after each
> time we are woke up. But after commit 9e641bdcfa4e ("net-tun:
> restructure tun_do_read for better sleep/wakeup efficiency"), it uses
> skb_recv_datagram() which does not check dev->reg_state. This will
> result if we delete a tun/tap device after a process is blocked in the
> reading. The device will wait for the reference count which was held
> by that process for ever.
> 
> Fixes this by using RCV_SHUTDOWN which will be checked during
> sk_recv_datagram() before trying to wake up the process during uninit.
> 
> Fixes: 9e641bdcfa4e ("net-tun: restructure tun_do_read for better
> sleep/wakeup efficiency")
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Xi Wang <xii@google.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
> - The patch is needed for -stable.
> - Changes from v1: remove unnecessary NETREG_REGISTERED check in tun_do_read()
> ---
>  drivers/net/tun.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 425e983..e16487c 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -580,11 +580,13 @@ static void tun_detach_all(struct net_device *dev)
>  	for (i = 0; i < n; i++) {
>  		tfile = rtnl_dereference(tun->tfiles[i]);
>  		BUG_ON(!tfile);
> +		tfile->socket.sk->sk_shutdown = RCV_SHUTDOWN;
>  		tfile->socket.sk->sk_data_ready(tfile->socket.sk);
>  		RCU_INIT_POINTER(tfile->tun, NULL);
>  		--tun->numqueues;
>  	}
>  	list_for_each_entry(tfile, &tun->disabled, next) {
> +		tfile->socket.sk->sk_shutdown = RCV_SHUTDOWN;
>  		tfile->socket.sk->sk_data_ready(tfile->socket.sk);
>  		RCU_INIT_POINTER(tfile->tun, NULL);
>  	}
> @@ -641,6 +643,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
>  			goto out;
>  	}
>  	tfile->queue_index = tun->numqueues;
> +	tfile->socket.sk->sk_shutdown &= ~RCV_SHUTDOWN;
>  	rcu_assign_pointer(tfile->tun, tun);
>  	rcu_assign_pointer(tun->tfiles[tun->numqueues], tfile);
>  	tun->numqueues++;
> @@ -1491,9 +1494,6 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
>  	if (!iov_iter_count(to))
>  		return 0;
>  
> -	if (tun->dev->reg_state != NETREG_REGISTERED)
> -		return -EIO;
> -
>  	/* Read frames from queue */
>  	skb = __skb_recv_datagram(tfile->socket.sk, noblock ? MSG_DONTWAIT : 0,
>  				  &peeked, &off, &err);
> -- 
> 2.7.4
