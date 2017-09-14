From: Jason Wang <jasowang@redhat.com>
Subject: Re: Regression in throughput between kvm guests over virtual bridge
Date: Thu, 14 Sep 2017 12:21:55 +0800
Message-ID: <50891c14-3fc6-f519-8c03-07bdef3090f4@redhat.com>
References: <4c7e2924-b10f-0e97-c388-c8809ecfdeeb@linux.vnet.ibm.com>
 <bdd417dc-9e2f-4a2e-534b-c6aa38f002f2@redhat.com>
 <e022cfa7-ef65-550f-06e8-f6e29f1d68a0@redhat.com>
 <627d0c7a-dce5-3094-d5d4-c1507fcb8080@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, mst@redhat.com
To: Matthew Rosato <mjrosato@linux.vnet.ibm.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34094 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750740AbdINEWB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 14 Sep 2017 00:22:01 -0400
In-Reply-To: <627d0c7a-dce5-3094-d5d4-c1507fcb8080@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年09月14日 00:59, Matthew Rosato wrote:
> On 09/13/2017 04:13 AM, Jason Wang wrote:
>>
>> On 2017年09月13日 09:16, Jason Wang wrote:
>>>
>>> On 2017年09月13日 01:56, Matthew Rosato wrote:
>>>> We are seeing a regression for a subset of workloads across KVM guests
>>>> over a virtual bridge between host kernel 4.12 and 4.13. Bisecting
>>>> points to c67df11f "vhost_net: try batch dequing from skb array"
>>>>
>>>> In the regressed environment, we are running 4 kvm guests, 2 running as
>>>> uperf servers and 2 running as uperf clients, all on a single host.
>>>> They are connected via a virtual bridge.  The uperf client profile looks
>>>> like:
>>>>
>>>> <?xml version="1.0"?>
>>>> <profile name="TCP_STREAM">
>>>>     <group nprocs="1">
>>>>       <transaction iterations="1">
>>>>         <flowop type="connect" options="remotehost=192.168.122.103
>>>> protocol=tcp"/>
>>>>       </transaction>
>>>>       <transaction duration="300">
>>>>         <flowop type="write" options="count=16 size=30000"/>
>>>>       </transaction>
>>>>       <transaction iterations="1">
>>>>         <flowop type="disconnect"/>
>>>>       </transaction>
>>>>     </group>
>>>> </profile>
>>>>
>>>> So, 1 tcp streaming instance per client.  When upgrading the host kernel
>>>> from 4.12->4.13, we see about a 30% drop in throughput for this
>>>> scenario.  After the bisect, I further verified that reverting c67df11f
>>>> on 4.13 "fixes" the throughput for this scenario.
>>>>
>>>> On the other hand, if we increase the load by upping the number of
>>>> streaming instances to 50 (nprocs="50") or even 10, we see instead a
>>>> ~10% increase in throughput when upgrading host from 4.12->4.13.
>>>>
>>>> So it may be the issue is specific to "light load" scenarios.  I would
>>>> expect some overhead for the batching, but 30% seems significant...  Any
>>>> thoughts on what might be happening here?
>>>>
>>> Hi, thanks for the bisecting. Will try to see if I can reproduce.
>>> Various factors could have impact on stream performance. If possible,
>>> could you collect the #pkts and average packet size during the test?
>>> And if you guest version is above 4.12, could you please retry with
>>> napi_tx=true?
> Original runs were done with guest kernel 4.4 (from ubuntu 16.04.3 -
> 4.4.0-93-generic specifically).  Here's a throughput report (uperf) and
> #pkts and average packet size (tcpstat) for one of the uperf clients:
>
> host 4.12 / guest 4.4:
> throughput: 29.98Gb/s
> #pkts=33465571 avg packet size=33755.70
>
> host 4.13 / guest 4.4:
> throughput: 20.36Gb/s
> #pkts=21233399 avg packet size=36130.69

I test guest 4.4 on Intel machine, still can reproduce :(

>
> I ran the test again using net-next.git as guest kernel, with and
> without napi_tx=true.  napi_tx did not seem to have any significant
> impact on throughput.  However, the guest kernel shift from
> 4.4->net-next improved things.  I can still see a regression between
> host 4.12 and 4.13, but it's more on the order of 10-15% - another sample:
>
> host 4.12 / guest net-next (without napi_tx):
> throughput: 28.88Gb/s
> #pkts=31743116 avg packet size=33779.78
>
> host 4.13 / guest net-next (without napi_tx):
> throughput: 24.34Gb/s
> #pkts=25532724 avg packet size=35963.20

Thanks for the numbers. I originally suspect batching will lead more 
pkts but less size, but looks not. The less packets is also a hint that 
there's delay somewhere.

>
>>> Thanks
>> Unfortunately, I could not reproduce it locally. I'm using net-next.git
>> as guest. I can get ~42Gb/s on Intel(R) Xeon(R) CPU E5-2650 0 @ 2.00GHz
>> for both before and after the commit. I use 1 vcpu and 1 queue, and pin
>> vcpu and vhost threads into separate cpu on host manually (in same numa
>> node).
> The environment is quite a bit different -- I'm running in an LPAR on a
> z13 (s390x).  We've seen the issue in various configurations, the
> smallest thus far was a host partition w/ 40G and 20 CPUs defined (the
> numbers above were gathered w/ this configuration).  Each guest has 4GB
> and 4 vcpus.  No pinning / affinity configured.

Unfortunately, I don't have s390x on hand. Will try to get one.

>
>> Can you hit this regression constantly and what's you qemu command line
> Yes, the regression seems consistent.  I can try tweaking some of the
> host and guest definitions to see if it makes a difference.

Is the issue gone if you reduce VHOST_RX_BATCH to 1? And it would be 
also helpful to collect perf diff to see if anything interesting. 
(Consider 4.4 shows more obvious regression, please use 4.4).

>
> The guests are instantiated from libvirt - Here's one of the resulting
> qemu command lines:
>
> /usr/bin/qemu-system-s390x -name guest=mjrs34g1,debug-threads=on -S
> -object
> secret,id=masterKey0,format=raw,file=/var/lib/libvirt/qemu/domain-1-mjrs34g1/master-key.aes
> -machine s390-ccw-virtio-2.10,accel=kvm,usb=off,dump-guest-core=off -m
> 4096 -realtime mlock=off -smp 4,sockets=4,cores=1,threads=1 -uuid
> 44710587-e783-4bd8-8590-55ff421431b1 -display none -no-user-config
> -nodefaults -chardev
> socket,id=charmonitor,path=/var/lib/libvirt/qemu/domain-1-mjrs34g1/monitor.sock,server,nowait
> -mon chardev=charmonitor,id=monitor,mode=control -rtc base=utc
> -no-shutdown -boot strict=on -drive
> file=/dev/disk/by-id/scsi-3600507630bffc0380000000000001803,format=raw,if=none,id=drive-virtio-disk0
> -device
> virtio-blk-ccw,scsi=off,devno=fe.0.0000,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1
> -netdev tap,fd=25,id=hostnet0,vhost=on,vhostfd=27 -device
> virtio-net-ccw,netdev=hostnet0,id=net0,mac=02:de:26:53:14:01,devno=fe.0.0001
> -netdev tap,fd=28,id=hostnet1,vhost=on,vhostfd=29 -device
> virtio-net-ccw,netdev=hostnet1,id=net1,mac=02:54:00:89:d4:01,devno=fe.0.00a1
> -chardev pty,id=charconsole0 -device
> sclpconsole,chardev=charconsole0,id=console0 -device
> virtio-balloon-ccw,id=balloon0,devno=fe.0.0002 -msg timestamp=on
>
> In the above, net0 is used for a macvtap connection (not used in the
> experiment, just for a reliable ssh connection - can remove if needed).
> net1 is the bridge connection used for the uperf tests.
>
>
>> and #cpus on host? Is zerocopy enabled?
> Host info provided above.
>
> cat /sys/module/vhost_net/parameters/experimental_zcopytx
> 1

May worth to try disable zerocopy or do the test form host to guest 
instead of guest to guest to exclude the possible issue of sender.

Thanks
