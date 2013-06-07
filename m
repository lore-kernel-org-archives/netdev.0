From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] get 2% or more performance improved by reducing spin_lock
 race
Date: Fri, 07 Jun 2013 16:50:35 +0800
Message-ID: <51B19EDB.5040604@redhat.com>
References: <5872DA217C2FF7488B20897D84F904E7339109CE@nkgeml511-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "mst@redhat.com" <mst@redhat.com>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"(kvm@vger.kernel.org)" <kvm@vger.kernel.org>,
	"(netdev@vger.kernel.org)" <netdev@vger.kernel.org>,
	Heguansen <heguansen@huawei.com>
To: Qinchuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63930 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753172Ab3FGIvP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jun 2013 04:51:15 -0400
In-Reply-To: <5872DA217C2FF7488B20897D84F904E7339109CE@nkgeml511-mbx.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2013 03:31 PM, Qinchuanyu wrote:
> the wake_up_process func is included by spin_lock/unlock in vhost_work_queue,
>  but it could be done outside the spin_lock. 
> I have test it with kernel 3.0.27 and guest suse11-sp2 using iperf, the num as below.
>                  orignal                   modified
> thread_num  tp(Gbps)   vhost(%)  |  tp(Gbps)     vhost(%)
> 1           9.59         28.82   |      9.59        27.49
> 8            9.61        32.92   |      9.62        26.77
> 64            9.58        46.48  |     9.55        38.99
> 256            9.6        63.7   |      9.6         52.59
>
> Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
> ---
>  drivers/vhost/vhost.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 94dbd25..8bee109 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -146,9 +146,10 @@ static inline void vhost_work_queue(struct vhost_dev *dev,
>  	if (list_empty(&work->node)) {
>  		list_add_tail(&work->node, &dev->work_list);
>  		work->queue_seq++;
> +		spin_unlock_irqrestore(&dev->work_lock, flags);
>  		wake_up_process(dev->worker);
> -	}
> -	spin_unlock_irqrestore(&dev->work_lock, flags);
> +	} else
> +		spin_unlock_irqrestore(&dev->work_lock, flags);
>  }
>  
>  void vhost_poll_queue(struct vhost_poll *poll)

Hi Chuanyu:

I believe you need a better name of the patch such as:

vhost: wake up worker outside spinlock
