From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Subject: Re: [PATCH RFC V1 net-next 0/6] Time based packet transmission
Date: Wed, 18 Oct 2017 15:18:55 -0700
Message-ID: <743a4550-7344-5e73-bf6d-6ec368263ad9@intel.com>
References: <cover.1505719061.git.rcochran@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Andre Guedes <andre.guedes@intel.com>,
        Anna-Maria Gleixner <anna-maria@linutronix.de>,
        David Miller <davem@davemloft.net>,
        Henrik Austad <henrik@austad.us>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        "Briano, Ivan" <ivan.briano@intel.com>,
        Levi Pearson <levipearson@gmail.com>
To: Richard Cochran <rcochran@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1505719061.git.rcochran@linutronix.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,


On 09/18/2017 12:41 AM, Richard Cochran wrote:
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
> 
>   - Should the kernel inform the user if it detects a missed deadline,
>     via the error queue for example?
> 
>   - What should the timescale be for the dialed Tx time?  Should the
>     kernel select UTC when using the SW Qdisc and the HW time
>     otherwise?  Or should the socket option include a clockid_t?
> 
> * Things todo
> 
>   - Design a Qdisc for purpose of configuring SO_TXTIME.  There should
>     be one option to dial HW offloading or SW best effort.
> 
>   - Implement the SW best effort variant.  Here is my back of the
>     napkin sketch.  Each interface has its own timerqueue keeping the
>     TXTIME packets in order and a FIFO for all other traffic.  A guard
>     window starts at the earliest deadline minus the maximum MTU minus
>     a configurable fudge factor.  The Qdisc uses a hrtimer to transmit
>     the next packet in the timerqueue.  During the guard window, all
>     other traffic is defered unless the next packet can be transmitted
>     before the guard window expires.


Even for HW offloading this timerqueue could be used for enforcing that packets
are always sorted by their launch time when they get enqueued into the
netdevice. Of course, assuming that this would be something that we'd like to
provide from within the kernel.



> 
> * Current limitations
> 
>   - The driver does not handle out of order packets.  If user space
>     sends a packet with an earlier Tx time, then the code should stop
>     the queue, reshuffle the descriptors accordingly, and then
>     restart the queue.


Wouldn't be an issue if the above was provided.



> 
>   - The driver does not correctly queue up packets in the distant
>     future.  The i210 has a limited time window of +/- 0.5 seconds.
>     Packets with a Tx time greater than that should be deferred in
>     order to enqueue them later on.
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


This is great. Just out of curiosity, were you using vlans on your tests?


> 
>   The test program is appended, below.  If anyone is interested in
>   reproducing this test, I can provide helper scripts.


I might try to reproduce them soon. I would appreciate if you could provide me
with the scripts, please.


Thanks,
Jesus




> 
> Thanks,
> Richard
> 
> 
> Richard Cochran (6):
>   net: Add a new socket option for a future transmit time.
>   net: skbuff: Add a field to support time based transmission.
>   net: ipv4: raw: Hook into time based transmission.
>   net: ipv4: udp: Hook into time based transmission.
>   net: packet: Hook into time based transmission.
>   net: igb: Implement time based transmission.
> 
>  arch/alpha/include/uapi/asm/socket.h           |  3 ++
>  arch/frv/include/uapi/asm/socket.h             |  3 ++
>  arch/ia64/include/uapi/asm/socket.h            |  3 ++
>  arch/m32r/include/uapi/asm/socket.h            |  3 ++
>  arch/mips/include/uapi/asm/socket.h            |  3 ++
>  arch/mn10300/include/uapi/asm/socket.h         |  3 ++
>  arch/parisc/include/uapi/asm/socket.h          |  3 ++
>  arch/powerpc/include/uapi/asm/socket.h         |  3 ++
>  arch/s390/include/uapi/asm/socket.h            |  3 ++
>  arch/sparc/include/uapi/asm/socket.h           |  3 ++
>  arch/xtensa/include/uapi/asm/socket.h          |  3 ++
>  drivers/net/ethernet/intel/igb/e1000_82575.h   |  1 +
>  drivers/net/ethernet/intel/igb/e1000_defines.h | 68 +++++++++++++++++++++++++-
>  drivers/net/ethernet/intel/igb/e1000_regs.h    |  5 ++
>  drivers/net/ethernet/intel/igb/igb.h           |  3 +-
>  drivers/net/ethernet/intel/igb/igb_main.c      | 68 +++++++++++++++++++++++---
>  include/linux/skbuff.h                         |  2 +
>  include/net/sock.h                             |  2 +
>  include/uapi/asm-generic/socket.h              |  3 ++
>  net/core/sock.c                                | 12 +++++
>  net/ipv4/raw.c                                 |  2 +
>  net/ipv4/udp.c                                 |  5 +-
>  net/packet/af_packet.c                         |  6 +++
>  23 files changed, 200 insertions(+), 10 deletions(-)
> 
