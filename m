From: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Subject: Re: Regression in throughput between kvm guests over virtual bridge
Date: Wed, 18 Oct 2017 16:17:51 -0400
Message-ID: <c0b42b27-56f6-c2f9-9476-28d25678808a@linux.vnet.ibm.com>
References: <15abafa1-6d58-cd85-668a-bf361a296f52@redhat.com>
 <7345a69d-5e47-7058-c72b-bdd0f3c69210@linux.vnet.ibm.com>
 <55f9173b-a419-98f0-2516-cbd57299ba5d@redhat.com>
 <c9d43af9-f095-043a-7d46-acd84a18f75a@redhat.com>
 <7d444584-3854-ace2-008d-0fdef1c9cef4@linux.vnet.ibm.com>
 <1173ab1f-e2b6-26b3-8c3c-bd5ceaa1bd8e@redhat.com>
 <129a01d9-de9b-f3f1-935c-128e73153df6@linux.vnet.ibm.com>
 <3f824b0e-65f9-c69c-5421-2c5f6b349b09@redhat.com>
 <78678f33-c9ba-bf85-7778-b2d0676b78dd@linux.vnet.ibm.com>
 <038445a6-9dd5-30c2-aac0-ab5efbfa7024@linux.vnet.ibm.com>
 <20171012183132.qrbgnmvki6lpgt4a@Wei-Dev>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
        davem@davemloft.net, mst@redhat.com
To: Wei Xu <wexu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:50492 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750877AbdJRUR5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 16:17:57 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IKHdLh120545
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 16:17:56 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dp9p4xb3m-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 16:17:56 -0400
Received: from localhost
        by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <mjrosato@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 14:17:55 -0600
In-Reply-To: <20171012183132.qrbgnmvki6lpgt4a@Wei-Dev>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2017 02:31 PM, Wei Xu wrote:
> On Thu, Oct 05, 2017 at 04:07:45PM -0400, Matthew Rosato wrote:
>>
>> Ping...  Jason, any other ideas or suggestions?
> 
> Hi Matthew,
> Recently I am doing similar test on x86 for this patch, here are some,
> differences between our testbeds.
> 
> 1. It is nice you have got improvement with 50+ instances(or connections here?)
> which would be quite helpful to address the issue, also you've figured out the
> cost(wait/wakeup), kindly reminder did you pin uperf client/server along the whole
> path besides vhost and vcpu threads? 

Was not previously doing any pinning whatsoever, just reproducing an
environment that one of our testers here was running.  Reducing guest
vcpu count from 4->1, still see the regression.  Then, pinned each vcpu
thread and vhost thread to a separate host CPU -- still made no
difference (regression still present).

> 
> 2. It might be useful to short the traffic path as a reference, What I am running
> is briefly like:
>     pktgen(host kernel) -> tap(x) -> guest(DPDK testpmd)
> 
> The bridge driver(br_forward(), etc) might impact performance due to my personal
> experience, so eventually I settled down with this simplified testbed which fully
> isolates the traffic from both userspace and host kernel stack(1 and 50 instances,
> bridge driver, etc), therefore reduces potential interferences.
> 
> The down side of this is that it needs DPDK support in guest, has this ever be
> run on s390x guest? An alternative approach is to directly run XDP drop on
> virtio-net nic in guest, while this requires compiling XDP inside guest which needs
> a newer distro(Fedora 25+ in my case or Ubuntu 16.10, not sure).
> 

I made an attempt at DPDK, but it has not been run on s390x as far as
I'm aware and didn't seem trivial to get working.

So instead I took your alternate suggestion & did:
pktgen(host) -> tap(x) -> guest(xdp_drop)

When running this setup, I am not able to reproduce the regression.  As
mentioned previously, I am also unable to reproduce when running one end
of the uperf connection from the host - I have only ever been able to
reproduce when both ends of the uperf connection are running within a guest.

> 3. BTW, did you enable hugepage for your guest? It would  performance more
> or less depends on the memory demand when generating traffic, I didn't see
> similar command lines in yours.
> 

s390x does not currently support passing through hugetlb backing via
QEMU mem-path.
