From: Kelly Burkhart <kelly.burkhart@gmail.com>
Subject: Poor localhost net performance on recent stable kernel
Date: Thu, 15 Apr 2010 10:44:44 -0500
Message-ID: <q2gfa1e4ce71004150844of9c3aaaeh5e5cc7c20d263a41@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:35550 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540Ab0DOPop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 11:44:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

While working on upgrading distributions, I've noticed that local
network communication is much slower on 2.6.33.2 than on our old
kernel 2.6.16.60 (sles 10.2).

Results of netperf, UDP_RR against localhost I get around 150000 tps
on the new kernel vs. 290000 tps with the old kernel.  The netperf
command:

netperf -T 1 -H 127.0.0.1 -t UDP_RR -c -C -- -r 100

TCP_RR had similar results.  The problem did not exist with TCP_STREAM.

While trying to track this down, I wrote a test program that writes
then reads a 32 bit integer to a pipe:

static void tst_pipe0( int sleep_us )
{
    int pipefd[2];
    int idx;
    uint32_t tarr[ITERS];

    printf("tst_pipe0 -- sleep %dus\n", sleep_us);

    if (pipe(pipefd) < 0)
        err_exit("pipe");

    for(idx=0; idx<ITERS; ++idx) {
        uint32_t btsc;
        uint32_t rtsc;
        uint32_t etsc;
        get_tscl(btsc);
        write(pipefd[1], (char *)&btsc, sizeof(btsc));
        read(pipefd[0], (char *)&rtsc, sizeof(rtsc));
        get_tscl(etsc);
        tarr[idx] = etsc-btsc;
        do_sleep(sleep_us);
    }
    prt_avg(tarr, ITERS);
    close(pipefd[0]);
    close(pipefd[1]);
    printf("\n");
}

There's a dramatic difference if there's a sleep between iterations on
the new kernel.  On the old kernel the write/read round trip takes
1100-1300 cycles with or without sleep.  On the new kernel, with no
sleep the round trip is about 1400 cycles.  It doubles with a 1us
sleep then gradually increases to 12000-14000 cycles then stabilizes
as I increase the sleep time to 1500us.  I'm not sure if this is
related to the netperf difference or is a completely different
scheduling issue.

I'm running on an Intel Xeon X5570 @ 2.93GHz.  Different tick/notick,
preemption, HZ kernel config option values doesn't substantially change
the magnitude of the difference.

Does anyone have any ideas regarding what could be causing the netperf
issue?  And is the pipe microbenchmark meaningful and if so what does
it mean?

Thanks,

-Kelly
