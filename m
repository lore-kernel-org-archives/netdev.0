From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next 1/8] i40e: main driver core
Date: Sun, 16 Jun 2013 21:34:19 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E416853236F@FMSMSX102.amr.corp.intel.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1371182122-26629-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <1371187762.31941.42.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64819 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750847Ab3FPVeV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 17:34:21 -0400
In-Reply-To: <1371187762.31941.42.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Joe Perches [mailto:joe@perches.com]
> Sent: Thursday, June 13, 2013 10:29 PM
> Subject: Re: [net-next 1/8] i40e: main driver core
> 

Hi, Joe.  Thanks for your comments.

> On Thu, 2013-06-13 at 20:55 -0700, Jeff Kirsher wrote:
> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >
> > This is the driver for the Intel(R) Ethernet Controller XL710 Family.
> 
> This code looks very generic and not tailored to linux.
> Are you intending to fix it to be more linux-kernel like?

This is part of our trade-off when trying to support multiple OSs by sharing code for a complex part.  We've worked to make it more linux-kernel like, tho' admittedly there are a couple places that could use a little more work.  The first couple of routines in the i40e_main.c are obvious targets.  We'll take another look at how we can make them a little less obvious.

> 
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> b/drivers/net/ethernet/intel/i40e/i40e_main.c
> []
> > +enum i40e_status_code i40e_allocate_dma_mem_d(struct i40e_hw *hw,
> 
> i40e_status?  int is more common.

Yes, you're right.  However, we are using these enums for many of our returns in order to get type-checking goodness from the compiler for catching errors in return handling.  I believe we are using the int returns on the kernel API callbacks.

> 
> > +	if (mem->va)
> > +		return I40E_SUCCESS;
> > +	else
> > +		return I40E_ERR_NO_MEMORY;
> 
> 	if (!mem->va)
> 		return -ENOMEM;
> 
> 	return 0;
> 
> but returning the pointer or NULL is much more normal.

Yep - this is one of those points where we have an OS specific implementation of an interface for our shared code (see i40e_osdep.h in patch 4/8 and all of patch 6/8).  The original design was to allow for multiple possible error codes, but I suspect now that it is implemented, we're only ever looking for success, so we probably won't have much trouble making this change.

> 
> > +enum i40e_status_code i40e_allocate_virt_mem_d(struct i40e_hw *hw,
> > +					       struct i40e_virt_mem *mem,
> > +					       u32 size)
> []
> > 	if (mem->va)
> > +		return I40E_SUCCESS;
> > +	else
> > +		return I40E_ERR_NO_MEMORY;
> > +}
> 
> same as above.

Agreed.

> 
> > +/**
> > + * i40e_debug_d - OS dependent version of debug printing
> > + * @hw:  pointer to the HW structure
> > + * @mask: debug level mask
> > + * @fmt_str: printf-type format description
> > + **/
> > +void i40e_debug_d(void *hw, u32 mask, char *fmt_str, ...)
> > +{
> > +	char *buf;
> > +	int buf_len = 512;
> > +	va_list argptr;
> > +	struct i40e_pf *pf = (struct i40e_pf *)(((struct i40e_hw *)hw)-
> >back);
> > +
> > +	if (!(mask & ((struct i40e_hw *)hw)->debug_mask))
> > +		return;
> > +
> > +	buf = kzalloc(buf_len, GFP_KERNEL);
> > +
> > +	if (!buf) {
> > +		dev_err(&pf->pdev->dev, "%s - Out of memory\n", __func__);
> > +		return;
> > +	}
> > +
> > +	va_start(argptr, fmt_str);
> > +	vsnprintf(buf, buf_len, fmt_str, argptr);
> > +	va_end(argptr);
> > +
> > +	/* the debug string is already formatted with a newline */
> > +	dev_info(&pf->pdev->dev, "%s", buf);
> > +	kfree(buf);
> 
> %pV and avoid the malloc/free.

Oh, that's a nice bit of magic - thanks.

> 
> Also, it seems that perhaps all of these uses
> try to use "%s: ", __func__, so maybe using
> %pf, __builtin_return_address(0) might be better.
> 
> > +void i40e_update_stats(struct i40e_vsi *vsi)
> > +{
> []
> > +	for (q = 0; q < vsi->num_queue_pairs; q++) {
> > +		rx_b += vsi->rx_rings[q].rx_stats.bytes;
> 
> better to use a temporary for vs->rx_rings[q]

Sure.
We actually need a pair of temporaries there, one for the tx and one for rx.

> 
> > +
> 
> > struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
> > +					u8 *macaddr, u16 vlan,
> > +					bool is_vf, bool is_netdev)
> > +{
> []
> > +		f = kzalloc(sizeof(*f), GFP_ATOMIC);
> > +		if (NULL == f) {
> > +			if (is_netdev)
> > +				netdev_err(vsi->netdev,
> > +					   "%s: no memory for new filter\n",
> > +					   __func__);
> > +			else
> > +				dev_err(&vsi->back->pdev->dev,
> > +					 "%s: no memory for new filter\n",
> > +					 __func__);
> 
> No need for OOM messages, there are a lot
> of these.

Okay.

> 
> > +static int i40e_set_mac(struct net_device *netdev, void *p)
> > +{
> > +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> > +	struct i40e_vsi *vsi = np->vsi;
> > +	struct sockaddr *addr = p;
> > +	struct i40e_mac_filter *f;
> > +
> > +	netdev_info(netdev, "%s: address=%pM\n", __func__, addr->sa_data);
> 
> sa_addr?  Is family guaranteed to be ARPHDR_ETHER here?

We can move that message down a couple lines after the check for is_valid_ether_addr(), then we'll have the guarantee.

> 
> []
> 
> > +static void i40e_set_rx_mode(struct net_device *netdev)
> > +{
> 
> > +		if (f->macaddr[0] & 0x01) {
> 
> is_multicast_ether_addr()

Sure.

> 
> Sorry, this is very long and I wonder if you really
> intend this to be merged as-is.
> 

Yes, this is long as it is a driver for a large and complex bit of silicon, and there are more features to be added in the future.  We tried to split it up in a somewhat logical way without bombing the netdev list with a huge number of patches.  We're open to other guidance if there is a custom to be followed.

We didn't assume that our first posting would be immediately merged, but rather would be the starting point for getting kernel community feedback on the way to acceptance.  We'll roll these and other comments into our codebase and come back with another rev for consideration.

Again, thanks for your comments,
sln
