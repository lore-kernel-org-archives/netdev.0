From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5] net: ipv6: Make address flushing on ifdown
 optional
Date: Wed, 14 Oct 2015 20:46:35 -0600
Message-ID: <561F138B.8060007@cumulusnetworks.com>
References: <20151013.184539.1401344867685512636.davem@davemloft.net>
 <1444815241.2154853.409816321.48710CD1@webmail.messagingengine.com>
 <561E7E57.2070001@cumulusnetworks.com>
 <20151014.180659.1860914575436401565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	hannes@redhat.com, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33133 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754893AbbJOCqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 22:46:33 -0400
Received: by pabrc13 with SMTP id rc13so72253137pab.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 19:46:33 -0700 (PDT)
In-Reply-To: <20151014.180659.1860914575436401565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/15 7:06 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Wed, 14 Oct 2015 10:09:59 -0600
>
>> This latest patch makes IPv6 static addresses on par with IPv4,
>> including error paths.
>
> I don't agree with ipv4's behavior... and just because ipv4 does
> something poorly doesn't mean we get a free pass to replicate that
> lazyness in ipv6.
>

As I stated this patch makes IPv6 on par with IPv4 with regards to 
saving the address and lack of error handling back to the user should a 
failure happen on a link up. Yes, it is best to give the user 
notification of a failure, but step back for a moment and look at the 
bigger picture:

At best the address is saved and restored on a link up (the expected 
outcome for 99.999999...% of the time). At worst the address is removed 
because the prefix route fails a memory allocation and the user is not 
notified. But that is exactly what happens today - the address is 
dropped and the user has to restore it.

As for the 1 failure path -- it's a GFP_ATOMIC memory allocation 
failure. Frankly if that happens lack of an address on an interface is 
the least of the user's problems.

As for the options to fix this existing shortcoming:

1. The existing call_netdevice_notifiers infra does not allow a notifier 
to 'fail' the transaction and roll it back or even to give the user an 
error message.

2. Stashing the prefix route has its merits but it has to deal with 
error paths as well. What if the address is deleted? What if the mask is 
changed while the device is a down state? What if the device is deleted? 
Sure, handle those cases but what other paths are missing from that list?

Both paths introduce a lot of complexity all b/c we want to save the 
address on a link and restore the route on a link up.

Why not take this as a start point that at least does the right thing 
almost every time?

David
