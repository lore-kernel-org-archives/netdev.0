From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 1/8] i40e: main driver core
Date: Wed, 19 Jun 2013 19:12:42 +0100
Message-ID: <1371665562.1956.89.camel@bwh-desktop.uk.level5networks.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1371182122-26629-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>, "Shannon Nelson" <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	<e1000-devel@lists.sourceforge.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58255 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934659Ab3FSSMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 14:12:47 -0400
In-Reply-To: <1371182122-26629-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-13 at 20:55 -0700, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> This is the driver for the Intel(R) Ethernet Controller XL710 Family.
> 
> This driver is targeted at basic ethernet functionality only, and will be
> improved upon further as time goes on.
> 
> This patch mail contains the driver entry points but does not include transmit
> and receive (see next patch) routines.

Aside from the poor style of using your own private error names *even in
netdev operations*, you're also not using consistent types for them
(int, s32 or u32?).

[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
[...]
> +#define I40E_MAX_NIC 32

This doesn't appear to be used (thankfully).

[...]
> +void i40e_tx_timeout(struct net_device *netdev)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_vsi *vsi = np->vsi;
> +	struct i40e_pf *pf = vsi->back;
> +
> +	pf->tx_timeout_count++;
> +#ifdef CONFIG_DEBUG_FS
> +	if (vsi->block_tx_timeout) {
> +		netdev_info(netdev, "%s: recovery disabled\n", __func__);
> +		return;
> +	}
> +#endif

Looks like a development hack.

> +	if (time_after(jiffies, (pf->tx_timeout_last_recovery + HZ*20)))
> +		pf->tx_timeout_recovery_level = 0;
> +	pf->tx_timeout_last_recovery = jiffies;
> +	vsi->netdev->trans_start = jiffies;

Direct assignment of net_device::trans_start is deprecated, and
definitely wrong for a multiqueue driver.

[...]
> +/**
> + * i40e_get_vsi_stats_struct - Get System Network Statistics
> + * @vsi: the VSI we care about
> + *
> + * Returns the address of the device statistics structure.
> + * The statistics are actually updated from the service task.
> + **/
> +struct net_device_stats *i40e_get_vsi_stats_struct(struct i40e_vsi *vsi)
> +{
> +	/* only return the current stats */
> +	/* It is possible for a VSIs to not have a netdev */
> +	if (vsi->netdev)
> +		return &vsi->netdev->stats;
> +	else
> +		return &vsi->net_stats;
> +}

You should be using rtnl_device_stats64; at 40G a 32-bit counter is
ridiculous (using this in a 32-bit machine is a bit ridiculous too,
though...)

[...]
> +/**
> + * i40e_vlan_rx_register - Setup or shutdown vlan offload
> + * @netdev: network interface to be adjusted
> + * @features: netdev features to test if VLAN offload is enabled or not
> + **/
> +static void i40e_vlan_rx_register(struct net_device *netdev, u32 features)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_vsi *vsi = np->vsi;
> +	bool enable;
> +	enable = !!(features & NETIF_F_HW_VLAN_CTAG_RX);
> +
> +	if (enable)

It's a simple expression; why bother with a variable for it?

> +		i40e_vlan_stripping_enable(vsi);
> +	else
> +		i40e_vlan_stripping_disable(vsi);
> +}
[...]
> +/**
> + * i40e_napi_disable_all - Disable NAPI for all q_vectors in the VSI
> + * @vsi: the VSI being configured
> + **/
> +static void i40e_napi_disable_all(struct i40e_vsi *vsi)
> +{
> +	int q_idx;
> +
> +	if (!vsi->netdev)
> +		return;
> +
> +	for (q_idx = 0; q_idx < vsi->num_q_vectors; q_idx++) {
> +		napi_synchronize(&vsi->q_vectors[q_idx].napi);

This will wait indefinitely if there is enough traffic to keep NAPI
scheduled.  (Arguably this is a bug in napi_synchronize() and it should
actually use some sort of generation count.)  It's completely pointless
when you're about to call:

> +		napi_disable(&vsi->q_vectors[q_idx].napi);

which will actually tell the NAPI soft IRQ to stop.

> +	}
> +}
[...]
> +/**
> + * i40e_vsi_reinit_locked - Reset the VSI
> + * @vsi: the VSI being configured
> + *
> + * Rebuild the ring structs after some configuration
> + * has changed, e.g. MTU size.
> + **/
> +static void i40e_vsi_reinit_locked(struct i40e_vsi *vsi)
> +{
> +	struct i40e_pf *pf = vsi->back;
> +
> +	WARN_ON(in_interrupt());
> +	/* put off any impending NetWatchDogTimeout */
> +	if (vsi->netdev)
> +		vsi->netdev->trans_start = jiffies;

Leave trans_start alone.

[...]
> +/**
> + * i40e_down - Shutdown the connection processing
> + * @vsi: the VSI being stopped
> + **/
> +void i40e_down(struct i40e_vsi *vsi)
> +{
> +	int i;
> +
> +	/* It is assumed that the caller of this function
> +	 * sets the vsi->state __I40E_DOWN bit.
> +	 */
> +	if (vsi->netdev) {
> +		netif_tx_stop_all_queues(vsi->netdev);
> +		netif_carrier_off(vsi->netdev);
> +		netif_tx_disable(vsi->netdev);

This seems very confused.  Do you want to stop TX synchronously or
asynchronously?

[...]
> +/**
> + * i40e_check_hang_subtask - Check for hung queues and dropped interrupts
> + * @pf: board private structure
> + *
> + * Set the per-queue flags to request a check for stuck queues in the irq
> + * clean functions, then force interrupts to be sure the irq clean is called.
> + **/
> +static void i40e_check_hang_subtask(struct i40e_pf *pf)
> +{
[...]

We already have a TX watchdog.

[...]
> +/**
> + * i40e_config_rss - Prepare for RSS if used
> + * @pf: board private structure
> + **/
> +static s32 i40e_config_rss(struct i40e_pf *pf)
> +{
> +	struct i40e_hw *hw = &pf->hw;
> +	u32 lut = 0;
> +	int i, j;
> +	u64 hena;
> +	/* Set of random keys generated using kernel random number generator */
> +	static const u32 seed[I40E_PFQF_HKEY_MAX_INDEX + 1] = {0x41b01687,
> +				0x183cfd8c, 0xce880440, 0x580cbc3c, 0x35897377,
> +				0x328b25e1, 0x4fa98922, 0xb7d90c14, 0xd5bad70d,
> +				0xcd15a2c1, 0xe8580225, 0x4a1e9d11, 0xfe5731be};

Chosen by a fair dice roll?

[...]
> +/**
> + * i40e_assign_netdev_ops - Initialize netdev operations function pointers
> + * @dev: ptr to the netdev struct
> + **/
> +static void i40e_assign_netdev_ops(struct net_device *dev)
> +{
> +	dev->netdev_ops = &i40e_netdev_ops;
> +	dev->watchdog_timeo = 5 * HZ;
> +}

Sure you need a function for that?

[...]
> +static s32 i40e_config_netdev(struct i40e_vsi *vsi)
> +{
[...]
> +	if (pf->pci_using_dac)
> +		netdev->features |= NETIF_F_HIGHDMA;
[...]

HIGHDMA just means you don't assume TX page fragments are in lowmem.  It
actually has nothing to do with DMA capabilities, which are checked
separately.  Besides which DAC isn't exactly relevant to PCI Express
devices... so this looks like cargo-culting from e1000 from the days
before e1000e was split off.

I didn't read any further yet.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
