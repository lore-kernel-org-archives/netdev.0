From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 1/8] i40e: main driver core
Date: Thu, 13 Jun 2013 22:29:22 -0700
Message-ID: <1371187762.31941.42.camel@joe-AO722>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1371182122-26629-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54408 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750857Ab3FNF3X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jun 2013 01:29:23 -0400
In-Reply-To: <1371182122-26629-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-13 at 20:55 -0700, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> This is the driver for the Intel(R) Ethernet Controller XL710 Family.

This code looks very generic and not tailored to linux.
Are you intending to fix it to be more linux-kernel like?

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
[]
> +enum i40e_status_code i40e_allocate_dma_mem_d(struct i40e_hw *hw,

i40e_status?  int is more common.

> +	if (mem->va)
> +		return I40E_SUCCESS;
> +	else
> +		return I40E_ERR_NO_MEMORY;

	if (!mem->va)
		return -ENOMEM;

	return 0;

but returning the pointer or NULL is much more normal.

> +enum i40e_status_code i40e_allocate_virt_mem_d(struct i40e_hw *hw,
> +					       struct i40e_virt_mem *mem,
> +					       u32 size)
[]
> 	if (mem->va)
> +		return I40E_SUCCESS;
> +	else
> +		return I40E_ERR_NO_MEMORY;
> +}

same as above.

> +/**
> + * i40e_debug_d - OS dependent version of debug printing
> + * @hw:  pointer to the HW structure
> + * @mask: debug level mask
> + * @fmt_str: printf-type format description
> + **/
> +void i40e_debug_d(void *hw, u32 mask, char *fmt_str, ...)
> +{
> +	char *buf;
> +	int buf_len = 512;
> +	va_list argptr;
> +	struct i40e_pf *pf = (struct i40e_pf *)(((struct i40e_hw *)hw)->back);
> +
> +	if (!(mask & ((struct i40e_hw *)hw)->debug_mask))
> +		return;
> +
> +	buf = kzalloc(buf_len, GFP_KERNEL);
> +
> +	if (!buf) {
> +		dev_err(&pf->pdev->dev, "%s - Out of memory\n", __func__);
> +		return;
> +	}
> +
> +	va_start(argptr, fmt_str);
> +	vsnprintf(buf, buf_len, fmt_str, argptr);
> +	va_end(argptr);
> +
> +	/* the debug string is already formatted with a newline */
> +	dev_info(&pf->pdev->dev, "%s", buf);
> +	kfree(buf);

%pV and avoid the malloc/free.

Also, it seems that perhaps all of these uses
try to use "%s: ", __func__, so maybe using
%pf, __builtin_return_address(0) might be better.

> +void i40e_update_stats(struct i40e_vsi *vsi)
> +{
[]
> +	for (q = 0; q < vsi->num_queue_pairs; q++) {
> +		rx_b += vsi->rx_rings[q].rx_stats.bytes;

better to use a temporary for vs->rx_rings[q]

> +

> struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
> +					u8 *macaddr, u16 vlan,
> +					bool is_vf, bool is_netdev)
> +{
[]
> +		f = kzalloc(sizeof(*f), GFP_ATOMIC);
> +		if (NULL == f) {
> +			if (is_netdev)
> +				netdev_err(vsi->netdev,
> +					   "%s: no memory for new filter\n",
> +					   __func__);
> +			else
> +				dev_err(&vsi->back->pdev->dev,
> +					 "%s: no memory for new filter\n",
> +					 __func__);

No need for OOM messages, there are a lot
of these.

> +static int i40e_set_mac(struct net_device *netdev, void *p)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_vsi *vsi = np->vsi;
> +	struct sockaddr *addr = p;
> +	struct i40e_mac_filter *f;
> +
> +	netdev_info(netdev, "%s: address=%pM\n", __func__, addr->sa_data);

sa_addr?  Is family guaranteed to be ARPHDR_ETHER here?

[]

> +static void i40e_set_rx_mode(struct net_device *netdev)
> +{

> +		if (f->macaddr[0] & 0x01) {

is_multicast_ether_addr()

Sorry, this is very long and I wonder if you really
intend this to be merged as-is.
