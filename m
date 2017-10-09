From: Levi Pearson <levipearson@gmail.com>
Subject: Re: [PATCH net-next RFC 4/9] net: dsa: mv88e6xxx: add support for
 event capture
Date: Mon, 9 Oct 2017 16:08:50 -0600
Message-ID: <CAEYbN3TpMVPVapmLNCPj69pxP9b_1y8VizS3XvccskcWOrpwEw@mail.gmail.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-5-git-send-email-brandon.streiff@ni.com> <20171008150634.hb7nxwbbmi5xff7m@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Brandon Streiff <brandon.streiff@ni.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Erik Hons <erik.hons@ni.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171008150634.hb7nxwbbmi5xff7m@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 8, 2017 at 9:06 AM, Richard Cochran
<richardcochran@gmail.com> wrote:

>> +static int mv88e6xxx_ptp_enable_perout(struct mv88e6xxx_chip *chip,
>> +                                    struct ptp_clock_request *rq, int on)
>> +{
>> +     struct timespec ts;
>> +     u64 ns;
>> +     int pin;
>> +     int err;
>> +
>> +     pin = ptp_find_pin(chip->ptp_clock, PTP_PF_PEROUT, rq->extts.index);
>> +
>> +     if (pin < 0)
>> +             return -EBUSY;
>> +
>> +     ts.tv_sec = rq->perout.period.sec;
>> +     ts.tv_nsec = rq->perout.period.nsec;
>> +     ns = timespec_to_ns(&ts);
>> +
>> +     if (ns > U32_MAX)
>> +             return -ERANGE;
>> +
>> +     mutex_lock(&chip->reg_lock);
>> +
>> +     err = mv88e6xxx_config_periodic_trig(chip, (u32)ns, 0);
>
> Here you ignore the phase of the signal given in the trq->perout.start
> field.  That is not what the user expects.  For periodic outputs where
> the phase cannot be set, we really would need a new ioctl.
>
> However, in this case, you should just drop this functionality.  I
> understand that this works with your adjustable external oscillator,
> but we cannot support that in mainline (at least, not yet).

I've been working with this patchset and just came across this
limitation as well. The periodic timer output is the basis of the Qbv
t0 timer in devices that support Qbv, and setting this up with the
correct start time is pretty important in that context. The hardware
does support setting a start time, but it must be specified according
to the cycle count of the free-running timer rather than a nanosecond
value. I think this can be worked out from the values stored in the
timecounter struct and I'm writing some code for it now, but if you've
already written something I'd be happy to integrate that instead.

Another issue related to this is that while the free-running counter
in the hardware can't be easily adjusted, the periodic event generator
*can* be finely adjusted (via picosecond and sub-picosecond
accumulators) to correct for drift between the local clock and the PTP
grandmaster time. So to be semantically correct, this needs to be both
started at the right time *and* it needs to have the periodic
corrections made so that the fine correction parameters in the
hardware keep it adjusted to be synchronous with PTP grandmaster time.

So, taking this functionality out in the first pass seems like a good
move for Brandon to take, but I'm working on a complete implementation
for it. I think I've got a handle on how to do it, but if you have any
suggestions, I'm open to them.


Levi
