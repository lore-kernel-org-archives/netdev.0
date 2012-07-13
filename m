From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [DANGER 8/7]: ipv4: Cache output routes in fib_info nexthops.
Date: Thu, 12 Jul 2012 17:52:54 -0700
Message-ID: <CAGK4HS_-fQYnmcbBwEE=JywzAO7_nnE8QAOCXk3-WQOjCimPiA@mail.gmail.com>
References: <20120712.104758.253504708560401123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:34602 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515Ab2GMAwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 20:52:55 -0400
Received: by yenl2 with SMTP id l2so3078737yen.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 17:52:55 -0700 (PDT)
In-Reply-To: <20120712.104758.253504708560401123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Something is flaky about it, when I ssh into my test system
> for the first time after a boot there is a strange delay of
> some sort.  It's as if the SYN-ACK is dropped on the way out
> of the test machine, and my desktop has to retry the initial
> SYN.  I plan to investigate this after some sleep.


Dave,
I applied these patches and got the same symptoms. It takes a long
time for ssh to work right after boot but it starts working after
about a minute.
(I am sshing into the machine with the patches applied). My  knowledge
of routing code is rudimentary but I traced the following.

 I think this is because the SYN packets do not even reach the TCP
handler. It looks like ip_route_input_slow() sets the dst.input
function to ip_error().

The code path I saw was as follows:
ip_rcv_finish() eventually calls ip_route_input_slow() wherein
fib_lookup() initially returns a res.type of RTN_UNICAST (why not
RTN_LOCAL?).
However, the following code
 if (!IN_DEV_FORWARD(in_dev))
                goto no_route;

is executed and sets the res.type to RTN_UNREACHABLE.
After the jump to local_input, rth->dst.input is set first to
ip_local_deliver() but again to ip_error().
Due to this, the SYN packet does not even make it to ip_local_deliver
and so the TCP handler is never called.

I did not get a chance to see why it suddenly starts working. Hope
this helps. I will dig around more.

Thanks,
Vijay
