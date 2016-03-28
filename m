From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [RFC net-next 2/2] udp: No longer use SLAB_DESTROY_BY_RCU
Date: Mon, 28 Mar 2016 12:11:19 -0700
Message-ID: <56F981D7.2050801@hpe.com>
References: <1458944964-12890-1-git-send-email-edumazet@google.com>
 <1458944964-12890-3-git-send-email-edumazet@google.com>
 <56F95884.8010901@hpe.com>
 <1459184434.6473.104.camel@edumazet-glaptop3.roam.corp.google.com>
 <56F97B70.1000904@hpe.com>
 <1459191346.6473.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:48362 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbcC1TLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 15:11:21 -0400
In-Reply-To: <1459191346.6473.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2016 11:55 AM, Eric Dumazet wrote:
> On Mon, 2016-03-28 at 11:44 -0700, Rick Jones wrote:
>> On 03/28/2016 10:00 AM, Eric Dumazet wrote:
>>> If you mean that a busy DNS resolver spends _most_ of its time doing :
>>>
>>> fd = socket()
>>> bind(fd  port=0)
>>>     < send and receive one frame >
>>> close(fd)
>>
>> Yes.  Although it has been a long time, I thought that say the likes of
>> a caching named in the middle between hosts and the rest of the DNS
>> would behave that way as it was looking-up names on behalf those who
>> asked it.
>
> I really doubt a modern program would dynamically allocate one UDP port
> for every in-flight request, as it would limit them to number of
> ephemeral ports concurrent requests (~30000 assuming the process can get
> them all on the host)

I was under the impression that individual DNS queries were supposed to 
have not only random DNS query IDs but also originate from random UDP 
source ports.  https://tools.ietf.org/html/rfc5452 4.5 at least touches 
on the topic but I don't see it making it hard and fast.  By section 10 
though it is more explicit:

    This document recommends the use of UDP source port number
    randomization to extend the effective DNS transaction ID beyond the
    available 16 bits.

That being the case, if indeed there were to be 30000-odd concurrent 
requests outstanding "upstream" from that location there'd have to be 
30000 ephemeral ports in play.

rick

>
> Managing a pool would be more efficient (The 1.3 usec penalty becomes
> more like 4 usec in multi threaded programs)
>
> Sure, you always can find badly written programs, but they already hit
> scalability issues anyway.
>
> UDP refcounting cost about 2 cache line misses per packet in stress
> situations, this really has to go, so that well written programs can get
> full speed.
>
>
