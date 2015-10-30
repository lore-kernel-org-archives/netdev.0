From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 2/4] e1000e: Do not read icr in Other interrupt
Date: Fri, 30 Oct 2015 12:19:00 -0700
Message-ID: <5633C2A4.90002@gmail.com>
References: <1446226264-29660-1-git-send-email-bpoirier@suse.com>
 <1446226264-29660-3-git-send-email-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Frank Steiner <steiner-reg@bio.ifi.lmu.de>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446226264-29660-3-git-send-email-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/2015 10:31 AM, Benjamin Poirier wrote:
> Using eiac instead of reading icr allows us to avoid interference with
> rx and tx interrupts in the Other interrupt handler.
>
> According to the 82574 datasheet section 10.2.4.1, interrupt causes that
> trigger the Other interrupt are
> 1) Link Status Change.
> 2) Receiver Overrun.
> 3) MDIO Access Complete.
> 4) Small Receive Packet Detected.
> 5) Receive ACK Frame Detected.
> 6) Manageability Event Detected.
>
> Causes 3, 4, 5 are related to features which are not enabled by the
> driver. Always assume that cause 1 is what triggered the Other interrupt
> and set get_link_status. Cause 2 and 6 should be rare enough that the
> extra cost of needlessly re-reading the link status is negligible.
>
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

You might want to instead use a write of LSC to the ICR instead of just 
using auto-clear and not enabling LSC.  My concern is that you might no 
longer be getting link status change events at all.  An easy test is to 
just unplug/plug the cable a few times, or run "ethtool -r" on the link 
partner if connected back to back.  You should see messages appear in 
the dmesg log indicating that the link state changed.

In addition you should probably clear the IAME bit in the CTRL_EXT 
register so that you don't risk masking the interrupts on the ICR read 
or write.

> ---
>   drivers/net/ethernet/intel/e1000e/netdev.c | 23 ++++++++---------------
>   1 file changed, 8 insertions(+), 15 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index a228167..602fcc9 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -1905,24 +1905,16 @@ static irqreturn_t e1000_msix_other(int __always_unused irq, void *data)
>   	struct net_device *netdev = data;
>   	struct e1000_adapter *adapter = netdev_priv(netdev);
>   	struct e1000_hw *hw = &adapter->hw;
> -	u32 icr = er32(ICR);
>
> -	if (icr & adapter->eiac_mask)
> -		ew32(ICS, (icr & adapter->eiac_mask));
> +	/* Assume that the Other interrupt was triggered by LSC */
> +	hw->mac.get_link_status = true;
>
> -	if (icr & E1000_ICR_OTHER) {
> -		if (!(icr & E1000_ICR_LSC))
> -			goto no_link_interrupt;
> -		hw->mac.get_link_status = true;
> -		/* guard against interrupt when we're going down */
> -		if (!test_bit(__E1000_DOWN, &adapter->state))
> -			mod_timer(&adapter->watchdog_timer, jiffies + 1);

You could probably just pop a write to the ICR register here to clear 
the LSC bit since you are auto clearing the OTHER bit.

> +	/* guard against interrupt when we're going down */
> +	if (!test_bit(__E1000_DOWN, &adapter->state)) {
> +		mod_timer(&adapter->watchdog_timer, jiffies + 1);
> +		ew32(IMS, E1000_IMS_OTHER);
>   	}
>
> -no_link_interrupt:
> -	if (!test_bit(__E1000_DOWN, &adapter->state))
> -		ew32(IMS, E1000_IMS_LSC | E1000_IMS_OTHER);
> -
>   	return IRQ_HANDLED;
>   }
>
> @@ -2019,6 +2011,7 @@ static void e1000_configure_msix(struct e1000_adapter *adapter)
>   		       hw->hw_addr + E1000_EITR_82574(vector));
>   	else
>   		writel(1, hw->hw_addr + E1000_EITR_82574(vector));
> +	adapter->eiac_mask |= E1000_IMS_OTHER;
>
>   	/* Cause Tx interrupts on every write back */
>   	ivar |= (1 << 31);
> @@ -2247,7 +2240,7 @@ static void e1000_irq_enable(struct e1000_adapter *adapter)
>
>   	if (adapter->msix_entries) {
>   		ew32(EIAC_82574, adapter->eiac_mask & E1000_EIAC_MASK_82574);
> -		ew32(IMS, adapter->eiac_mask | E1000_IMS_OTHER | E1000_IMS_LSC);
> +		ew32(IMS, adapter->eiac_mask);

You might want to consider adding a write to IAM here that would limit 
the auto masking to same bits you are auto clearing.

I would probably leave E1000_IMS_LSC set in the IMS.  No need to 
auto-mask it since the mask for other will keep it from triggering more 
than once.

>   	} else if ((hw->mac.type == e1000_pch_lpt) ||
>   		   (hw->mac.type == e1000_pch_spt)) {
>   		ew32(IMS, IMS_ENABLE_MASK | E1000_IMS_ECCER);
>
