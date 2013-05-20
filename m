From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] vhost: get 2% performance improved by reducing spin_lock
 race in vhost_work_queue
Date: Mon, 20 May 2013 11:38:10 +0800
Message-ID: <51999AA2.8070806@redhat.com>
References: <5872DA217C2FF7488B20897D84F904E7338FD1E5@nkgeml511-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"mst@redhat.com" <mst@redhat.com>,
	"dhowells@redhat.com" <dhowells@redhat.com>,
	"(kvm@vger.kernel.org)" <kvm@vger.kernel.org>,
	"(netdev@vger.kernel.org)" <netdev@vger.kernel.org>
To: Qinchuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12811 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755195Ab3ETDiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 May 2013 23:38:24 -0400
In-Reply-To: <5872DA217C2FF7488B20897D84F904E7338FD1E5@nkgeml511-mbx.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2013 11:06 AM, Qinchuanyu wrote:
> Right now the wake_up_process func is included in spin_lock/unlock, but it could be done outside the spin_lock.
> I have test it with kernel 3.0.27 and guest suse11-sp2, it provide 2%-3% net performance improved.
>
> Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>

Make sense to me but need generate a patch against net-next.git or
vhost.git in git.kernel.org.

Btw. How did you test this? Care to share the perf numbers?

Thanks
> mu
> --- a/drivers/vhost/vhost.c     2013-05-20 10:36:30.000000000 +0800
> +++ b/drivers/vhost/vhost.c     2013-05-20 10:36:54.000000000 +0800
> @@ -144,9 +144,10 @@
>         if (list_empty(&work->node)) {
>                 list_add_tail(&work->node, &dev->work_list);
>                 work->queue_seq++;
> +               spin_unlock_irqrestore(&dev->work_lock, flags);
>                 wake_up_process(dev->worker);
> -       }
> -       spin_unlock_irqrestore(&dev->work_lock, flags);
> +       } else
> +               spin_unlock_irqrestore(&dev->work_lock, flags);
>  }
>  
>  void vhost_poll_queue(struct vhost_poll *poll)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
