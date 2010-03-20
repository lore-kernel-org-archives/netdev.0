From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: implement basic garbage collection for bundles
Date: Sat, 20 Mar 2010 14:42:02 +0200
Message-ID: <4BA4C29A.8000806@iki.fi>
References: <1269087341-7009-1-git-send-email-timo.teras@iki.fi> <20100320123247.GB1930@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:64359 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401Ab0CTMmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 08:42:04 -0400
Received: by ewy8 with SMTP id 8so235344ewy.28
        for <netdev@vger.kernel.org>; Sat, 20 Mar 2010 05:42:02 -0700 (PDT)
In-Reply-To: <20100320123247.GB1930@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Mar 20, 2010 at 02:15:41PM +0200, Timo Teras wrote:
>> The dst core calls garbage collection only from dst_alloc when
>> the dst entry threshold is exceeded. Xfrm core currently checks
>> bundles only on NETDEV_DOWN event.
>>
>> Previously this has not been a big problem since xfrm gc threshold
>> was small, and they were generated all the time due to another bug.
>>
>> Since after a33bc5c15154c835aae26f16e6a3a7d9ad4acb45
>> ("xfrm: select sane defaults for xfrm[4|6] gc_thresh") we can have
>> large gc threshold sizes (>200000 on machines with normal amount
>> of memory) the garbage collection does not get triggered under
>> normal circumstances. This can result in enormous amount of stale
>> bundles. Further more, each of these stale bundles keep a reference
>> to ipv4/ipv6 rtable entries which are already gargage collected and
>> put to dst core "destroy free'd dst's" list. Now this list can grow
>> to be very large, and the dst core periodic job can bring even a fast
>> machine to it's knees.
> 
> So why do we need this larger threshold in the first place? Neil?

Actually it looks like that on ipv6 side the gc_thresh is something
more normal. On ipv4 side it's insanely big. The 1/2 ratio is not
what ipv4 rtable uses for it's own gc_thresh. Looks like it's using
1/16 ratio which yields much better value.

But even if we have the gc_thresh back to 1024 or similar size,
it is still a good thing to do some basic gc on xfrm bundles so
that the underlaying rtable dst's can be freed before they end up
in the dst core list.

- Timo

