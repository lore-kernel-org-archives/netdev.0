From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 01/13] ixgbe: Add support for IPv6 and UDP to ixgbe_get_headlen
Date: Sat, 20 Oct 2012 13:39:22 -0700
Message-ID: <50830BFA.5070409@gmail.com>
References: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>  <1350714367-24208-2-git-send-email-jeffrey.t.kirsher@intel.com> <1350720070.13333.359.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59363 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab2JTUj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 16:39:28 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr4so1173024pbb.19
        for <netdev@vger.kernel.org>; Sat, 20 Oct 2012 13:39:28 -0700 (PDT)
In-Reply-To: <1350720070.13333.359.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2012 1:01 AM, Eric Dumazet wrote:
> On Fri, 2012-10-19 at 23:25 -0700, Jeff Kirsher wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> This change adds support for IPv6 and UDP to ixgbe_get_headlen. The
>> advantage to this is that we can now handle ipv4/UDP, ipv6/TCP, and
>> ipv6/UDP with a single memcpy instead of having to do them in multiple
>> pskb_may_pull calls.
>>
>> A quick bit of testing shows that we increase throughput for a single
>> session of netperf from 8800Mpbs to about 9300Mpbs in the case of ipv6/TCP.
>> As such overall ipv6 performance should improve with this change.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Tested-by: Stephen Ko  <stephen.s.ko@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 15 ++++++++++++++-
>>   1 file changed, 14 insertions(+), 1 deletion(-)
> Thats pretty interesting.
>
> Why this work is not done generically, so that all drivers can have
> benefit of it ?
>
> Even a driver not using fragments could have benefit, because we could
> prefetch() so that GRO stack is faster (no stall to get the last 2 bytes
> of a TCP header when timestamps are used)
>
> Thanks

The ixgbe_get_headlen function originally was written to handle the case 
where we were doing the hardware LRO/RSC feature but we weren't setting 
gso_size.  We were using it to get the size of the header so we could 
determine the average payload size of the frame.  When we switched over 
to page based receive the function came along with it and had actually 
prevented a performance regression for IPv4/TCP which this patch is 
fixing for the other supported protocols.  The main idea of this code is 
now to emulate what our hardware was doing in determining the length of 
the header when we had header-data split enabled.  I hadn't really 
thought of any way it could be used in a generic sense.  The function is 
essentially is built around several assumptions that only apply to the 
igb/ixgbe case such as the fact that the entire block being linear and 
the limitation of the protocols so that they match up with what we used 
to do for header-data split.

That being said, if there is a way for you to use it in the generic case 
feel free to copy the ixgbe version, rename it, and export it for use.  
The key bit for me is that I just need to be able to get the header 
length before calling eth_type_trans as I only want to do one memcpy for 
the entire header.

Thanks,

Alex
