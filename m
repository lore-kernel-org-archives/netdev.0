From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] vhost: get 2% performance improved by reducing spin_lock
 race in vhost_work_queue
Date: Mon, 20 May 2013 12:46:55 +0800
Message-ID: <5199AABF.6090801@redhat.com>
References: <5872DA217C2FF7488B20897D84F904E7338FD1E5@nkgeml511-mbx.china.huawei.com> <51999AA2.8070806@redhat.com> <5872DA217C2FF7488B20897D84F904E7338FD2C5@nkgeml511-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"mst@redhat.com" <mst@redhat.com>,
	"dhowells@redhat.com" <dhowells@redhat.com>,
	"(kvm@vger.kernel.org)" <kvm@vger.kernel.org>,
	"(netdev@vger.kernel.org)" <netdev@vger.kernel.org>,
	Heguansen <heguansen@huawei.com>
To: Qinchuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25399 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822Ab3ETErx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 00:47:53 -0400
In-Reply-To: <5872DA217C2FF7488B20897D84F904E7338FD2C5@nkgeml511-mbx.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2013 12:22 PM, Qinchuanyu wrote:
> The patch below is base on=20
> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/tree=
/drivers/vhost/vhost.c?id=3Drefs/tags/next-20130517
>
> Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
> --- a/drivers/vhost/vhost.c     2013-05-20 11:47:05.000000000 +0800
> +++ b/drivers/vhost/vhost.c     2013-05-20 11:48:24.000000000 +0800
> @@ -154,9 +154,10 @@
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
> =20
>  void vhost_poll_queue(struct vhost_poll *poll)
>
> I did the test by using iperf in 10G environment, the test num as bel=
ow:
>                  orignal                   modified
> thread_num  tp(Gbps)   vhost(%)  |  tp(Gbps)     vhost(%)
> 1           9.59         28.82   |      9.59        27.49
> 8            9.61        32.92   |      9.62        26.77
> 64            9.58        46.48  |     9.55        38.99
> 256            9.6        63.7   |      9.6         52.59
>
> The cost of vhost reduced while the throughput is almost unchanged.

Thanks, and please generate a formal patch based on
Documentation/SubmittingPatches (put the description and perf numbers i=
n
the commit log). Then resubmit it to let the maintainer apply it.

>
> On 05/20/2013 11:06 AM, Qinchuanyu wrote:
>> Right now the wake_up_process func is included in spin_lock/unlock, =
but it could be done outside the spin_lock.
>> I have test it with kernel 3.0.27 and guest suse11-sp2, it provide 2=
%-3% net performance improved.
>>
>> Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
> Make sense to me but need generate a patch against net-next.git or
> vhost.git in git.kernel.org.
>
> Btw. How did you test this? Care to share the perf numbers?
>
> Thanks
>> mu
>> --- a/drivers/vhost/vhost.c     2013-05-20 10:36:30.000000000 +0800
>> +++ b/drivers/vhost/vhost.c     2013-05-20 10:36:54.000000000 +0800
>> @@ -144,9 +144,10 @@
>>         if (list_empty(&work->node)) {
>>                 list_add_tail(&work->node, &dev->work_list);
>>                 work->queue_seq++;
>> +               spin_unlock_irqrestore(&dev->work_lock, flags);
>>                 wake_up_process(dev->worker);
>> -       }
>> -       spin_unlock_irqrestore(&dev->work_lock, flags);
>> +       } else
>> +               spin_unlock_irqrestore(&dev->work_lock, flags);
>>  }
>> =20
>>  void vhost_poll_queue(struct vhost_poll *poll)
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=
=BF=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=
=BF=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD^=EF=BF=BD=
)=EF=BF=BD=EF=BF=BD=EF=BF=BDw*=1Fjg=EF=BF=BD=EF=BF=BD=EF=BF=BD=1E=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=DD=A2j/=EF=BF=BD=EF=BF=BD=EF=BF=
=BDz=EF=BF=BD=DE=96=EF=BF=BD=EF=BF=BD2=EF=BF=BD=DE=99=EF=BF=BD=EF=BF=BD=
=EF=BF=BD&=EF=BF=BD)=DF=A1=EF=BF=BDa=EF=BF=BD=EF=BF=BD=7F=EF=BF=BD=EF=BF=
=BD=1E=EF=BF=BDG=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=0F=EF=BF=BDj:+v=EF=
=BF=BD=EF=BF=BD=EF=BF=BDw=EF=BF=BD=D9=A5
