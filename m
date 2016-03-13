From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH] netfilter: fix race condition in ipset save and delete
Date: Sun, 13 Mar 2016 12:25:36 -0400
Message-ID: <56E59480.1060304@akamai.com>
References: <20160313023317.GA14181@akamai.com>
 <alpine.DEB.2.10.1603131254230.18557@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	johunt@akamai.com, netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1603131254230.18557@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jozsef,

On 03/13/2016 08:07 AM, Jozsef Kadlecsik wrote:
> Hi,
> 
> On Sat, 12 Mar 2016, Vishwanath Pai wrote:
> 
>> netfilter: fix race condition in ipset save and delete
>>
>> This fix adds a new reference counter (ref_kernel) for the struct ip_set.
>> The other reference counter (ref) is used to track references from the
>> userspace and we need a separate counter to keep track of in-kernel
>> references. Using the same ref counter for both userspace and kernel
>> references causes a race condition which can be demonstrated by the
>> following script:
>>
>> #!/bin/sh
>> ipset create hash_ip1 hash:ip family inet hashsize 1024 maxelem 500000 \
>> counters
>> ipset create hash_ip2 hash:ip family inet hashsize 300000 maxelem 500000 \
>> counters
>> ipset create hash_ip3 hash:ip family inet hashsize 1024 maxelem 500000 \
>> counters
>>
>> ipset save &
>>
>> ipset swap hash_ip3 hash_ip2
>> ipset destroy hash_ip3 /* will crash the machine */
>>
>> Swap will exchange the values of ref so destroy will see ref = 0 instead of
>> ref = 1. With this fix in place swap will not suceed because ipset save
>> still has ref_kernel on the set (ip_set_swap doesn't swap ref_kernel).
>>
>> Both delete and swap will error out if ref_kernel != 0 on the set.
>>
>> Note: The changes to *_head functions is because previously we would
>> increment ref whenever we called these functions, we don't do that
>> anymore.
> 
> Overall, I agree with your patch, however I disagree with the description 
> and some details. 
> 
> It's a race between dump & swap and then destroy - dump and destroy are 
> safe. The "ref" reference counter *is* kernel related: it keeps track of 
> references from other kernel subsystems (netfilter matches/targets) and 
> from ipset itself when a set is a member of another set. It would be 
> misleading to call "ref" as userspace reference counter.
> 
> The reference counter you introduce is for netlink events (technically 
> just for dump), so it would better be named "ref_netlink" instead of 
> "ref_kernel" (similarly, ip_set_get|put_ref_netlink).
> 
> Please update the patch, the description and resubmit. Thanks!
> 
> Best regards,
> Jozsef
> 

Thanks for reviewing, I will update the patch and send it again.

Thanks,
Vishwanath

