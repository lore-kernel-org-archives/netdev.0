From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH RFC V1 net-next 0/6] Time based packet transmission
Date: Tue, 19 Sep 2017 16:43:02 +0200
Message-ID: <20170919144302.GB4347@localhost>
References: <cover.1505719061.git.rcochran@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andre Guedes <andre.guedes@intel.com>,
        Henrik Austad <henrik@austad.us>, linux-kernel@vger.kernel.org,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        intel-wired-lan@lists.osuosl.org,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Anna-Maria Gleixner <anna-maria@linutronix.de>,
        David Miller <davem@davemloft.net>
To: Richard Cochran <rcochran@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1505719061.git.rcochran@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2017 at 09:41:15AM +0200, Richard Cochran wrote:
> This series is an early RFC that introduces a new socket option
> allowing time based transmission of packets.  This option will be
> useful in implementing various real time protocols over Ethernet,
> including but not limited to P802.1Qbv, which is currently finding
> its way into 802.1Q.

If I understand it correctly, this also allows us to make a PTP/NTP
"one-step" clock with HW that doesn't support it directly.

> * Open questions about SO_TXTIME semantics
> 
>   - What should the kernel do if the dialed Tx time is in the past?
>     Should the packet be sent ASAP, or should we throw an error?

Dropping the packet with an error would make more sense to me.

>   - What should the timescale be for the dialed Tx time?  Should the
>     kernel select UTC when using the SW Qdisc and the HW time
>     otherwise?  Or should the socket option include a clockid_t?

I think for applications that don't (want to) bind their socket to a
specific interface it would be useful if the cmsg specified clockid_t
or maybe if_index. If the packet would be sent using a different
PHC/interface, it should be dropped.

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

Nice!

-- 
Miroslav Lichvar
