From: levipearson@gmail.com
Subject: Re: [PATCH RFC V1 net-next 0/6] Time based packet transmission
Date: Wed, 20 Sep 2017 11:35:33 -0600
Message-ID: <20170920173533.32537-1-levipearson@gmail.com>
References: <cover.1505719061.git.rcochran@linutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, vinicius.gomes@intel.com,
        andre.guedes@intel.com, john.stultz@linaro.org,
        jesus.sanchez-palencia@intel.com, henrik@austad.us,
        tglx@linutronix.de, anna-maria@linutronix.de, davem@davemloft.net
To: rcochran@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1505719061.git.rcochran@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This series is an early RFC that introduces a new socket option
> allowing time based transmission of packets.  This option will be
> useful in implementing various real time protocols over Ethernet,
> including but not limited to P802.1Qbv, which is currently finding
> its way into 802.1Q.
> 
> * Open questions about SO_TXTIME semantics
> 
>   - What should the kernel do if the dialed Tx time is in the past?
>     Should the packet be sent ASAP, or should we throw an error?

Based on the i210 and latest NXP/Freescale FEC launch time behavior,
the hardware timestamps work over 1-second windows corresponding to
the time elapsed since the last PTP second began. When considering the
head-of-queue frame, the launch time is compared to the elapsed time
counter and if the elapsed time is between exactly the launch time and
half a second after the launch time, it is launched. If you enqueue a
frame with a scheduled launch time that ends up more than half a second
late, it is considered by the hardware to be scheduled *in the future*
at the offset belonging to the next second after the 1-second window
wraps around.

So *slightly* late (<<.5sec late) frames could be scheduled as normal,
but approaching .5sec late frames would have to either be dropped or 
have their schedule changed to avoid blocking the queue for a large
fraction of a second.

I don't like the idea of changing the scheduled time, and anything that
is close to half a second late is most likely useless. But it is also
reasonable to let barely-late frames go out ASAP--in the case of a Qav-
shaped stream, the bunching would get smoothed out downstream. A timed
launch schedule need not be used as an exact time, but a "don't send
before time X" flag. Both are useful in different circumstances.

A configurable parameter for allowable lateness, with the upper bound
set by the driver based on the hardware capabilities, seems ideal.
Barring that, I would suggest dropping frames with already-missed
launch times.

> 
>   - Should the kernel inform the user if it detects a missed deadline,
>     via the error queue for example?

I think some sort of counter for mis-scheduled/late-delivered frames
would be in keeping with the general 802.1 error handling strategy.

> 
>   - What should the timescale be for the dialed Tx time?  Should the
>     kernel select UTC when using the SW Qdisc and the HW time
>     otherwise?  Or should the socket option include a clockid_t?

When I implemented something like this, I left it relative to the HW
time for the sake of simplicity, but I don't have a strong opinion.

> 
> * Things todo
> 
>   - Design a Qdisc for purpose of configuring SO_TXTIME.  There should
>     be one option to dial HW offloading or SW best effort.

You seem focused on Qbv, but there is another aspect of the endpoint
requirements for Qav that this would provide a perfect use case for. A
bridge can treat all traffic in a Qav-shaped class equally, but an
endpoint must essentially run one credit-based shaper per active stream
feeding into the class--this is because a stream must adhere to its
frames-per-interval promise in its t-spec, and when the observation
interval is not an even multiple of the sample rate, it will occasionally
have an observation interval with no frame. This leaves extra bandwidth
in the class reservation, but it cannot be used by any other stream if
it would cause more than one frame per interval to be sent!

Even if a stream is not explicitly scheduled in userspace, a per-stream
Qdisc could apply a rough launch time that the class Qdisc (or hardware
shaping) would use to ensure the frames-per-interval aspect of the
reservation for the stream is adhered to. For example, each observation
interval could be assigned a launch time, and all streams would get a
number of frames corresponding to their frames-per-interval reservation
assigned that same launch time before being put into the class queue.
The i210's shaper would then only consider the current interval's set 
of frames ready to launch, and spread them evenly with its hardware
credit-based shaping.

For industrial and automotive control applications, a Qbv Qdisc based on
SO_TXTIME would be very interesting, but pro and automotive media uses
will most likely continue to use SRP + Qav, and these are becoming
increasingly common uses as you can see by the growing support for Qav in
automotive chips.

>   - Implement the SW best effort variant.  Here is my back of the
>     napkin sketch.  Each interface has its own timerqueue keeping the
>     TXTIME packets in order and a FIFO for all other traffic.  A guard
>     window starts at the earliest deadline minus the maximum MTU minus
>     a configurable fudge factor.  The Qdisc uses a hrtimer to transmit
>     the next packet in the timerqueue.  During the guard window, all
>     other traffic is defered unless the next packet can be transmitted
>     before the guard window expires.

This sounds plausible to me.

> 
> * Current limitations
> 
>   - The driver does not handle out of order packets.  If user space
>     sends a packet with an earlier Tx time, then the code should stop
>     the queue, reshuffle the descriptors accordingly, and then
>     restart the queue.

You might store the last scheduled timestamp in the driver private struct
and drop any frame with a timestamp not greater or equal to the last one.

> 
>   - The driver does not correctly queue up packets in the distant
>     future.  The i210 has a limited time window of +/- 0.5 seconds.
>     Packets with a Tx time greater than that should be deferred in
>     order to enqueue them later on.

The limit is not half a second in the future, but half a second from the
previous scheduled frame if one is enqueued. Another use case for the last
scheduled frame field. There are definitely cases that might need to be
deferred though.

> 
> * Performance measurements
> 
>   1. Prepared a PC and the Device Under Test (DUT) each with an Intel
>      i210 card connected with a crossover cable.
>   2. The DUT was a Pentium(R) D CPU 2.80GHz running PREEMPT_RT
>      4.9.40-rt30 with about 50 usec maximum latency under cyclictest.
>   3. Synchronized the DUT's PHC to the PC's PHC using ptp4l.
>   4. Synchronized the DUT's system clock to its PHC using phc2sys.
>   5. Started netperf to produce some network load.
>   6. Measured the arrival time of the packets at the PC's PHC using
>      hardware time stamping.
> 
>   I ran ten minute tests both with and without using the so_txtime
>   option, with a period was 1 millisecond.  I then repeated the
>   so_txtime case but with a 250 microsecond period.  The measured
>   offset from the expected period (in nanoseconds) is shown in the
>   following table.
> 
>   |         | plain preempt_rt |     so_txtime | txtime @ 250 us |
>   |---------+------------------+---------------+-----------------|
>   | min:    |    +1.940800e+04 | +4.720000e+02 |   +4.720000e+02 |
>   | max:    |    +7.556000e+04 | +5.680000e+02 |   +5.760000e+02 |
>   | pk-pk:  |    +5.615200e+04 | +9.600000e+01 |   +1.040000e+02 |
>   | mean:   |    +3.292776e+04 | +5.072274e+02 |   +5.073602e+02 |
>   | stddev: |    +6.514709e+03 | +1.310849e+01 |   +1.507144e+01 |
>   | count:  |           600000 |        600000 |         2400000 |
> 
>   Using so_txtime, the peak to peak jitter is about 100 nanoseconds,
>   independent of the period.  In contrast, plain preempt_rt shows a
>   jitter of of 56 microseconds.  The average delay of 507 nanoseconds
>   when using so_txtime is explained by the documented input and output
>   delays on the i210 cards.
> 
>   The test program is appended, below.  If anyone is interested in
>   reproducing this test, I can provide helper scripts.
> 
> Thanks,
> Richard
> 

< most of test program snipped >

> 
> 	/*
> 	 * We specify the transmission time in the CMSG.
> 	 */
> 	if (use_so_txtime) {
> 		msg.msg_control = u.buf;
> 		msg.msg_controllen = sizeof(u.buf);
> 		cmsg = CMSG_FIRSTHDR(&msg);
> 		cmsg->cmsg_level = SOL_SOCKET;
> 		cmsg->cmsg_type = SO_TXTIME;
> 		cmsg->cmsg_len = CMSG_LEN(sizeof(__u64));
> 		*((__u64 *) CMSG_DATA(cmsg)) = txtime;
> 	}
> 	cnt = sendmsg(fd, &msg, 0);

An interesting use case I have explored is to increase efficiency by batching
transmissions with sendmmsg. This is attractive when getting large chunks of
audio data from ALSA and scheduling them for transmit all at once.

Anyway, I am wholly in favor of this proposal--in fact, it is very similar to
a patch set I shared with Eric Mann and others at Intel in early Dec 2016 with
the intention to get some early feedback before submitting here. I never heard
back and got busy with other things. I only mention this since you said
elsewhere that you got this idea from Eric Mann yourself, and I am curious
whether Eric and I came up with it independently (which I would not be
surprised at).


Levi
