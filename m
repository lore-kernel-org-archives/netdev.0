From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [RFC PATCH 2/3] net: macb: Add support for 1588 for Zynq
 Ultrascale+ MPSoC
Date: Tue, 9 Aug 2016 18:40:08 +0200
Message-ID: <99d6c0ce-c3b9-a919-cedb-0af954bac388@atmel.com>
References: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
 <1441958258-35441-3-git-send-email-harinik@xilinx.com>
 <CAFcVECLfXL-=efbUhNeKhiFQgtfv6Z1+JJckg+js7DM-LfFeSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>,
	Boris Brezillon <boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>, <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	"michals@xilinx.com" <michals@xilinx.com>, <anirudh@xilinx.com>
To: Harini Katakam <harinikatakamlinux@gmail.com>,
	Harini Katakam <harini.katakam@xilinx.com>,
	Andrei Pistirica <Andrei.Pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFcVECLfXL-=efbUhNeKhiFQgtfv6Z1+JJckg+js7DM-LfFeSw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 21/09/2015 à 19:49, Harini Katakam a écrit :
> On Fri, Sep 11, 2015 at 1:27 PM, Harini Katakam
> <harini.katakam@xilinx.com> wrote:
>> Cadence GEM in Zynq Ultrascale+ MPSoC supports 1588 and provides a
>> 102 bit time counter with 48 bits for seconds, 30 bits for nsecs and
>> 24 bits for sub-nsecs. The timestamp is made available to the SW through
>> registers as well as (more precisely) through upper two words in
>> an extended BD.
>>
>> This patch does the following:
>> - Adds MACB_CAPS_TSU in zynqmp_config.
>> - Registers to ptp clock framework (after checking for timestamp support in
>>   IP and capability in config).
>> - TX BD and RX BD control registers are written to populate timestamp in
>>   extended BD words.
>> - Timer initialization is done by writing time of day to the timer counter.
>> - ns increment register is programmed as NS_PER_SEC/TSU_CLK.
>>   For a 24 bit subns precision, the subns increment equals
>>   remainder of (NS_PER_SEC/TSU_CLK) * (2^24).
>>   TSU (Time stamp unit) clock is obtained by the  driver from devicetree.
>> - HW time stamp capabilities are advertised via ethtool and macb ioctl is
>>   updated accordingly.
>> - For all PTP event frames, nanoseconds and the lower 5 bits of seconds are
>>   obtained from the BD. This offers a precise timestamp. The upper bits
>>   (which dont vary between consecutive packets) are obtained from the
>>   TX/RX PTP event/PEER registers. The timestamp obtained thus is updated
>>   in skb for upper layers to access.
>> - The drivers register functions with ptp to perform time and frequency
>>   adjustment.
>> - Time adjustment is done by writing to the 1558_ADJUST register.
>>   The controller will read the delta in this register and update the timer
>>   counter register. Alternatively, for large time offset adjustments,
>>   the driver reads the secs and nsecs counter values, adds/subtracts the
>>   delta and updates the timer counter. In order to be as precise as possible,
>>   nsecs counter is read again if secs has incremented during the counter read.
>> - Frequency adjustment is not directly supported by this IP.
>>   addend is the initial value ns increment and similarly addendesub.
>>   The ppb (parts per billion) provided is used as
>>   ns_incr = addend +/- (ppb/rate).
>>   Similarly the remainder of the above is used to populate subns increment.
>>   In case the ppb requested is negative AND subns adjustment greater than
>>   the addendsub, ns_incr is reduced by 1 and subns_incr is adjusted in
>>   positive accordingly.
>>
>> Signed-off-by: Harini Katakam <harinik@xilinx.com>:
>> ---
>>  drivers/net/ethernet/cadence/macb.c |  372 ++++++++++++++++++++++++++++++++++-
>>  drivers/net/ethernet/cadence/macb.h |   64 ++++++
>>  2 files changed, 428 insertions(+), 8 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
>> index bb2932c..b531008 100644
>> --- a/drivers/net/ethernet/cadence/macb.c
>> +++ b/drivers/net/ethernet/cadence/macb.c
>> @@ -30,6 +30,8 @@
>>  #include <linux/of_device.h>
>>  #include <linux/of_mdio.h>

[..]

>> +       unsigned int            ns_incr;
>> +       unsigned int            subns_incr;
>>  };
>>
>>  static inline bool macb_is_gem(struct macb *bp)
>> --
>> 1.7.9.5
> 
> Ping
> 
> Thanks.

Harini,

I come back to this patch of last year and I'm sorry about being so late
answering you.

Andrei who is added to the discussion will have some time to deal with
this feature and we would like to make some progress with it. He already
had some work done on his side before I recall your email.

So, could you please re-send your original 1588 patch with Andrei in
copy so that we can all (re-)start the discussion and progress for
adding this feature.

We must also note that some hardware differences between our platforms
may have an impact on the code and how we implement things (as
highlighted on this forum:
http://www.at91.com/discussions/viewtopic.php/f,12/t,25462.html).
Anyway, we'll overcome this and have a widely tested solution at the end
of the day!

Thanks for your patience, bye!

PS: for some reason, I only have this "ping" part of your email but not
the original one
-- 
Nicolas Ferre
