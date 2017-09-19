From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: [5/5] e1000e: Avoid receiver overrun interrupt bursts
Date: Tue, 19 Sep 2017 12:38:02 -0600
Message-ID: <DDD41C67-CDF2-4443-9F49-0DC5489D9243@redfish-solutions.com>
References: <20170721183627.13373-5-bpoirier@suse.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        linux-kernel@vger.kernel.org,
        Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
        Benjamin Poirier <bpoirier@suse.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721183627.13373-5-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

We’ve been running this patchset (all 5) for about as long as they’ve been under review… about 2 months.  And in a burn-in lab with heavy traffic.

We’ve not seen a single link-flap in hundreds of ours of saturated traffic.

Would love to see some resolution soon on this as we don’t want to ship a release with unsanctioned patches.

Is there an estimate on when that might be?

Thanks,

-Philip



> On Jul 21, 2017, at 12:36 PM, Benjamin Poirier <bpoirier@suse.com> wrote:
> 
> When e1000e_poll() is not fast enough to keep up with incoming traffic, the
> adapter (when operating in msix mode) raises the Other interrupt to signal
> Receiver Overrun.
> 
> This is a double problem because 1) at the moment e1000_msix_other()
> assumes that it is only called in case of Link Status Change and 2) if the
> condition persists, the interrupt is repeatedly raised again in quick
> succession.
> 
> Ideally we would configure the Other interrupt to not be raised in case of
> receiver overrun but this doesn't seem possible on this adapter. Instead,
> we handle the first part of the problem by reverting to the practice of
> reading ICR in the other interrupt handler, like before commit 16ecba59bc33
> ("e1000e: Do not read ICR in Other interrupt"). Thanks to commit
> 0a8047ac68e5 ("e1000e: Fix msi-x interrupt automask") which cleared IAME
> from CTRL_EXT, reading ICR doesn't interfere with RxQ0, TxQ0 interrupts
> anymore. We handle the second part of the problem by not re-enabling the
> Other interrupt right away when there is overrun. Instead, we wait until
> traffic subsides, napi polling mode is exited and interrupts are
> re-enabled.
> 
> Reported-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
> Fixes: 16ecba59bc33 ("e1000e: Do not read ICR in Other interrupt")
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> ---
> drivers/net/ethernet/intel/e1000e/defines.h |  1 +
> drivers/net/ethernet/intel/e1000e/netdev.c  | 33 +++++++++++++++++++++++------
> 2 files changed, 27 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
> index 0641c0098738..afb7ebe20b24 100644
> --- a/drivers/net/ethernet/intel/e1000e/defines.h
> +++ b/drivers/net/ethernet/intel/e1000e/defines.h
> @@ -398,6 +398,7 @@
> #define E1000_ICR_LSC           0x00000004 /* Link Status Change */
> #define E1000_ICR_RXSEQ         0x00000008 /* Rx sequence error */
> #define E1000_ICR_RXDMT0        0x00000010 /* Rx desc min. threshold (0) */
> +#define E1000_ICR_RXO           0x00000040 /* Receiver Overrun */
> #define E1000_ICR_RXT0          0x00000080 /* Rx timer intr (ring 0) */
> #define E1000_ICR_ECCER         0x00400000 /* Uncorrectable ECC Error */
> /* If this bit asserted, the driver should claim the interrupt */
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 5a8ab1136566..803edd1a6401 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -1910,12 +1910,30 @@ static irqreturn_t e1000_msix_other(int __always_unused irq, void *data)
> 	struct net_device *netdev = data;
> 	struct e1000_adapter *adapter = netdev_priv(netdev);
> 	struct e1000_hw *hw = &adapter->hw;
> +	u32 icr;
> +	bool enable = true;
> +
> +	icr = er32(ICR);
> +	if (icr & E1000_ICR_RXO) {
> +		ew32(ICR, E1000_ICR_RXO);
> +		enable = false;
> +		/* napi poll will re-enable Other, make sure it runs */
> +		if (napi_schedule_prep(&adapter->napi)) {
> +			adapter->total_rx_bytes = 0;
> +			adapter->total_rx_packets = 0;
> +			__napi_schedule(&adapter->napi);
> +		}
> +	}
> +	if (icr & E1000_ICR_LSC) {
> +		ew32(ICR, E1000_ICR_LSC);
> +		hw->mac.get_link_status = true;
> +		/* guard against interrupt when we're going down */
> +		if (!test_bit(__E1000_DOWN, &adapter->state)) {
> +			mod_timer(&adapter->watchdog_timer, jiffies + 1);
> +		}
> +	}
> 
> -	hw->mac.get_link_status = true;
> -
> -	/* guard against interrupt when we're going down */
> -	if (!test_bit(__E1000_DOWN, &adapter->state)) {
> -		mod_timer(&adapter->watchdog_timer, jiffies + 1);
> +	if (enable && !test_bit(__E1000_DOWN, &adapter->state)) {
> 		ew32(IMS, E1000_IMS_OTHER);
> 	}
> 
> @@ -2687,7 +2705,8 @@ static int e1000e_poll(struct napi_struct *napi, int weight)
> 		napi_complete_done(napi, work_done);
> 		if (!test_bit(__E1000_DOWN, &adapter->state)) {
> 			if (adapter->msix_entries)
> -				ew32(IMS, adapter->rx_ring->ims_val);
> +				ew32(IMS, adapter->rx_ring->ims_val |
> +				     E1000_IMS_OTHER);
> 			else
> 				e1000_irq_enable(adapter);
> 		}
> @@ -4204,7 +4223,7 @@ static void e1000e_trigger_lsc(struct e1000_adapter *adapter)
> 	struct e1000_hw *hw = &adapter->hw;
> 
> 	if (adapter->msix_entries)
> -		ew32(ICS, E1000_ICS_OTHER);
> +		ew32(ICS, E1000_ICS_LSC | E1000_ICS_OTHER);
> 	else
> 		ew32(ICS, E1000_ICS_LSC);
> }
