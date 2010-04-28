From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Poor localhost net performance on recent stable kernel
Date: Wed, 28 Apr 2010 12:25:02 -0700
Message-ID: <20100428122502.95647ceb.akpm@linux-foundation.org>
References: <q2gfa1e4ce71004150844of9c3aaaeh5e5cc7c20d263a41@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kelly Burkhart <kelly.burkhart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40258 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756747Ab0D1TZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:25:33 -0400
In-Reply-To: <q2gfa1e4ce71004150844of9c3aaaeh5e5cc7c20d263a41@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Apr 2010 10:44:44 -0500
Kelly Burkhart <kelly.burkhart@gmail.com> wrote:

> Hello,
> 
> While working on upgrading distributions, I've noticed that local
> network communication is much slower on 2.6.33.2 than on our old
> kernel 2.6.16.60 (sles 10.2).
> 
> Results of netperf, UDP_RR against localhost I get around 150000 tps
> on the new kernel vs. 290000 tps with the old kernel.  The netperf
> command:
> 
> netperf -T 1 -H 127.0.0.1 -t UDP_RR -c -C -- -r 100

I ran this command on a Red Hat 2.6.18-1.2868 kernel and on 2.6.34-rc5.

2.6.18-1.2868: 43903.29 per second
2.6.34-rc5:    72506.11 per second

IIRC, localhost communications have always exhibited quite large
variations between kernel versions depending on various vagaries
of alignemnt, cacheline sharing, etc.

> TCP_RR had similar results.  The problem did not exist with TCP_STREAM.
> 
> While trying to track this down, I wrote a test program that writes
> then reads a 32 bit integer to a pipe:
> 
> static void tst_pipe0( int sleep_us )
> {
>     int pipefd[2];
>     int idx;
>     uint32_t tarr[ITERS];
> 
>     printf("tst_pipe0 -- sleep %dus\n", sleep_us);
> 
>     if (pipe(pipefd) < 0)
>         err_exit("pipe");
> 
>     for(idx=0; idx<ITERS; ++idx) {
>         uint32_t btsc;
>         uint32_t rtsc;
>         uint32_t etsc;
>         get_tscl(btsc);
>         write(pipefd[1], (char *)&btsc, sizeof(btsc));
>         read(pipefd[0], (char *)&rtsc, sizeof(rtsc));
>         get_tscl(etsc);
>         tarr[idx] = etsc-btsc;
>         do_sleep(sleep_us);
>     }
>     prt_avg(tarr, ITERS);
>     close(pipefd[0]);
>     close(pipefd[1]);
>     printf("\n");
> }
> 
> There's a dramatic difference if there's a sleep between iterations on
> the new kernel.  On the old kernel the write/read round trip takes
> 1100-1300 cycles with or without sleep.  On the new kernel, with no
> sleep the round trip is about 1400 cycles.  It doubles with a 1us
> sleep then gradually increases to 12000-14000 cycles then stabilizes
> as I increase the sleep time to 1500us.  I'm not sure if this is
> related to the netperf difference or is a completely different
> scheduling issue.
> 
> I'm running on an Intel Xeon X5570 @ 2.93GHz.  Different tick/notick,
> preemption, HZ kernel config option values doesn't substantially change
> the magnitude of the difference.
> 
> Does anyone have any ideas regarding what could be causing the netperf
> issue?  And is the pipe microbenchmark meaningful and if so what does
> it mean?

Pipes don't share much code with udp-to-localhost - this is probably
something different.

If you were using two processes then I'd cheerily blame the scheduler. 
Because blaming the scheduler for WeirdShitWhichBroke is usually
correct.  But as you're using a single process then the pipe code
itself is a more likely source for any slowdowns.

As for the strange behavior with sleeps: dunno.  There are various
adjustments made to the sleep duration when performing short sleeps -
some in-kernel, perhaps some in glibc.  Plus we've been evolving the
internal implementation for sleeps, and changes in x86 clocksources and
NOHZ could impact the accuracy of the sleep duration.  So perhaps
what's happening is that different kernels are sleeping for different
durations when asked to sleep for short durations.

If it's not that then it's probably the scheduler ;) But even the
scheduler would have trouble causing these sorts of effects if the
machine is otherwise idle.

