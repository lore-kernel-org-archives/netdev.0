From: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Subject: Re: Regression in throughput between kvm guests over virtual bridge
Date: Wed, 25 Oct 2017 16:31:55 -0400
Message-ID: <4bb941da-059c-3c3c-26bf-5f41598d2fa6@linux.vnet.ibm.com>
References: <55f9173b-a419-98f0-2516-cbd57299ba5d@redhat.com>
 <c9d43af9-f095-043a-7d46-acd84a18f75a@redhat.com>
 <7d444584-3854-ace2-008d-0fdef1c9cef4@linux.vnet.ibm.com>
 <1173ab1f-e2b6-26b3-8c3c-bd5ceaa1bd8e@redhat.com>
 <129a01d9-de9b-f3f1-935c-128e73153df6@linux.vnet.ibm.com>
 <3f824b0e-65f9-c69c-5421-2c5f6b349b09@redhat.com>
 <78678f33-c9ba-bf85-7778-b2d0676b78dd@linux.vnet.ibm.com>
 <038445a6-9dd5-30c2-aac0-ab5efbfa7024@linux.vnet.ibm.com>
 <20171012183132.qrbgnmvki6lpgt4a@Wei-Dev>
 <c0b42b27-56f6-c2f9-9476-28d25678808a@linux.vnet.ibm.com>
 <20171023135729.xeacprxsg5qizkoa@Wei-Dev>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
        davem@davemloft.net, mst@redhat.com
To: Wei Xu <wexu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:41796 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751900AbdJYUcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 16:32:00 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9PKTKk9116256
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 16:31:59 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2du0k7ay4n-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 16:31:59 -0400
Received: from localhost
        by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <mjrosato@linux.vnet.ibm.com>;
        Wed, 25 Oct 2017 16:31:59 -0400
In-Reply-To: <20171023135729.xeacprxsg5qizkoa@Wei-Dev>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2017 09:57 AM, Wei Xu wrote:
> On Wed, Oct 18, 2017 at 04:17:51PM -0400, Matthew Rosato wrote:
>> On 10/12/2017 02:31 PM, Wei Xu wrote:
>>> On Thu, Oct 05, 2017 at 04:07:45PM -0400, Matthew Rosato wrote:
>>>>
>>>> Ping...  Jason, any other ideas or suggestions?
>>>
>>> Hi Matthew,
>>> Recently I am doing similar test on x86 for this patch, here are some,
>>> differences between our testbeds.
>>>
>>> 1. It is nice you have got improvement with 50+ instances(or connections here?)
>>> which would be quite helpful to address the issue, also you've figured out the
>>> cost(wait/wakeup), kindly reminder did you pin uperf client/server along the whole
>>> path besides vhost and vcpu threads? 
>>
>> Was not previously doing any pinning whatsoever, just reproducing an
>> environment that one of our testers here was running.  Reducing guest
>> vcpu count from 4->1, still see the regression.  Then, pinned each vcpu
>> thread and vhost thread to a separate host CPU -- still made no
>> difference (regression still present).
>>
>>>
>>> 2. It might be useful to short the traffic path as a reference, What I am running
>>> is briefly like:
>>>     pktgen(host kernel) -> tap(x) -> guest(DPDK testpmd)
>>>
>>> The bridge driver(br_forward(), etc) might impact performance due to my personal
>>> experience, so eventually I settled down with this simplified testbed which fully
>>> isolates the traffic from both userspace and host kernel stack(1 and 50 instances,
>>> bridge driver, etc), therefore reduces potential interferences.
>>>
>>> The down side of this is that it needs DPDK support in guest, has this ever be
>>> run on s390x guest? An alternative approach is to directly run XDP drop on
>>> virtio-net nic in guest, while this requires compiling XDP inside guest which needs
>>> a newer distro(Fedora 25+ in my case or Ubuntu 16.10, not sure).
>>>
>>
>> I made an attempt at DPDK, but it has not been run on s390x as far as
>> I'm aware and didn't seem trivial to get working.
>>
>> So instead I took your alternate suggestion & did:
>> pktgen(host) -> tap(x) -> guest(xdp_drop)
> 
> It is really nice of you for having tried this, I also tried this on x86 with 
> two ubuntu 16.04 guests, but unfortunately I couldn't reproduce it as well,
> but I did get lower throughput with 50 instances than one instance(1-4 vcpus),
> is this the same on s390x? 

For me, the total throughput is higher from 50 instances than for 1
instance when host kernel is 4.13.  However, when running a 50 instance
uperf load I cannot reproduce the regression, either.  Throughput is a
little bit better when host is 4.13 vs 4.12 for a 50 instance run.

> 
>>
>> When running this setup, I am not able to reproduce the regression.  As
>> mentioned previously, I am also unable to reproduce when running one end
>> of the uperf connection from the host - I have only ever been able to
>> reproduce when both ends of the uperf connection are running within a guest.
> 
> Did you see improvement when running uperf from the host if no regression? 
> 
> It would be pretty nice to run pktgen from the VM as Jason suggested in another
> mail(pktgen(vm1) -> tap1 -> bridge -> tap2 -> vm2), this is super close to your
> original test case and can help to determine if we can get some clue with tcp or
> bridge driver.
> 
> Also I am interested in your hardware platform, how many NUMA nodes do you have?
> what about your binding(vcpu/vhost/pktgen). For my case, I got a server with 4
> NUMA nodes and 12 cpus for each sockets, and I am explicitly launching qemu from
> cpu0, then bind vhost(Rx/Tx) to cpu 2&3, and vcpus start from cpu 4(3 vcpus for
> each).

I'm running in an LPAR on a z13.  The particular LPAR I am using to
reproduce has 20 CPUs and 40G of memory assigned, all in 1 NUMA node.  I
was initially recreating an issue uncovered by someone elses test, and
thus was doing no cpu binding -- But have attempted binding vhost and
vcpu threads to individual host CPUs and it seemed to have no impact on
the noted regression.  When doing said binding, I did: qemu-guestA ->
cpu0(or 0-3 when running 4vcpu), qemu-guestA-vhost -> cpu4, qemu-guestB
-> cpu8(or 8-11 when running 4vcpu), qemu-guestB-vhost -> cpu12.
