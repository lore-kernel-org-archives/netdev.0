From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5] net: ipv6: Make address flushing on ifdown
 optional
Date: Wed, 14 Oct 2015 10:09:59 -0600
Message-ID: <561E7E57.2070001@cumulusnetworks.com>
References: <1444667587-13863-1-git-send-email-dsa@cumulusnetworks.com>
 <20151013.184539.1401344867685512636.davem@davemloft.net>
 <1444815241.2154853.409816321.48710CD1@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@redhat.com,
	nicolas.dichtel@6wind.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34997 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266AbbJNQKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 12:10:17 -0400
Received: by padcn9 with SMTP id cn9so27227044pad.2
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 09:10:16 -0700 (PDT)
In-Reply-To: <1444815241.2154853.409816321.48710CD1@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/15 3:34 AM, Hannes Frederic Sowa wrote:
> Hello,
>
> On Wed, Oct 14, 2015, at 03:45, David Miller wrote:
>> From: David Ahern <dsa@cumulusnetworks.com>
>> Date: Mon, 12 Oct 2015 09:33:07 -0700
>>
>>> Currently, all ipv6 addresses are flushed when the interface is configured
>>> down, including global, static addresses:
>>   ...
>>> Add a new sysctl to make this behavior optional. The new setting defaults to
>>> flush all addresses to maintain backwards compatibility. When the setting is
>>> reset global addresses with no expire times are not flushed:
>>   ...
>>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>>
>> Here is what I really don't like about these changes: the failure
>> semantics are terrible.
>>
>> If I add an address or a route, and some memory allocation fails, I get
>> a notification and see that my operation did not succeed.
>>
>> But here, my routes can fail to be added during an ifup and all I will
>> get, at best, is a kernel log message.
>>
>> This places a serious disconnect between what the user asked for and
>> making sure he finds out directly that his operation did not really
>> fully succeed.
>>
>> In fact, this failure handling here during ifup leaves the interface in
>> a partially configured state.
>
> Agreed, it would be better.
>
>> There are really two ways to deal with this properly:
>>
>> 1) Propagate the failure back through the notifiers and fail the ifup
>>     completely when the addrconf_dst_alloc() fails.
>>
>> 2) On ifdown, stash the objects away somewhere so that memory allocation
>>     is not necessary on ifup.
>
> In regard to error propagation I think 2) is the only viable option. I
> don't think why you shouldn't be able to simply remove the ip6_rt_put
> after the ip6_del_rt and keep the dst_entry hanging there and later
> reinsert.

I don't agree with stashing it. IPv4 code does not do that and handling 
the stashed routes makes the implementation more complex than needed.

This latest patch makes IPv6 static addresses on par with IPv4, 
including error paths. On admin link down IPv4 code removes local and 
connected routes. On admin link up they are reinserted. Error paths are 
not handled. ie., any memory allocations or insertion failures are 
silently ignored.

As for this IPv6 patch the only real failure scenario is ENOMEM in the 
dst_alloc.

David
