From: Asias He <asias.hejun@gmail.com>
Subject: Re: [PATCH] vhost: wake up worker outside spin_lock
Date: Fri, 7 Jun 2013 22:05:37 +0800
Message-ID: <CAFO3S41ATqXBpFNz-sBqKtjMuf6P5=LT96w+maBa_Sm3v2EkHg@mail.gmail.com>
References: <51B1E518.1070003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>, KVM <kvm@vger.kernel.org>,
	netdev@vger.kernel.org
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:35395 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382Ab3FGOGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 10:06:18 -0400
In-Reply-To: <51B1E518.1070003@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 7, 2013 at 9:50 PM, Qin Chuanyu <qinchuanyu@huawei.com> wrote:
> the wake_up_process func is included by spin_lock/unlock in
> vhost_work_queue,
> but it could be done outside the spin_lock.
> I have test it with kernel 3.0.27 and guest suse11-sp2 using iperf,
> the num as below.
>                  original                 modified
>
> thread_num  tp(Gbps)   vhost(%)  |  tp(Gbps)     vhost(%)
> 1           9.59        28.82    |   9.59        27.49
> 8           9.61        32.92    |   9.62        26.77
> 64          9.58        46.48    |   9.55        38.99
> 256         9.6         63.7     |   9.6         52.59
>
> Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
> ---
>  drivers/vhost/vhost.c |    4 +++-
>
>  1 files changed, 3 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 94dbd25..dcc7a17 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -146,9 +146,11 @@ static inline void vhost_work_queue(struct vhost_dev
> *dev,
>
>         if (list_empty(&work->node)) {
>                 list_add_tail(&work->node, &dev->work_list);
>                 work->queue_seq++;
> +               spin_unlock_irqrestore(&dev->work_lock, flags);
>                 wake_up_process(dev->worker);
> +       } else {
> +               spin_unlock_irqrestore(&dev->work_lock, flags);
>         }
> -       spin_unlock_irqrestore(&dev->work_lock, flags);
>
>  }

Hmm,  this looks more clearer to me.

--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -156,14 +156,17 @@ EXPORT_SYMBOL_GPL(vhost_poll_flush);
 void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work)
 {
        unsigned long flags;
+       bool wakeup = false;

        spin_lock_irqsave(&dev->work_lock, flags);
        if (list_empty(&work->node)) {
                list_add_tail(&work->node, &dev->work_list);
                work->queue_seq++;
-               wake_up_process(dev->worker);
+               wakeup = true;
        }
        spin_unlock_irqrestore(&dev->work_lock, flags);
+       if (wakeup)
+               wake_up_process(dev->worker);
 }


>
>  void vhost_poll_queue(struct vhost_poll *poll)
> --
> 1.7.3.1.msysgit.0
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--
Asias
