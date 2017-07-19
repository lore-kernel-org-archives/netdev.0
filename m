From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: commit 16ecba59 breaks 82574L under heavy load.
Date: Wed, 19 Jul 2017 10:19:53 -0400
Message-ID: <20170719141953.GQ18556@csclub.uwaterloo.ca>
References: <20170718142109.GO18556@csclub.uwaterloo.ca>
 <20170718231435.64us7vu67wtp6pwe@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170718231435.64us7vu67wtp6pwe@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2017 at 04:14:35PM -0700, Benjamin Poirier wrote:
> Thanks for the detailed analysis.
> 
> Refering to the original discussion around this patch series, it seemed like
> the IMS bit for a condition had to be set for the Other interrupt to be raised
> for that condition.
> 
> https://lkml.org/lkml/2015/11/4/683
> 
> In this case however, E1000_ICR_RXT0 is not set in IMS so Other shouldn't be
> raised for Receiver Overrun. Apparently something is going on...
> 
> I can reproduce the spurious Other interrupts with a simple mdelay()
> With the debugging patch at the end of the mail I see stuff like this
> while blasting with udp frames:
>           <idle>-0     [086] d.h1 15338.742675: e1000_msix_other: got Other interrupt, count 15127
>            <...>-54504 [086] d.h. 15338.742724: e1000_msix_other: got Other interrupt, count 1
>            <...>-54504 [086] d.h. 15338.742774: e1000_msix_other: got Other interrupt, count 1
>            <...>-54504 [086] d.h. 15338.742824: e1000_msix_other: got Other interrupt, count 1
>           <idle>-0     [086] d.h1 15340.745123: e1000_msix_other: got Other interrupt, count 27584
>            <...>-54504 [086] d.h. 15340.745172: e1000_msix_other: got Other interrupt, count 1
>            <...>-54504 [086] d.h. 15340.745222: e1000_msix_other: got Other interrupt, count 1
>            <...>-54504 [086] d.h. 15340.745272: e1000_msix_other: got Other interrupt, count 1
> 
> > hence sets the flag that (unfortunately) means both link is down and link
> > state should be checked.  Since this now happens 3000 times per second,
> > the chances of it happening while the watchdog_task is checking the link
> > state becomes pretty high, and it if does happen to coincice, then the
> > watchdog_task will reset the adapter, which causes a real loss of link.
> 
> Through which path does watchdog_task reset the adapter? I didn't
> reproduce that.

The other interrupt happens and sets get_link_status to true.  At some
point the watchdog_task runs on some core and calls e1000e_has_link,
which then calls check_for_link to find out the current link status.
While e1000e_check_for_copper_link is checking the link state and
after updating get_link_status to false to indicate link is up, another
interrupt occurs and another core handles it and changes get_link_status
to true again.  So by the time e1000e_has_link goes to determine the
return value, get_link_state has changed back again so now it returns
link down, and as a result the watchdog_task calls reset, because we
have packets in the transmit queue (we were busy forwarding over 100000
packets per second when it happened).

Running on an Atom D525 which isn't very fast and uses hyperthreading
might have something to do with how the scheduling manages to trigger
this race condition.  On a faster CPU you very likely would be done
checking the link state quickly enough that the interrupt handler rarely
gets a chance to interfere.  Also we have the irq affinity set so the
RX/TX of one port is handled by one CPU, the RX/TX of the other port
by a different CPU and the Other interrupts and other tasks (like the
watchdog) are handled by the last two CPUs.

Either making the current link state its own bool and keeping it's meaning
away from get_link_state, or making the interrupt handler only change
get_link_state when LSC is actually present makes the problem go away.
Having two meanings to get_link_state (both link state needs checking
and what the link state is) causes issues.  After all it is using a bool
to store 3 values: Link is up, link needs checking but is up and link
needs checking but is down.  Of course the last two states are rather
quantum, in that you don't know which it is until you check.

> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index b3679728caac..689ad76d0d12 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -46,6 +46,8 @@
>  
>  #include "e1000.h"
>  
> +DEFINE_RATELIMIT_STATE(e1000e_ratelimit_state, 2 * HZ, 4);
> +
>  #define DRV_EXTRAVERSION "-k"
>  
>  #define DRV_VERSION "3.2.6" DRV_EXTRAVERSION
> @@ -937,6 +939,8 @@ static bool e1000_clean_rx_irq(struct e1000_ring *rx_ring, int *work_done,
>  	bool cleaned = false;
>  	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
>  
> +	mdelay(10);
> +
>  	i = rx_ring->next_to_clean;
>  	rx_desc = E1000_RX_DESC_EXT(*rx_ring, i);
>  	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
> @@ -1067,6 +1071,13 @@ static bool e1000_clean_rx_irq(struct e1000_ring *rx_ring, int *work_done,
>  
>  	adapter->total_rx_bytes += total_rx_bytes;
>  	adapter->total_rx_packets += total_rx_packets;
> +
> +	if (__ratelimit(&e1000e_ratelimit_state)) {
> +		static unsigned int max;
> +		max = max(max, total_rx_packets);
> +		trace_printk("received %u max %u\n", total_rx_packets, max);
> +	}
> +
>  	return cleaned;
>  }
>  
> @@ -1904,9 +1915,16 @@ static irqreturn_t e1000_msix_other(int __always_unused irq, void *data)
>  	struct net_device *netdev = data;
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
>  	struct e1000_hw *hw = &adapter->hw;
> +	static unsigned int count;
>  
>  	hw->mac.get_link_status = true;
>  
> +	count++;
> +	if (__ratelimit(&e1000e_ratelimit_state)) {
> +		trace_printk("got Other interrupt, count %u\n", count);
> +		count = 0;
> +	}
> +
>  	/* guard against interrupt when we're going down */
>  	if (!test_bit(__E1000_DOWN, &adapter->state)) {
>  		mod_timer(&adapter->watchdog_timer, jiffies + 1);
> @@ -7121,7 +7139,7 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	netdev->netdev_ops = &e1000e_netdev_ops;
>  	e1000e_set_ethtool_ops(netdev);
>  	netdev->watchdog_timeo = 5 * HZ;
> -	netif_napi_add(netdev, &adapter->napi, e1000e_poll, 64);
> +	netif_napi_add(netdev, &adapter->napi, e1000e_poll, 500);
>  	strlcpy(netdev->name, pci_name(pdev), sizeof(netdev->name));
>  
>  	netdev->mem_start = mmio_start;
> @@ -7327,6 +7345,8 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	if (err)
>  		goto err_register;
>  
> +	ratelimit_set_flags(&e1000e_ratelimit_state, RATELIMIT_MSG_ON_RELEASE);
> +
>  	/* carrier off reporting is important to ethtool even BEFORE open */
>  	netif_carrier_off(netdev);

-- 
Len Sorensen
