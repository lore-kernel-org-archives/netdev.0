From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next v2 1/8] i40e: main driver core
Date: Fri, 23 Aug 2013 17:00:10 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E416C615C3B@FMSMSX102.amr.corp.intel.com>
References: <1377224142-25160-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1377224142-25160-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <20130823.002805.1975660490102085087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1924 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754474Ab3HWRAb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 13:00:31 -0400
In-Reply-To: <20130823.002805.1975660490102085087.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, August 23, 2013 12:28 AM
> To: Kirsher, Jeffrey T
> Cc: Brandeburg, Jesse; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com; Nelson, Shannon; Waskiewicz Jr, Peter P; e1000-
> devel@lists.sourceforge.net
> Subject: Re: [net-next v2 1/8] i40e: main driver core

Thanks, Dave, for your time and the notes.

> 
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 22 Aug 2013 19:15:35 -0700
> 
> > +enum i40e_status_code i40e_allocate_dma_mem_d(struct i40e_hw *hw,
> > +					      struct i40e_dma_mem *mem,
> > +					      u64 size, u32 alignment)
> > +{
>  ...
> > +	mem->va = dma_alloc_coherent(&pf->pdev->dev, mem->size,
> > +				     &mem->pa, GFP_ATOMIC | __GFP_ZERO);
> 
> First, I see no reason to specify GFP_ATOMIC here, code paths that
> call this thing even have comments above them like:
> 
> --------------------
> + *  Do *NOT* hold the lock when calling this as the memory allocation
> routines
> + *  called are not going to be atomic context safe
> --------------------
> 
> Secondly, use dma_zalloc_coherent() if you want __GFP_ZERO.

Sure, we'll adjust.

> 
> > +static int i40e_get_lump(struct i40e_lump_tracking *pile, u16 needed,
> u16 id)
> > +{
> > +	int i = 0, j = 0;
> > +	int ret = I40E_ERR_NO_MEMORY;
> > +
> > +	if (pile == NULL || needed == 0 || id >= I40E_PILE_VALID_BIT) {
> > +		pr_info("%s: param err: pile=%p needed=%d id=0x%04x\n",
> > +		       __func__, pile, needed, id);
> > +		return I40E_ERR_PARAM;
> 
> Since there is absolutely no context passed into these helper routines,
> the log messages are less useful than they could be.  If you did this
> right you could use netdev_info() or dev_info() here.

Perhaps we went a little too far in trying for loosely coupled code?  We'll add enough context for dev_info().

> 
> > +void i40e_pf_reset_stats(struct i40e_pf *pf)
> > +{
> > +	memset(&pf->stats, 0, sizeof(struct i40e_hw_port_stats));
> > +	memset(&pf->stats_offsets, 0, sizeof(struct i40e_hw_port_stats));
> > +	pf->stat_offsets_loaded = false;
> > +
> > +}
> 
> Spurious empty line at end of that function.

Obviously we need another pass at catching these little whitespace issues.

> 
> > +		flush(hw);
> 
> I think this brief and common name is asking for namespace collision
> problems.  Maybe name it i40e_flush or i40e_hw_flush or something like
> that.

Good call - thanks.

> 
> > +{
> > +	int i;
> > +	struct i40e_pf *pf = vsi->back;
> 
> Please order local variable declarations from longest line to shortest.

Will do, on these and the rest.

[...]

> 
> > +static u8 i40e_dcb_get_num_tc(struct i40e_dcbx_config *dcbcfg)
> > +{
> > +	int num_tc = 0, i;
> > +	/* Scan the ETS Config Priority Table to find
> > +	 * traffic class enabled for a given priority
> > +	 * and use the traffic class index to get the
> > +	 * number of traffic classes enabled
> > +	 */
> 
> Please put an empty line between the local variables and
> the rest of the function.

Yep.

[...]

> 
> > +static inline int i40e_prev_power_of_2(int n)
> > +{
> > +	int p = n;
> > +	--p;
> > +	p |= p >> 1;
> > +	p |= p >> 2;
> > +	p |= p >> 4;
> > +	p |= p >> 8;
> > +	p |= p >> 16;
> > +	if (p == (n - 1))
> > +		return n;  /* it was already a power of 2 */
> > +	p >>= 1;
> > +	return ++p;
> > +}
> 
> I think something using rounddown_pow_of_two() would accomplish this.
> 
> Perhaps:
> 
> 	if (!is_power_of_2(x))
> 		x = rounddown_pow_of_two(x);

Oh, didn't know about that one, thanks!

sln
