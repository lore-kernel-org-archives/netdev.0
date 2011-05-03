From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Tue, 03 May 2011 16:23:39 -0700
Message-ID: <4DC08E7B.7070906@chelsio.com>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com> <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23895 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955Ab1ECXXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 19:23:49 -0400
In-Reply-To: <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2011 09:12 AM, Alexander Duyck wrote:

[...]

> +static int rmgr_add(struct ethtool_rx_flow_spec *fsp)
> +{
> +	__u32 loc = fsp->location;

Unneeded assignment.  Couple lines later you assign a new value to loc.

> +	__u32 slot_num;
> +
> +	/* start at the end of the list since it is lowest priority */
> +	loc = rmgr.size - 1;
> +
> +	/* locate the first slot a rule can be placed in */
> +	slot_num = loc / BITS_PER_LONG;
> +
> +	/*
> +	 * Avoid testing individual bits by inverting the word and checking
> +	 * to see if any bits are left set, if so there are empty spots.  By
> +	 * moving 1 + loc % BITS_PER_LONG we align ourselves to the last bit
> +	 * in the previous word.
> +	 *
> +	 * If loc rolls over it should be greater than or equal to rmgr.size
> +	 * and as such we know we have reached the end of the list.
> +	 */
> +	if (!~(rmgr.slot[slot_num] | (~1UL << rmgr.size % BITS_PER_LONG))) {
> +		loc -= 1 + (loc % BITS_PER_LONG);
> +		slot_num--;
> +	}
> +
> +	/*
> +	 * Now that we are aligned with the last bit in each long we can just
> +	 * go though and eliminate all the longs with no free bits
> +	 */
> +	while (loc < rmgr.size && !~(rmgr.slot[slot_num])) {
> +		loc -= BITS_PER_LONG;
> +		slot_num--;
> +	}
> +
> +	/*
> +	 * If we still are inside the range, test individual bits as one is
> +	 * likely available for our use.
> +	 */
> +	while (loc < rmgr.size && test_bit(loc, rmgr.slot))
> +		loc--;
> +
> +	/* location found, insert rule */
> +	if (loc < rmgr.size) {
> +		fsp->location = loc;
> +		return rmgr_ins(loc);
> +	}
> +
> +	/* No space to add this rule */
> +	fprintf(stderr, "rmgr: Cannot find appropriate slot to insert rule\n");
> +
> +	return -1;
> +}

[...]

> +int rxclass_rule_ins(int fd, struct ifreq *ifr,
> +		     struct ethtool_rx_flow_spec *fsp)
> +{
> +	struct ethtool_rxnfc nfccmd;
> +	__u32 loc = fsp->location;
> +	int err;
> +
> +	/*
> +	 * if location is unspecified pull rules from device
> +	 * and allocate a free rule for our use
> +	 */
> +	if (loc == RX_CLS_LOC_UNSPEC) {
> +		/* init table of available rules */
> +		err = rmgr_init(fd, ifr);
> +		if (err < 0)
> +			return err;
> +
> +		/* verify rule location */
> +		err = rmgr_add(fsp);
> +		if (err < 0)
> +			return err;
> +
> +		/* cleanup table and free resources */
> +		rmgr_cleanup();
> +	}

This logic where ethtool tries to select a filter slot when a user provides 
RX_CLS_LOC_UNSPEC does not work in general.  It assumes that all slots are 
equal and a new filter can go into any available slot. But a device may have 
restrictions on where a filter may go that ethtool doesn't know.  I 
mentioned during a previous review that for cxgb4 some filters require a 
slot number that is a multiple of 4.  There are some other constraints as 
well depending on the type of filter being added. For such a device ethtool 
doesn't know enough to handle RX_CLS_LOC_UNSPEC correctly.

I think RX_CLS_LOC_UNSPEC should be passed to the driver, where there is 
enough knowledge to pick an appropriate slot.  So I'd remove the

     if (loc == RX_CLS_LOC_UNSPEC)

block above, let the driver pick a slot, and then pass the selected location 
back for ethtool to report.
