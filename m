From: Andi Kleen <ak@muc.de>
Subject: Re: TCP prequeue performance
Date: Thu, 16 Jun 2005 01:34:48 +0200
Message-ID: <m1br679otj.fsf@muc.de>
References: <BED5FA3B.2A0%cndougla@purdue.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261660AbVFOXfB@vger.kernel.org>
To: Chase Douglas <cndougla@purdue.edu>
In-Reply-To: <BED5FA3B.2A0%cndougla@purdue.edu> (Chase Douglas's message of
 "Wed, 15 Jun 2005 15:31:07 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chase Douglas <cndougla@purdue.edu> writes:
>
> I then disabled the prequeue mechanism by changing net/ipv4/tcp.c:1347 of
> 2.6.11:
>
> if (tp->ucopy.task == user_recv) {
>     to
> if (0 && tp->ucopy.task == user_recv) {

You actually didn't disable it completely - it would still be filled. 
To really disable it set net.ipv4.tcp_lowlatency, that disables
even the early queueing and will process all incoming TCP in softirq context
only.

>
> The same benchmark then yielded:
>
> time ./client 10000 10000 100000 1 500000000 recv
>
> real    1m21.928s
> user    0m1.579s
> sys     0m8.330ss
>
> Note the decreases in the system and real times. These numbers are fairly
> stable through 10 consecutive benchmarks of each. If I change message sizes
> and number of connections, the difference can narrow or widen, but usually
> the non-prequeue beats the prequeue with respect to system and real time.
>
> It might be that I've just found an instance where the prequeue is slower
> than the "slow" path. I'm not quite sure why this would be. Does anyone have
> any thoughts on this?

prequeue adds latency. Its original purpose was to be able to 
do combined checksum copy to user space, but that is not very useful
anymore with modern NICs which all do hardware checksumming. 
The only purpose it has left is to batch the TCP processing
better and in particular to account it to the scheduler.

When the receiver does not process the data in time 
the delayed ack timer takes over and processes the data.

Now the way you disabled it is interesting. The data would
be still queued, but in user process would be never emptied.

This means data is always processed later in the delack
timer in your hacked kernel. 

This will lead to batching of the processing (because
after upto 200ms there will be many more packet in the queues), 
and seems to save CPU time in your case.

Basically you added something similar to the the anticipatory scheduler
which adds artifical delays into disk scheduling to your TCP receiver
to get better batching. It seems to work for you. 

I think it is unlikely adding artificial processing delays like this
will help in many cases though, normally early delivery of received
data to user space should be better.

-Andi
