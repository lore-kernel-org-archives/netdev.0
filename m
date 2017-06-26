From: Jean-Philippe Menil <jpmenil@gmail.com>
Subject: Re: BUG: KASAN: use-after-free in free_old_xmit_skbs
Date: Mon, 26 Jun 2017 09:35:42 +0200
Message-ID: <f91048e7-5567-cdf8-fd98-3077ca7ac9a3@gmail.com>
References: <d2e8cf65-ea3d-7db2-9382-a063daf1168a@gmail.com>
 <20170605050423-mutt-send-email-mst@kernel.org>
 <20170606024211-mutt-send-email-mst@kernel.org>
 <CAOTcU=u_HSMQiwDF3Snv5P8mT-b_Aepeb=Z9gbLd1j=2P+Yy+A@mail.gmail.com>
 <20170622215125-mutt-send-email-mst@kernel.org>
 <4f6d4342-8476-882e-e7a8-b3f0ebd20d95@redhat.com>
 <CAM_iQpXhW___-iP3kdv9MJcW=hroyp2SuMzAZdx3KCpc9-W76g@mail.gmail.com>
 <9327ebf9-59db-f34e-b945-ef381ee95315@redhat.com>
Reply-To: jpmenil@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        virtualization@lists.linux-foundation.org,
        qemu-devel Developers <qemu-devel@nongnu.org>
To: Jason Wang <jasowang@redhat.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36854 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751400AbdFZHgD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 03:36:03 -0400
Received: by mail-wr0-f196.google.com with SMTP id 77so28471838wrb.3
        for <netdev@vger.kernel.org>; Mon, 26 Jun 2017 00:36:02 -0700 (PDT)
In-Reply-To: <9327ebf9-59db-f34e-b945-ef381ee95315@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/26/2017 04:50 AM, Jason Wang wrote:
> 
> 
> On 2017年06月24日 06:32, Cong Wang wrote:
>> On Fri, Jun 23, 2017 at 1:43 AM, Jason Wang <jasowang@redhat.com> wrote:
>>>
>>> On 2017年06月23日 02:53, Michael S. Tsirkin wrote:
>>>> On Thu, Jun 22, 2017 at 08:15:58AM +0200, jean-philippe menil wrote:
>>>>> Hi Michael,
>>>>>
>>>>> from what i see, the race appear when we hit virtnet_reset in
>>>>> virtnet_xdp_set.
>>>>> virtnet_reset
>>>>>     _remove_vq_common
>>>>>       virtnet_del_vqs
>>>>>         virtnet_free_queues
>>>>>           kfree(vi->sq)
>>>>> when the xdp program (with two instances of the program to trigger it
>>>>> faster)
>>>>> is added or removed.
>>>>>
>>>>> It's easily repeatable, with 2 cpus and 4 queues on the qemu command
>>>>> line,
>>>>> running the xdp_ttl tool from Jesper.
>>>>>
>>>>> For now, i'm able to continue my qualification, testing if xdp_qp 
>>>>> is not
>>>>> null,
>>>>> but do not seem to be a sustainable trick.
>>>>> if (xdp_qp && vi->xdp_queues_pairs != xdp_qp)
>>>>>
>>>>> Maybe it will be more clear to you with theses informations.
>>>>>
>>>>> Best regards.
>>>>>
>>>>> Jean-Philippe
>>>>
>>>> I'm pretty clear about the issue here, I was trying to figure out a 
>>>> fix.
>>>> Jason, any thoughts?
>>>>
>>>>
>>> Hi Jean:
>>>
>>> Does the following fix this issue? (I can't reproduce it locally through
>>> xdp_ttl)
>> It is tricky here.
>>
>>  From my understanding of the code base, the tx_lock is not sufficient
>> here, because in virtnet_del_vqs() all vqs are deleted and one vp
>> maps to one txq.
>>
>> I am afraid you have to add a spinlock somewhere to serialized
>> free_old_xmit_skbs() vs. vring_del_virtqueue(). As you can see
>> they are in different layers, so it is hard to figure out where to add
>> it...
>>
>> Also, make sure we don't sleep inside the spinlock, I see a
>> synchronize_net().
> 
> Looks like I miss something. I thought free_old_xmit_skbs() were 
> serialized in this case since we disable all tx queues after 
> netif_tx_unlock_bh()?
> 
> Jean:
> 
> I thought this could be easily reproduced by e.g produce some traffic 
> and in the same time try to attach an xdp program. But looks not. How do 
> you trigger this? What's your qemu command line for this?
> 
> Thanks

Hi Jason,

this is how i trigger the bug:
- on the guest, tcpdump on on the interface
- on the guest, run iperf against the host
- on the guest, cat /sys/kernel/debug/tracing/trace_pipe
- on the guest, run one or two instances of xdp_ttl compiled with DEBUG 
uncommented, that i start stop, until i trigger the bug.

qemu command line is as follow:

qemu-system-x86_64 -name ubuntu --enable-kvm -machine pc,accel=kvm -smp 
2 -drive file=/dev/LocalDisk/ubuntu,if=virtio,format=raw -m 2048 -rtc 
base=localtime,clock=host -usbdevice tablet --balloon virtio -netdev 
tap,id=ubuntu-0,ifname=ubuntu-0,script=/home/jenfi/WORK/jp/qemu/if-up,downscript=/home/jenfi/WORK/jp/qemu/if-down,vhost=on,queues=4 
-device 
virtio-net-pci,netdev=ubuntu-0,mac=de:ad:be:ef:01:03,mq=on,guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off,vectors=2 
-vnc 127.0.0.1:3 -nographic -serial 
file:/home/jenfi/WORK/jp/qemu/ubuntu.out -monitor 
unix:/home/jenfi/WORK/jp/qemu/ubuntu.sock,server,nowait

Notice, the smp 2, queues to 4 and vectors to 2.
Seem that if fogot to mention that in the beginning of this thread, 
sorry for that.

Best regards.

Jean-Philippe
