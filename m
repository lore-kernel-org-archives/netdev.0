From: Jason Wang <jasowang@redhat.com>
Subject: Re: Regression in throughput between kvm guests over virtual bridge
Date: Wed, 13 Sep 2017 16:13:45 +0800
Message-ID: <e022cfa7-ef65-550f-06e8-f6e29f1d68a0@redhat.com>
References: <4c7e2924-b10f-0e97-c388-c8809ecfdeeb@linux.vnet.ibm.com>
 <bdd417dc-9e2f-4a2e-534b-c6aa38f002f2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, mst@redhat.com
To: Matthew Rosato <mjrosato@linux.vnet.ibm.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44052 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750776AbdIMINw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 04:13:52 -0400
In-Reply-To: <bdd417dc-9e2f-4a2e-534b-c6aa38f002f2@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年09月13日 09:16, Jason Wang wrote:
>
>
> On 2017年09月13日 01:56, Matthew Rosato wrote:
>> We are seeing a regression for a subset of workloads across KVM guests
>> over a virtual bridge between host kernel 4.12 and 4.13. Bisecting
>> points to c67df11f "vhost_net: try batch dequing from skb array"
>>
>> In the regressed environment, we are running 4 kvm guests, 2 running as
>> uperf servers and 2 running as uperf clients, all on a single host.
>> They are connected via a virtual bridge.  The uperf client profile looks
>> like:
>>
>> <?xml version="1.0"?>
>> <profile name="TCP_STREAM">
>>    <group nprocs="1">
>>      <transaction iterations="1">
>>        <flowop type="connect" options="remotehost=192.168.122.103
>> protocol=tcp"/>
>>      </transaction>
>>      <transaction duration="300">
>>        <flowop type="write" options="count=16 size=30000"/>
>>      </transaction>
>>      <transaction iterations="1">
>>        <flowop type="disconnect"/>
>>      </transaction>
>>    </group>
>> </profile>
>>
>> So, 1 tcp streaming instance per client.  When upgrading the host kernel
>> from 4.12->4.13, we see about a 30% drop in throughput for this
>> scenario.  After the bisect, I further verified that reverting c67df11f
>> on 4.13 "fixes" the throughput for this scenario.
>>
>> On the other hand, if we increase the load by upping the number of
>> streaming instances to 50 (nprocs="50") or even 10, we see instead a
>> ~10% increase in throughput when upgrading host from 4.12->4.13.
>>
>> So it may be the issue is specific to "light load" scenarios.  I would
>> expect some overhead for the batching, but 30% seems significant...  Any
>> thoughts on what might be happening here?
>>
>
> Hi, thanks for the bisecting. Will try to see if I can reproduce. 
> Various factors could have impact on stream performance. If possible, 
> could you collect the #pkts and average packet size during the test? 
> And if you guest version is above 4.12, could you please retry with 
> napi_tx=true?
>
> Thanks

Unfortunately, I could not reproduce it locally. I'm using net-next.git 
as guest. I can get ~42Gb/s on Intel(R) Xeon(R) CPU E5-2650 0 @ 2.00GHz 
for both before and after the commit. I use 1 vcpu and 1 queue, and pin 
vcpu and vhost threads into separate cpu on host manually (in same numa 
node).

Can you hit this regression constantly and what's you qemu command line 
and #cpus on host? Is zerocopy enabled?

Thanks
