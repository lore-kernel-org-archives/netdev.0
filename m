From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: SR-IOV setup race between PCI and rtnetlink
Date: Thu, 16 Feb 2012 21:25:24 +0000
Message-ID: <1329427524.2601.58.camel@bwh-desktop>
References: <1329416552.2601.37.camel@bwh-desktop>
	 <C5551D9AAB213A418B7FD5E4A6F30A0702F8FB96@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Shradha Shah <sshah@solarflare.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:55107 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754131Ab2BPVZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 16:25:28 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F8FB96@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-16 at 19:55 +0000, Rose, Gregory V wrote:
[...]
> > However we really need the VFs to be configurable immediately, so that
> > the VF driver can communicate with the PF driver (sfc).  I could add an
> > separate flag to keep the RTNL interface disabled while the inter-driver
> > interface is enabled, but that doesn't seem like the right thing to do.
> > 
> > Perhaps there should be a net device op to return the number of VFs,
> > which the net driver must then only change while holding the RTNL lock?
> > RTNL would then use that instead of dev_num_vf().
> 
> Intel drivers aren't subject to this problem at this time because the
> number of VFs are configured on driver load and don't change until you
> unload the driver and then reload it with a new max_vfs parameter. 

sfc also fixes the number of VFs at driver load, but this race can occur
*during* driver load if the driver calls pci_enable_sriov() after
register_netdevice().

It looks like most other drivers with SR-IOV capability avoid this
problem by calling pci_enable_sriov() before registering the net device.
(cxgb4 is an exception and should also suffer from this.)

The reason for the current ordering in sfc is that we also use VFs for
user-level networking and in that case the VF driver's probe function
needs to identify the corresponding net device.  If the net device isn't
registered until later then we'll have to defer that to a netdevice
notifier.

> However, if/when I get some patches done that allow the user to set
> the number of VFs via ethtool instead of just the module parameter
> that will change and this change would be very helpful in that
> circumstance also.

Wouldn't it make more sense to do that through rtnetlink, along with the
configuration of the individual VFs?

Ben.

> Sounds like a good idea to me.
> 
> - Greg
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
