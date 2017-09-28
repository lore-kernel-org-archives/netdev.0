From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 0/3] support changing steering policies in tuntap
Date: Thu, 28 Sep 2017 14:50:31 +0800
Message-ID: <77e2149a-e2cc-cd18-039d-a202cd9f8b4c@redhat.com>
References: <1506500637-13881-1-git-send-email-jasowang@redhat.com>
 <20170927230042-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927230042-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月28日 06:13, Michael S. Tsirkin wrote:
> On Wed, Sep 27, 2017 at 04:23:54PM +0800, Jason Wang wrote:
>> Hi all:
>>
>> We use flow caches based flow steering policy now. This is good for
>> connection-oriented communication such as TCP but not for the others
>> e.g connectionless unidirectional workload which cares only about
>> pps. This calls the ability of supporting changing steering policies
>> in tuntap which was done by this series.
>>
>> Flow steering policy was abstracted into tun_steering_ops in the first
>> patch. Then new ioctls to set or query current policy were introduced,
>> and the last patch introduces a very simple policy that select txq
>> based on processor id as an example.
>>
>> Test was done by using xdp_redirect to redirect traffic generated from
>> MoonGen that was running on a remote machine. And I see 37%
>> improvement for processor id policy compared to automatic flow
>> steering policy.
> For sure, if you don't need to figure out the flow hash then you can
> save a bunch of cycles.  But I don't think the cpu policy is too
> practical outside of a benchmark.

Well, the aim of the series is to add methods to change the steering 
policy, cpu policy is an example. Actually, it may make sense for some 
cards which guarantee that all packets belongs to a specific flow goes 
into a specific cpu.

>
> Did you generate packets and just send them to tun? If so, this is not a
> typical configuration, is it?

The test was done by:

- generate UDP traffic from a remote machine
- use xdp redirection to do mac swap in guest and forward it back to the 
remote machine

>   With packets coming e.g.  from a real nic
> they might already have the hash pre-calculated, and you won't
> see the benefit.

Yes, I can switch to use this as a example policy.

Thanks

>
>> In the future, both simple and sophisticated policy like RSS or other guest
>> driven steering policies could be done on top.
> IMHO there should be a more practical example before adding all this
> indirection. And it would be nice to understand why this queue selection
> needs to be tun specific.

Actually, we can use fanout policy (as pointed out) by using the API 
introduced in this series.

Thanks

>
>> Thanks
>>
>> Jason Wang (3):
>>    tun: abstract flow steering logic
>>    tun: introduce ioctls to set and get steering policies
>>    tun: introduce cpu id based steering policy
>>
>>   drivers/net/tun.c           | 151 +++++++++++++++++++++++++++++++++++++-------
>>   include/uapi/linux/if_tun.h |   8 +++
>>   2 files changed, 136 insertions(+), 23 deletions(-)
>>
>> -- 
>> 2.7.4
