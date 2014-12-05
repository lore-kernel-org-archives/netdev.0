From: Nick H <nickkvm@gmail.com>
Subject: Re: KVM vs Xen-PV netperf numbers
Date: Fri, 5 Dec 2014 15:36:57 -0800
Message-ID: <CAMou0=xwJ4MMw6zn8WgY-xbiPbF=JqChTkwUtgOOdTMipCuJQA@mail.gmail.com>
References: <CAMou0=xqzcSTxmw_NXjF96Na2RwLB6LDqjGaVFD0gtA=AFsJOg@mail.gmail.com>
	<CAN_zqfP-=8su7hdnd3HCjU++bWn_Qmom=5Zyf9-=iy_DJkAd2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Madhu Challa <challa@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:64655 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbaLEXg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 18:36:57 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so1608690pdi.3
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 15:36:57 -0800 (PST)
In-Reply-To: <CAN_zqfP-=8su7hdnd3HCjU++bWn_Qmom=5Zyf9-=iy_DJkAd2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please do not top post..

Comments inline:

On Fri, Dec 5, 2014 at 12:20 PM, Madhu Challa <challa@noironetworks.com> wrote:
> Could you please attach your kvm command line. If you are running ubuntu you
> might also want to verify you have
>
> # To load the vhost_net module, which in some cases can speed up
> # network performance, set VHOST_NET_ENABLED to 1.
> VHOST_NET_ENABLED=1
>
> in /etc/default/qemu-kvm

sudo qemu-system-x86_64 -hda vdisk.img  -smp 4 -netdev
type=tap,vhost=on,script=/usr/bin/qemu-ifup,id=net0 -device
virtio-net-pci,netdev=net0,mac=00:AD:44:44:CB:02 -m 8192


N
>
> Thanks.
>
> On Fri, Dec 5, 2014 at 12:02 PM, Nick H <nickkvm@gmail.com> wrote:
>>
>> Hello
>>
>> Not sure I have the right audience, I have two VM's on similar hosts.
>> One VM is KVM + virtio + vhost based while other is Xen PV with xen
>> netfront driver. Running a simple netperf test for 1400 byte packets
>> on both VM's, I see wider difference between throughput as follows.
>>
>> Xen-pv throughput comes to :
>>
>> ./netperf -H 10.xx.xx.49 -l 20 -t UDP_STREAM -- -m 1400
>> MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>> 10.xx.xx.49 (10.xx.xx.49) port 0 AF_INET : demo
>> Socket  Message  Elapsed      Messages
>> Size    Size     Time         Okay Errors   Throughput
>> bytes   bytes    secs            #      #   10^6bits/sec
>>
>> 212992    1400   20.00     1910549      0    1069.89
>> 262144           20.00     1704789            954.66
>>
>> whereas KVM virtio number comes to :
>>
>> ./netperf -t UDP_STREAM -l 10 -H 10.xx.xx.49 -- -m 1400
>> MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>> 10.xx.xx.49 (10.xx.xx.49) port 0 AF_INET : demo
>> Socket  Message  Elapsed      Messages
>> Size    Size     Time         Okay Errors   Throughput
>> bytes   bytes    secs            #      #   10^6bits/sec
>>
>> 212992    1400   10.00      155060      0     173.65
>> 262144           10.00      155060            173.65
>>
>> I built a custom kernel where I simply free up the (UDP only) skb in
>> virtio: xmit_skb() routine and I count how many skb's I have received.
>> Surprisingly it was not too high either:
>>
>> ./netperf -t UDP_STREAM -l 10 -H 10.xx.xx.49 -- -m 1400
>> MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>> 10.xx.xx.49 (10.xx.xx.49) port 0 AF_INET : demo
>> Socket  Message  Elapsed      Messages
>> Size    Size     Time         Okay Errors   Throughput
>> bytes   bytes    secs            #      #   10^6bits/sec
>>
>> 212992    1400   10.00      224792      0     251.74
>> 262144           10.00           0              0.00
>>
>>
>> 1910549 packets pumped in xen pv driver versus 212992 packets pumped
>> in case of virtio driver. Assuming the data path inside the kernel is
>> same for both drivers , and I have eliminated virtio's
>> virtqueue_kick() call by freeing the packet ahead in my experiment,
>> can all this overhead attributed to system call overhead in case of
>> KVM+virtio combination ? Anything I am missing ?
>>
>> The KVM setup is based off:
>> Linux ubn-nested 3.17.0+ #16 SMP Thu Dec 4 12:00:09 PST 2014 x86_64
>> x86_64 x86_64 GNU/Linux
>>
>> Regards
>> N
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
