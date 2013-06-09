From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: wake up worker outside spin_lock
Date: Sun, 9 Jun 2013 12:47:01 +0300
Message-ID: <20130609094701.GA14832@redhat.com>
References: <51B1E518.1070003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, kvm@vger.kernel.org, netdev@vger.kernel.org
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51B1E518.1070003@huawei.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 07, 2013 at 09:50:16PM +0800, Qin Chuanyu wrote:
> the wake_up_process func is included by spin_lock/unlock in
> vhost_work_queue,
> but it could be done outside the spin_lock.
> I have test it with kernel 3.0.27 and guest suse11-sp2 using iperf,
> the num as below.
>                  original                 modified
> thread_num  tp(Gbps)   vhost(%)  |  tp(Gbps)     vhost(%)
> 1           9.59        28.82    |   9.59        27.49
> 8           9.61        32.92    |   9.62        26.77
> 64          9.58        46.48    |   9.55        38.99
> 256         9.6         63.7     |   9.6         52.59
> 
> Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
> ---
>  drivers/vhost/vhost.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 94dbd25..dcc7a17 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -146,9 +146,11 @@ static inline void vhost_work_queue(struct
> vhost_dev *dev,

Applied and queued for 3.11, thanks.

This patch is malformed because of the wrapped line above.
I've applied this by hand, so just FYI, please see
Documentation/email-clients.txt
for some hints on configuring mail properly.


>  	if (list_empty(&work->node)) {
>  		list_add_tail(&work->node, &dev->work_list);
>  		work->queue_seq++;
> +		spin_unlock_irqrestore(&dev->work_lock, flags);
>  		wake_up_process(dev->worker);
> +	} else {
> +		spin_unlock_irqrestore(&dev->work_lock, flags);
>  	}
> -	spin_unlock_irqrestore(&dev->work_lock, flags);
>  }
> 
>  void vhost_poll_queue(struct vhost_poll *poll)
> -- 
> 1.7.3.1.msysgit.0
> 
