From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [RFC PATCH] xfrm: avoid to send/receive the exceeding hard
 lifetime data
Date: Fri, 14 Dec 2012 14:58:03 +0800
Message-ID: <CAJFZqHyUSHS3-TjkGQ3WiD486MCCTbiRd4vXUAcbJ=ZqqsnQoA@mail.gmail.com>
References: <1355387152-9963-1-git-send-email-roy.qing.li@gmail.com>
	<20121213101422.GF18940@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:34478 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab2LNG6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 01:58:05 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so3448728vcd.19
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 22:58:04 -0800 (PST)
In-Reply-To: <20121213101422.GF18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/13 Steffen Klassert <steffen.klassert@secunet.com>:
> On Thu, Dec 13, 2012 at 04:25:52PM +0800, roy.qing.li@gmail.com wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>>
>> If setkey sets both bh and bs as 1024, and the total send and receive package
>> size is 1024, then if next package size is too large, this package should be
>> discard.
>>
>> Example, first package size is 1000, send success, then the second package
>> is 500, 1000+500 is larger than 1024, so the second package should be discard.
>>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>> ---
>>  net/xfrm/xfrm_input.c  |    6 +++---
>>  net/xfrm/xfrm_output.c |    6 +++---
>>  2 files changed, 6 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
>> index ab2bb42..d0de8f3 100644
>> --- a/net/xfrm/xfrm_input.c
>> +++ b/net/xfrm/xfrm_input.c
>> @@ -178,6 +178,9 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
>>                       goto drop_unlock;
>>               }
>>
>> +             x->curlft.bytes += skb->len;
>> +             x->curlft.packets++;
>> +
>
> This is a bit critical on input. We should only increment these values
> if the integrity check on this packet was successfull. Otherwise someone
> could spam us with invalid packets and trigger a state expiry.
>
> If a synchronous crypto algorithm is used, we send at most one packet too
> much. The maximal byte count was not yet reached and RFC 2401 says not
> much on how to handle the packet that reaches the maximal byte count,
> so this is probaply ok.
>

Yes, RFC does not say how to handle this packet.

But when I do a IPsec compliance test with IxANVL, the test case 5.3/5.11,
which reports a error because it expects this packet should be dropped, but not.


I do not know if it is bug, or if it is valuable to fix it?

-Li

> But if an asynchronous crypto algorithm is used, we can send a lot
> of packets too much. So we should probaply add a second expiry check
> after resume from asynchronous crypto. We do this already with the replay
> check.
>
