From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Wed, 30 Nov 2016 09:42:40 -0800
Message-ID: <086ec7ce-ea6a-55bd-cefe-095c2cad9f09@hpe.com>
References: <20140903165943.372b897b@redhat.com>
 <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
 <20161116131609.4e5726b4@redhat.com>
 <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
 <20161116234022.2bad179b@redhat.com>
 <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117091638.5fab8494@redhat.com>
 <20730b37-d218-a1bb-d0fb-0f838e2a77b5@hpe.com>
 <20161130114339.78c6d4fa@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:39344 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756843AbcK3Rmn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 12:42:43 -0500
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com [15.241.48.73])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id CDFFC29BA
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 17:42:42 +0000 (UTC)
In-Reply-To: <20161130114339.78c6d4fa@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2016 02:43 AM, Jesper Dangaard Brouer wrote:
> Notice the "fib_lookup" cost is still present, even when I use
> option "-- -n -N" to create a connected socket.  As Eric taught us,
> this is because we should use syscalls "send" or "write" on a connected
> socket.

In theory, once the data socket is connected, the send_data() call in 
src/nettest_omni.c is supposed to use send() rather than sendto().

And indeed, based on a quick check, send() is what is being called, 
though it becomes it seems a sendto() system call - with the destination 
information NJULL:

write(1, "send\n", 5)                   = 5
sendto(4, "netperf\0netperf\0netperf\0netperf\0"..., 1024, 0, NULL, 0) = 
1024
write(1, "send\n", 5)                   = 5
sendto(4, "netperf\0netperf\0netperf\0netperf\0"..., 1024, 0, NULL, 0) = 
1024

So I'm not sure what might be going-on there.

You can get netperf to use write() instead of send() by adding a 
test-specific -I option.

happy benchmarking,

rick

>
> My udp_flood tool[1] cycle through the different syscalls:
>
> taskset -c 2 ~/git/network-testing/src/udp_flood 198.18.50.1 --count $((10**7)) --pmtu 2
>              	ns/pkt	pps		cycles/pkt
> send      	473.08	2113816.28	1891
> sendto    	558.58	1790265.84	2233
> sendmsg   	587.24	1702873.80	2348
> sendMmsg/32  	547.57	1826265.90	2189
> write     	518.36	1929175.52	2072
>
> Using "send" seems to be the fastest option.
>
> Some notes on test: I've forced TX completions to happen on another CPU0
> and pinned the udp_flood program (to CPU2) as I want to avoid the CPU
> scheduler to move udp_flood around as this cause fluctuations in the
> results (as it stress the memory allocations more).
>
> My udp_flood --pmtu option is documented in the --help usage text (see below signature)
>
