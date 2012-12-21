From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] IP_MAX_MTU value
Date: Fri, 21 Dec 2012 10:19:57 -0800
Message-ID: <50D4A84D.1010402@hp.com>
References: <1356072468.21834.4805.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:8115 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab2LUSUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 13:20:03 -0500
In-Reply-To: <1356072468.21834.4805.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2012 10:47 PM, Eric Dumazet wrote:
> Hi David
>
> We have the following definition in net/ipv4/route.c
>
> #define IP_MAX_MTU   0xFFF0
>
> This means that "netperf -t UDP_STREAM", using UDP messages of 65507
> bytes, are fragmented on loopback interface (while its MTU is now 65536
> and should allow those UDP messages being sent without fragments)
>
> I guess Rick chose 65507 bytes in netperf because it was related to the
> max IPv4 datagram length :
>
> 65507 + 28 = 65535

That is correct.  From src/nettest_opmni.c:

/* choosing the default send size is a trifle more complicated than it
    used to be as we have to account for different protocol limits */

#define UDP_LENGTH_MAX (0xFFFF - 28)

static int
choose_send_size(int lss, int protocol) {

   int send_size;

   if (lss > 0) {
     send_size = lss_size;

     /* we will assume that everyone has IPPROTO_UDP and thus avoid an
        issue with Windows using an enum */
     if ((protocol == IPPROTO_UDP) && (send_size > UDP_LENGTH_MAX))
       send_size = UDP_LENGTH_MAX;

   }
   else {
     send_size = 4096;
   }
   return send_size;
}

And I figured that while IPv6 allows even larger sizes, the likelihood 
of it mattering in the then near/medium term was minimal.

> Changing IP_MAX_MTU from 0xFFF0 to 0x10000 seems safe [1], but I might
> miss something really obvious ?

If you go beyond the protocol limit of an IPv4 datagram, won't it be 
necessary to  start being a bit more conditional on IPv4 vs IPv6?

> It might be because in old days we reserved 16 bytes for the ethernet
> header, and we wanted to avoid kmalloc() round-up to kmalloc-131072
> slab ?
>
> If so, we certainly can limit skb->head to 32 or 64 KB and complete with
> page fragments the remaining space.
>
> Thanks
>
> [1] performance increase is ~50%

99 times out of 10 I will assert that faster is better, but do we need 
another 50% for UDP over loopback with that large a message size?

happy benchmarking,

rick jones
