From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Issue with load across multiple connections
Date: Fri, 31 Mar 2017 15:46:57 -0700
Message-ID: <1491000417.8750.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CALx6S34Qjc5AbROJKbZBmEFX4o4xfqVU41ReoDCgAWv0_uuV5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ulrich@cs.auckland.ac.nz
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36730 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932868AbdCaWrA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 18:47:00 -0400
Received: by mail-pg0-f66.google.com with SMTP id 81so20251301pgh.3
        for <netdev@vger.kernel.org>; Fri, 31 Mar 2017 15:47:00 -0700 (PDT)
In-Reply-To: <CALx6S34Qjc5AbROJKbZBmEFX4o4xfqVU41ReoDCgAWv0_uuV5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-31 at 12:51 -0700, Tom Herbert wrote:
> Hi netdev,
> 
> I'm forwarding this problem report from Ulrich Speidel.
> 
> The correlation to FDs would seem to point to application always
> reading for FDs in order and it seems unlikely that FDs have any
> relevance in the networking stack below the file IO for sockets. Some
> of the stack experts might have a better idea though...
> 
> Thanks,
> Tom
> 

TCP stack has no fairness guarantee, both at sender side and receive
side.

This smells like some memory tuning to me. Some flows, depending on
their start time, can grab big receive/send windows, and others might
hit global memory pressure and fallback to ridiculous windows.

Please provide, on server and client :

cat /proc/sys/net/ipv4/tcp_rmem
cat /proc/sys/net/ipv4/tcp_wmem
cat /proc/sys/net/ipv4/tcp_mem

and maybe nstat output

nstats -n >/dev/null ; < run experiment > ; nstat


But I guess this is really a receiver problem, with too small amount of
memory.


> ---------- Forwarded message ----------
> From: Ulrich Speidel <ulrich@cs.auckland.ac.nz>
> Date: Fri, Mar 31, 2017 at 2:11 AM
> Subject: Linux kernel query
> To: tom@quantonium.net
> Cc: Brian Carpenter <brian@cs.auckland.ac.nz>, Nevil Brownlee
> <n.brownlee@auckland.ac.nz>, lars@steinwurf.com, Lei Qian
> <lqia012@gmail.com>
> 
> 
> Dear Tom,
> 
> I'm a colleague of Brian Carpenter at the University of Auckland. He
> has suggested that I contact you about this as I'm not sure that what
> we have discovered is a bug - it may even be an intended feature but
> I've failed to find it documented anywhere. From all we can tell, the
> problem seems related to how socket file descriptor numbers & SKBs are
> handled in POSIX-compliant kernels. I'm not a kernel hack so apologise
> in advance if terminology isn't always spot-on.
> 
> This is how we triggered the effect: We have a setup in which we have
> multiple physical network clients connect to multiple servers at
> random. On the client side, we create N "channels" (indexed, say 0 to
> N-1) on each physical client. Each channel executes the following
> task:
> 
> 1) create a fresh TCP socket
> 2) connect to a randomly chosen server from our pool
> 3) receive a quantity of data that the server sends (this may be
> somewhere between 0 bytes and hundreds of MB). In our case, we use the
> application merely as a network traffic generator, so the receive
> process consists of recording the number of bytes made available by
> the socket and freeing the buffer without ever actually reading it.
> 4) wait for server disconnect
> 5) free socket (i.e., we're not explicitly re-using the previous
> connection's socket)
> 6) jump back to 1)
> 
> We keep track of the throughput on each channel.
> 
> Note that the effect is the same regardless of whether we implement
> each channel in a process of its own, in a threaded application, or
> whether we use non-blocking sockets and check on them in a loop.
> 
> What we would normally expect is that the each channel would receive
> about the same goodput over time, regardless of the value of N. Note
> that each channel uses a succession of fresh sockets.
> 
> What actually happens is this: For up to approximately N=20 channels
> on a single physical client (we've tried Raspbian and Debian, as well
> as Ubuntu), each channel sees on average substantial and comparable
> levels of throughput, adding up to values approaching network
> interface capacity. Once we push N beyond 20, the throughput on any
> further channels drops to zero very quickly. For N=30, we typically
> see at least half a dozen channels with no throughput at all beyond
> the connection handshake. Throughput on the first 20 or so channels
> remains pretty much unchanged. The sockets on the channels with low or
> no throughput all manage to connect, but remain in connected state but
> receive no data.
> 
> Throughput on the first ~20 channels is sustainable for long periods
> of time - so we're not dealing with an intermittent bug that causes
> our sockets to stall: The affected sockets / channels never receive
> anything (and the sockets around the 20-or-so mark very little). So it
> seems that subsequent sockets on a channel inherit the ability of
> their predecessor to receive data at quantity.
> 
> We also see the issue on a single physical Raspberry client having the
> sole use of 14 Super Micros on GbE interfaces to download from. So we
> know we're definitely not overloading the server side (note that we
> are able to saturate the network to the Pi). Here is some sample data
> from the Pi (my apologies for the rough format):
> 
> Channel index/MB transferred/Number of connections completed+attempted
> 0 2.37 144
> 1 29.32 92
> 2 2.71 132
> 3 10.88 705
> 4 11.90 513
> 5 16.045990 571
> 6 9.631539 598
> 7 15.420138 362
> 8 9.854378 106
> 9 8.975264 315
> 10 8.020266 526
> 11 6.369107 582
> 12 8.877760 277
> 13 8.148640 406
> 14 13.536793 301
> 15 9.804712 55
> 16 7.643378 292
> 17 7.970028 393
> 18 0.000120 1
> 19 9.359919 415
> 20 0.000120 1
> 21 0.000120 1
> 22 12.937519 314
> 23 0.000920 2
> 24 14.561784 362
> 25 0.000240 2
> 26 11.005030 535
> 27 0.000120 1
> 28 0.000120 1
> 29 0.000120 1
> 
> The total data rate in this example was 94.1 Mbps on the 100 Mbps
> connection of the Pi. Experiment duration was 20 seconds on this
> occasion, but the effect is stable - we have observed it for many
> minutes. Once "stuck", a channel remains stuck.
> 
> The fact that the incoming data rate accrues almost exclusively to the
> ~20 busy channels suggests that the sockets on the other channel are
> either advertising a window of 0 bytes or are not generating ACKs for
> incoming data, or both.
> 
> We have considered the possibility of FIN packets getting dropped
> somewhere along the way - not only is this unlikely since they are
> small, but the effect also happens if we connect a server directly by
> cable to a client machine with no network equipment inbetween. Also,
> if lost FINs were to blame, we would see some of the steadfast 20
> channels stall over time as well, given the network load - and we
> don't.
> 
> We then looked at the numerical value of the socket file descriptors
> in use by each channel and noticed that there was a strong correlation
> between the average fd value and the goodput, or for that matter
> between channel index and average fd value.
> 
> When we artificially throttle the data rate that each server is able
> to serve a single client connection on, we get data on vastly more of
> the channels (in fact, that's the workaround we currently use, we're
> getting up to around 40 workable channels that way).
> 
> We note that the POSIX specs on file descriptor allocation demand
> "lowest available first" and that this usually extends to socket fds
> although POSIX doesn't prescribe this. From what I have been able to
> glean from the Linux kernel source I have looked at, sockets are
> entered into a linked list. I presume they are then serviced by the
> kernel in list order, which seems reasonable. However, I suspect (but
> haven't been able to locate the relevant piece of kernel code) that
> the kernel services the list starting at the head up to a point where
> it runs out of time allocated for this task. When it returns to the
> task, it then also seems to return to the head of the list again.
> 
> So it seems that the sockets with lower-numbered fds get serviced with
> priority, thus get their downloads completed first, which releases the
> fd to the table, and therefore makes it highly likely that the same
> channel will be assigned the same low fd when it creates the next
> socket. Higher-valued fds don't get service, don't complete their
> downloads, and in consequence their channels never get to return the
> fds and renew their sockets.
> 
> During my sabbatical last year, I investigated this scenario together
> with Aaron Gulliver from the University of Victoria, Canada, and we
> were able to simulate the effect based on this assumption. The graph
> from our draft paper below shows our (simplified) model in action - my
> apologies for the first draft nature of it, I've been waiting for half
> a year for a free day to complete it. It shows the number of times
> each socket fd (=socket series) was re-used (=connections completed
> using this fd value) during the simulation, as well as the bytes
> received. Ignore the "days" labels - these are a measure of how much
> "downtime" an fd number gets before it's re-used, read "days = time
> slices". Note the exponential y axis and the cliff around the 20 mark,
> i.e., pretty much what we see in practice.
> 
> 
> 
> We have also tried to find a theoretical approach but now think that
> it is combinatorially intractable except in very simple cases.
> 
> I have also copied Lars Nielsen from Steinwurf ApS in Aalborg, who has
> come across what is probably the same issue in a web crawler
> application he was developing. He also observed the magical value of
> about 20 and our "fix" worked for him, too. He has had an indication
> that the effect is anecdotally known in browser developer circles.
> 
> We are well aware that our applications (maintaining and continuously
> renewing a large number of sockets that receive data at
> all-you-can-eat rates) are somewhat unusual, so I am not sure whether
> the effect is even known.
> 
> So, my questions:
> 
> 1) Does the kernel indeed stop processing part-way down the list and
> then return to the head again rather than continue processing where it
> left off?
> 2) If so, is this a bug, or is it intended? I could imagine that the
> effect would help protect existing service connections (e.g., SSH
> logins) in the case of subsequent DDoS attacks, but I'm not sure
> whether that's by coincidence or design.
> 
> Any insights would be welcome!
> 
> Best regards,
> 
> Ulrich
> 
> --
> ****************************************************************
> Dr. Ulrich Speidel
> 
> Department of Computer Science
> 
> Room 303S.594 (City Campus)
> Ph: (+64-9)-373-7599 ext. 85282
> 
> The University of Auckland
> ulrich@cs.auckland.ac.nz
> http://www.cs.auckland.ac.nz/~ulrich/
> ****************************************************************
