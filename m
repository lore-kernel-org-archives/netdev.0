From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [RFC PATCH net-next 3/3] virtio-net: Add accelerated RFS support
Date: Fri, 17 Jan 2014 06:00:33 +0800
Message-ID: <CAEH94LjHcxkXLvs6AMNop_yzKG0zaT2mAgsAb21i+RtMbkXbmQ@mail.gmail.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
	<1389795654-28381-4-git-send-email-zwu.kernel@gmail.com>
	<1389907887.11912.87.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:58763 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbaAPWAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 17:00:34 -0500
Received: by mail-oa0-f43.google.com with SMTP id h16so3154951oag.2
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 14:00:33 -0800 (PST)
In-Reply-To: <1389907887.11912.87.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 5:31 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2014-01-15 at 22:20 +0800, Zhi Yong Wu wrote:
> [...]
>> +static int virtnet_init_rx_cpu_rmap(struct virtnet_info *vi)
>> +{
>> +     int rc = 0;
>> +
>> +#ifdef CONFIG_RFS_ACCEL
>> +     struct virtio_device *vdev = vi->vdev;
>> +     unsigned int irq;
>> +     int i;
>> +
>> +     if (!vi->affinity_hint_set)
>> +             goto out;
>> +
>> +     vi->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(vi->max_queue_pairs);
>> +     if (!vi->dev->rx_cpu_rmap) {
>> +             rc = -ENOMEM;
>> +             goto out;
>> +     }
>> +
>> +     for (i = 0; i < vi->max_queue_pairs; i++) {
>> +             irq = virtqueue_get_vq_irq(vdev, vi->rq[i].vq);
>> +             if (irq == -1)
>> +                     goto failed;
>
> Jumping into an if-statement is confusing.  Also do you really want to
> return 0 in this case?
No, If it fail to get irq, i want it to exit as soon as possible,
otherwise it will cause irq_cpu_rmap_add() to be invoked with one
incorrect argument irq.

By the way, do you have thought about if it makes sense to add aRFS
support to virtio_net? For [patch 2/3], what do you think of those
missing stuff listed by me?
For how indirect table is implemented in sfc NIC, do you have any doc
to share with  me? thanks.

>
> Otherwise this looks fine.
>
> Ben.
>
>> +             rc = irq_cpu_rmap_add(vi->dev->rx_cpu_rmap, irq);
>> +             if (rc) {
>> +failed:
>> +                     virtnet_free_irq_cpu_rmap(vi);
>> +                     goto out;
>> +             }
>> +     }
>> +out:
>> +#endif
>> +     return rc;
>> +}
> [...]
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>



-- 
Regards,

Zhi Yong Wu
