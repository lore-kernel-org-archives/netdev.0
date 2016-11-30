From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] udp: add recvmmsg implementation
Date: Tue, 29 Nov 2016 19:22:33 -0500 (EST)
Message-ID: <20161129.192233.392359849404330043.davem@davemloft.net>
References: <cover.1480086321.git.pabeni@redhat.com>
        <68bfaa7480400457e712fb04ee781410d1bb9479.1480086321.git.pabeni@redhat.com>
        <1165706e-b828-cb12-4bea-b77ccca1cb95@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
        brouer@redhat.com, sd@queasysnail.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37264 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752099AbcK3AWi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 19:22:38 -0500
In-Reply-To: <1165706e-b828-cb12-4bea-b77ccca1cb95@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 25 Nov 2016 18:09:00 +0100

> During review we discussed on how to handle major errors in the kernel:
> 
> The old code and the new code still can report back success even though
> the kernel got back an EFAULT while copying from kernel space to user
> space (due to bad pointers).
> 
> I favor that we drop all packets (also the already received batches) in
> this case and let the code report -EFAULT and increase sk_drops for all
> dropped packets from the queue.
> 
> Currently sk_err is set so the next syscall would get an -EFAULT, which
> seems very bad and can also be overwritten by incoming icmp packets, so
> we never get a notification that we actually had a bad pointer somewhere
> in the mmsghdr. Also delivering -EFAULT on the follow-up syscalls really
> will make people confused that use strace.
> 
> If people would like to know the amount of packets dropped we can make
> sk_drops readable by an getsockopt.
> 
> Thoughts?
> 
> Unfortunately the interface doesn't allow for better error handling.

I think this is a major problem.

If, as a side effect of batch dequeueing the SKBs from the socket,
you cannot stop properly mid-transfer if an error occurs, well then
you simply cannot batch like that.

You have to stop the exact byte where an error occurs mid-stream,
return the successful amount of bytes transferred, and then return
the error on the next recvmmsg call.

There is no other sane error reporting strategy.

If I get 4 frames, and the kernel can successfully copy the first
three and get an -EFAULT on the 4th.  Dammit you better tell the
application this so it can properly process the first 3 packets and
then determine how it is going to error out and recover for the 4th
one.

If we need to add prioritized sk_err stuff, or another value like
"sk_app_err" to handle the ICMP vs. -EFAULT issue, so be it.

I know what you guys are thinking, in that you can't figure out a
way to avoid the transactional overhead if it is necessary to
"put back" some SKBs if one of them in the batch gets a fault.

That's too bad, we need a proper implementation and proper error
reporting.  Those performance numbers are useless if we effectively
lose error notifications.
