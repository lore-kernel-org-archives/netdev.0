From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH net-next 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Wed, 14 Dec 2011 14:33:09 -0800
Message-ID: <1323901989.19702.12.camel@jbrandeb-mobl2>
References: <cover.1323744724.git.richardcochran@gmail.com>
	 <388385c50909f63bff239894c60dbb00abc65c93.1323744725.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16789 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758204Ab1LNWdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 17:33:11 -0500
In-Reply-To: <388385c50909f63bff239894c60dbb00abc65c93.1323744725.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-12-12 at 19:00 -0800, Richard Cochran wrote:
> This commit removes the legacy timecompare code from the igb driver and
> offers a tunable PHC instead.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Richard, first, thanks for this work, I have some feedback and request
you make a V2.

> -       /*
> -        * The timestamp latches on lowest register read. For the 82580
> -        * the lowest register is SYSTIMR instead of SYSTIML.  However we never
> -        * adjusted TIMINCA so SYSTIMR will just read as all 0s so ignore it.
> -        */

Please keep this comment in your new igb_82580_systim_read, it explains
a bit of *why* we are doing something.  There were a lot of explanatory
comments that you removed, please audit the "-" lines of your patch and
add back the comments that are appropriate in your new code. 

> -       if (hw->mac.type >= e1000_82580) {
> -               stamp = rd32(E1000_SYSTIMR) >> 8;
> -               shift = IGB_82580_TSYNC_SHIFT;
> -       }
> -
> -       stamp |= (u64)rd32(E1000_SYSTIML) << shift;
> -       stamp |= (u64)rd32(E1000_SYSTIMH) << (shift + 32);
> -       return stamp;
> -}
> -
>  /**
>   * igb_get_hw_dev - return device
>   * used by hardware layer to print debugging information
> @@ -2080,7 +2052,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
> 
>  #endif
>         /* do hw tstamp init after resetting */
> -       igb_init_hw_timer(adapter);
> +       igb_ptp_init(adapter);
> 
>         dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n");
>         /* print bus type/speed/width info */
> @@ -2150,6 +2122,8 @@ static void __devexit igb_remove(struct pci_dev *pdev)
>         struct igb_adapter *adapter = netdev_priv(netdev);
>         struct e1000_hw *hw = &adapter->hw;
> 
> +       igb_ptp_remove(adapter);
> +
>         /*
>          * The watchdog timer may be rescheduled, so explicitly
>          * disable watchdog from being rescheduled.
> @@ -2269,112 +2243,6 @@ out:
>  }
> 
>  /**
> - * igb_init_hw_timer - Initialize hardware timer used with IEEE 1588 timestamp
> - * @adapter: board private structure to initialize
> - *
> - * igb_init_hw_timer initializes the function pointer and values for the hw
> - * timer found in hardware.
> - **/
> -static void igb_init_hw_timer(struct igb_adapter *adapter)
> -{
> -       struct e1000_hw *hw = &adapter->hw;
> -
> -       switch (hw->mac.type) {
> -       case e1000_i350:
> -       case e1000_82580:
> -               memset(&adapter->cycles, 0, sizeof(adapter->cycles));
> -               adapter->cycles.read = igb_read_clock;
> -               adapter->cycles.mask = CLOCKSOURCE_MASK(64);
> -               adapter->cycles.mult = 1;
> -               /*
> -                * The 82580 timesync updates the system timer every 8ns by 8ns
> -                * and the value cannot be shifted.  Instead we need to shift
> -                * the registers to generate a 64bit timer value.  As a result
> -                * SYSTIMR/L/H, TXSTMPL/H, RXSTMPL/H all have to be shifted by
> -                * 24 in order to generate a larger value for synchronization.
> -                */
> -               adapter->cycles.shift = IGB_82580_TSYNC_SHIFT;
> -               /* disable system timer temporarily by setting bit 31 */
> -               wr32(E1000_TSAUXC, 0x80000000);
> -               wrfl();
> -
> -               /* Set registers so that rollover occurs soon to test this. */
> -               wr32(E1000_SYSTIMR, 0x00000000);
> -               wr32(E1000_SYSTIML, 0x80000000);
> -               wr32(E1000_SYSTIMH, 0x000000FF);
> -               wrfl();
> -
> -               /* enable system timer by clearing bit 31 */
> -               wr32(E1000_TSAUXC, 0x0);
> -               wrfl();
> -
> -               timecounter_init(&adapter->clock,
> -                                &adapter->cycles,
> -                                ktime_to_ns(ktime_get_real()));
> -               /*
> -                * Synchronize our NIC clock against system wall clock. NIC
> -                * time stamp reading requires ~3us per sample, each sample
> -                * was pretty stable even under load => only require 10
> -                * samples for each offset comparison.
> -                */
> -               memset(&adapter->compare, 0, sizeof(adapter->compare));
> -               adapter->compare.source = &adapter->clock;
> -               adapter->compare.target = ktime_get_real;
> -               adapter->compare.num_samples = 10;
> -               timecompare_update(&adapter->compare, 0);
> -               break;
> -       case e1000_82576:
> -               /*
> -                * Initialize hardware timer: we keep it running just in case
> -                * that some program needs it later on.
> -                */
> -               memset(&adapter->cycles, 0, sizeof(adapter->cycles));
> -               adapter->cycles.read = igb_read_clock;
> -               adapter->cycles.mask = CLOCKSOURCE_MASK(64);
> -               adapter->cycles.mult = 1;
> -               /**
> -                * Scale the NIC clock cycle by a large factor so that
> -                * relatively small clock corrections can be added or
> -                * subtracted at each clock tick. The drawbacks of a large
> -                * factor are a) that the clock register overflows more quickly
> -                * (not such a big deal) and b) that the increment per tick has
> -                * to fit into 24 bits.  As a result we need to use a shift of
> -                * 19 so we can fit a value of 16 into the TIMINCA register.
> -                */
> -               adapter->cycles.shift = IGB_82576_TSYNC_SHIFT;
> -               wr32(E1000_TIMINCA,
> -                               (1 << E1000_TIMINCA_16NS_SHIFT) |
> -                               (16 << IGB_82576_TSYNC_SHIFT));
> -
> -               /* Set registers so that rollover occurs soon to test this. */
> -               wr32(E1000_SYSTIML, 0x00000000);
> -               wr32(E1000_SYSTIMH, 0xFF800000);
> -               wrfl();
> -
> -               timecounter_init(&adapter->clock,
> -                                &adapter->cycles,
> -                                ktime_to_ns(ktime_get_real()));
> -               /*
> -                * Synchronize our NIC clock against system wall clock. NIC
> -                * time stamp reading requires ~3us per sample, each sample
> -                * was pretty stable even under load => only require 10
> -                * samples for each offset comparison.
> -                */
> -               memset(&adapter->compare, 0, sizeof(adapter->compare));
> -               adapter->compare.source = &adapter->clock;
> -               adapter->compare.target = ktime_get_real;
> -               adapter->compare.num_samples = 10;
> -               timecompare_update(&adapter->compare, 0);
> -               break;
> -       case e1000_82575:
> -               /* 82575 does not support timesync */
> -       default:
> -               break;
> -       }
> -
> -}
> -
> -/**
>   * igb_sw_init - Initialize general software structures (struct igb_adapter)
>   * @adapter: board private structure to initialize
>   *
> @@ -5628,35 +5496,6 @@ static int igb_poll(struct napi_struct *napi, int budget)
>  }
> 
>  /**
> - * igb_systim_to_hwtstamp - convert system time value to hw timestamp
> - * @adapter: board private structure
> - * @shhwtstamps: timestamp structure to update
> - * @regval: unsigned 64bit system time value.
> - *
> - * We need to convert the system time value stored in the RX/TXSTMP registers
> - * into a hwtstamp which can be used by the upper level timestamping functions
> - */
> -static void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
> -                                   struct skb_shared_hwtstamps *shhwtstamps,
> -                                   u64 regval)
> -{
> -       u64 ns;
> -
> -       /*
> -        * The 82580 starts with 1ns at bit 0 in RX/TXSTMPL, shift this up to
> -        * 24 to match clock shift we setup earlier.
> -        */
> -       if (adapter->hw.mac.type >= e1000_82580)
> -               regval <<= IGB_82580_TSYNC_SHIFT;
> -
> -       ns = timecounter_cyc2time(&adapter->clock, regval);
> -       timecompare_update(&adapter->compare, ns);
> -       memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
> -       shhwtstamps->hwtstamp = ns_to_ktime(ns);
> -       shhwtstamps->syststamp = timecompare_transform(&adapter->compare, ns);
> -}
> -
> -/**
>   * igb_tx_hwtstamp - utility function which checks for TX time stamp
>   * @q_vector: pointer to q_vector containing needed info
>   * @buffer: pointer to igb_tx_buffer structure
> diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
> index 7a9f6bc..7a62980 100644
> --- a/drivers/net/ethernet/intel/igb/igb_ptp.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
> @@ -406,3 +406,45 @@ void igb_ptp_remove(struct igb_adapter *adapter)
>                          adapter->netdev->name);
>         }
>  }
> +
> +/**
> + * igb_systim_to_hwtstamp - convert system time value to hw timestamp
> + * @adapter: board private structure
> + * @shhwtstamps: timestamp structure to update

cut and paste typo? should match the arguments below.

> + * @systim: unsigned 64bit system time value.
> + *
> + * We need to convert the system time value stored in the RX/TXSTMP registers
> + * into a hwtstamp which can be used by the upper level timestamping functions
> + */
> +void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
> +                           struct skb_shared_hwtstamps *hwtstamps,
> +                           u64 systim)
> +{
> +       u64 ns;
> +       unsigned long flags;
> +       unsigned int shift;
> +       int msb_set;
> +
> +       switch (adapter->hw.mac.type) {
> +       case e1000_i350:
> +       case e1000_82580:
> +               shift = OFL_SHIFT_82580;
> +               msb_set = (systim >> 32) & SYSTIMH_MSB_82580;
> +               break;
> +       case e1000_82576:
> +               shift = OFL_SHIFT_82576;
> +               msb_set = (systim >> 32) & SYSTIMH_MSB_82576;
> +               break;
> +       default:
> +               return;
> +       }
> +
> +       spin_lock_irqsave(&adapter->tmreg_lock, flags);

based on the discussion on the list with eric dumazet it should have a
comment here why the spinlock is needed and about how it is expected to
impact performance.
 
> +
> +       ns = igb_overflow_get(adapter, systim, msb_set, shift);
> +
> +       spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
> +
> +       memset(hwtstamps, 0, sizeof(*hwtstamps));
> +       hwtstamps->hwtstamp = ns_to_ktime(ns);
> +}
