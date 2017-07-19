From: "Nguyen, Anthony L" <anthony.l.nguyen@intel.com>
Subject: RE: [net-next v3 1/5] ixgbe: Ensure MAC filter was added before
 setting MACVLAN
Date: Wed, 19 Jul 2017 17:09:34 +0000
Message-ID: <4C5EDC162D52824D9E7FB1446983F3EE9C59E5A8@ORSMSX116.amr.corp.intel.com>
References: <20170719012305.76795-1-jeffrey.t.kirsher@intel.com>
         <20170719012305.76795-2-jeffrey.t.kirsher@intel.com>
 <1500461695.25934.35.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: Joe Perches <joe@perches.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64618 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753680AbdGSRJg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 13:09:36 -0400
In-Reply-To: <1500461695.25934.35.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Wednesday, July 19, 2017 3:55 AM
> Subject: Re: [net-next v3 1/5] ixgbe: Ensure MAC filter was added before setting
> MACVLAN
> 
> On Tue, 2017-07-18 at 18:23 -0700, Jeff Kirsher wrote:
> > This patch adds a check to ensure that adding the MAC filter was
> > successful before setting the MACVLAN.  If it was unsuccessful,
> > propagate the error.
> []
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> > b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> []
> > @@ -681,6 +681,7 @@ static int ixgbe_set_vf_macvlan(struct
> > ixgbe_adapter *adapter,  {
> >  	struct list_head *pos;
> >  	struct vf_macvlans *entry;
> > +	s32 retval = 0;
> 
> This function returns int, why use s32 here?
> 
> >  	if (index <= 1) {
> >  		list_for_each(pos, &adapter->vf_mvs.l) { @@ -721,14 +722,15
> @@
> > static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
> >  	if (!entry || !entry->free)
> >  		return -ENOSPC;
> >
> > -	entry->free = false;
> > -	entry->is_macvlan = true;
> > -	entry->vf = vf;
> > -	memcpy(entry->vf_macvlan, mac_addr, ETH_ALEN);
> > -
> > -	ixgbe_add_mac_filter(adapter, mac_addr, vf);
> > +	retval = ixgbe_add_mac_filter(adapter, mac_addr, vf);
> > +	if (retval >= 0) {
> > +		entry->free = false;
> > +		entry->is_macvlan = true;
> > +		entry->vf = vf;
> > +		memcpy(entry->vf_macvlan, mac_addr, ETH_ALEN);
> > +	}
> >
> > -	return 0;
> > +	return retval;
> 
> This is also backwards logic from typical style and unnecessarily indents code.
> 
> 	retval = ixgbe_add_mac_filter(adapter, mac_addr, vf);
> 	if (retval < 0)
> 		return retval;
> 
> 	entry->free = false;
> 	entry->is_macvlan = true;
> 	entry->vf = vf;
> 	memcpy(entry->vf_macvlan, mac_addr, ETH_ALEN);>
> 
> 	return 0;
> }
> 
> This patch also sets the return value to a possible positive value.
> 
> Is that really desired?
> 
> The only code that seems to use a possible positive value also limits its return to
> 0
> 
> static int ixgbe_uc_sync(struct net_device *netdev, const unsigned char *addr) {
> 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
> 	int ret;
> 
> 	ret = ixgbe_add_mac_filter(adapter, addr, VMDQ_P(0));
> 
> 	return min_t(int, ret, 0);
> }
> 

Hi Joe,

Thanks for the review.  I'll make those changes and get a v2 resubmitted.

Thanks,
Tony
