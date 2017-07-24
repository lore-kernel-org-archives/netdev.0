From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: commit 16ecba59 breaks 82574L under heavy load.
Date: Mon, 24 Jul 2017 15:56:01 -0600
Message-ID: <F714AA72-C760-4AB3-8D7B-D8261BE216AF@redfish-solutions.com>
References: <20170718142109.GO18556@csclub.uwaterloo.ca>
 <20170718231435.64us7vu67wtp6pwe@f1.synalogic.ca>
 <20170719141953.GQ18556@csclub.uwaterloo.ca>
 <20170720000747.4jiadqubv7hg5esz@f1.synalogic.ca>
 <20170720140027.GR18556@csclub.uwaterloo.ca>
 <20170720234455.7nxtui7shmnzivxd@f1.synalogic.ca>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170720234455.7nxtui7shmnzivxd@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Jul 20, 2017, at 5:44 PM, Benjamin Poirier <bpoirier@suse.com> wrote:
> 
> [snip]
> Could you please test the following patch and let me know if it:
> 1) reduces the interrupt rate of the Other msi-x vector
> 2) avoids the link flaps
> or
> 3) logs some dmesg warnings of the form "Other interrupt with unhandled [...]"
> In this case, please paste icr values printed.
> 
> Thanks
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
> diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
> index c7c994eb410e..f7b46eba3efb 100644
> --- a/drivers/net/ethernet/intel/e1000e/e1000.h
> +++ b/drivers/net/ethernet/intel/e1000e/e1000.h
> @@ -351,6 +351,10 @@ struct e1000_adapter {
> 	s32 ptp_delta;
> 
> 	u16 eee_advert;
> +
> +	unsigned int uh_count;
> +	u32 uh_values[16];
> +	unsigned int uh_values_nb;
> };
> 
> struct e1000_info {
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index b3679728caac..46697338c0e1 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -46,6 +46,8 @@
> 
> #include "e1000.h"
> 
> +DEFINE_RATELIMIT_STATE(other_uh_ratelimit_state, HZ, 1);
> +
> #define DRV_EXTRAVERSION "-k"
> 
> #define DRV_VERSION "3.2.6" DRV_EXTRAVERSION
> @@ -1904,12 +1906,60 @@ static irqreturn_t e1000_msix_other(int __always_unused irq, void *data)
> 	struct net_device *netdev = data;
> 	struct e1000_adapter *adapter = netdev_priv(netdev);
> 	struct e1000_hw *hw = &adapter->hw;
> +	u32 icr;
> +	bool enable = true;
> +	bool handled = false;
> +	unsigned int i;
> 
> -	hw->mac.get_link_status = true;
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
> +		handled = true;
> +	}
> +	if (icr & E1000_ICR_LSC) {
> +		ew32(ICR, E1000_ICR_LSC);
> +		hw->mac.get_link_status = true;
> +		/* guard against interrupt when we're going down */
> +		if (!test_bit(__E1000_DOWN, &adapter->state)) {
> +			mod_timer(&adapter->watchdog_timer, jiffies + 1);
> +		}
> +		handled = true;
> +	}
> 
> -	/* guard against interrupt when we're going down */
> -	if (!test_bit(__E1000_DOWN, &adapter->state)) {
> -		mod_timer(&adapter->watchdog_timer, jiffies + 1);
> +	if (!handled) {
> +		adapter->uh_count++;
> +		/* only print unseen icr values */
> +		if (adapter->uh_values_nb < ARRAY_SIZE(adapter->uh_values)) {
> +			for (i = 0; i < ARRAY_SIZE(adapter->uh_values); i++) {
> +				if (adapter->uh_values[i] == icr) {
> +					break;
> +				}
> +			}
> +			if (i == ARRAY_SIZE(adapter->uh_values)) {
> +				adapter->uh_values[adapter->uh_values_nb] =
> +					icr;
> +				adapter->uh_values_nb++;
> +				netdev_warn(netdev,
> +					    "Other interrupt with unhandled icr 0x%08x\n",
> +					    icr);
> +			}
> +		}
> +	}
> +	if (adapter->uh_count && __ratelimit(&other_uh_ratelimit_state)) {
> +		netdev_warn(netdev,
> +			    "Other interrupt with unhandled cause, count %u\n",
> +			    adapter->uh_count);
> +		adapter->uh_count = 0;
> +	}
> +
> +	if (enable && !test_bit(__E1000_DOWN, &adapter->state)) {
> 		ew32(IMS, E1000_IMS_OTHER);
> 	}
> 
> @@ -2681,7 +2731,8 @@ static int e1000e_poll(struct napi_struct *napi, int weight)
> 		napi_complete_done(napi, work_done);
> 		if (!test_bit(__E1000_DOWN, &adapter->state)) {
> 			if (adapter->msix_entries)
> -				ew32(IMS, adapter->rx_ring->ims_val);
> +				ew32(IMS, adapter->rx_ring->ims_val |
> +				     E1000_IMS_OTHER);
> 			else
> 				e1000_irq_enable(adapter);
> 		}
> @@ -4197,7 +4248,7 @@ static void e1000e_trigger_lsc(struct e1000_adapter *adapter)
> 	struct e1000_hw *hw = &adapter->hw;
> 
> 	if (adapter->msix_entries)
> -		ew32(ICS, E1000_ICS_OTHER);
> +		ew32(ICS, E1000_ICS_LSC | E1000_ICS_OTHER);
> 	else
> 		ew32(ICS, E1000_ICS_LSC);
> }
> @@ -7572,6 +7623,8 @@ static int __init e1000_init_module(void)
> 		e1000e_driver_version);
> 	pr_info("Copyright(c) 1999 - 2015 Intel Corporation.\n");
> 
> +	ratelimit_set_flags(&other_uh_ratelimit_state, RATELIMIT_MSG_ON_RELEASE);
> +
> 	return pci_register_driver(&e1000_driver);
> }
> module_init(e1000_init_module);



We’ve been running this patch on a Lanner FW-7568 (Atom D525, 6x 82574L NICs) under heavy load both with and without RPS enabled and have yet to see a single link flap.

Is it going into linux-stable?

Thanks,

-Philip
