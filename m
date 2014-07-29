From: "Ertman, David M" <david.m.ertman@intel.com>
Subject: RE: [net-next 11/12] e1000e: Fix EEE in S5 w/ Runtime PM enabled
Date: Tue, 29 Jul 2014 16:14:06 +0000
Message-ID: <2B0E3F215D1AB84DA946C8BEE234CCC9371476BC@ORSMSX104.amr.corp.intel.com>
References: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1406349922-9883-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20140726151005.GA20445@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Wysocki, Rafael J" <rafael.j.wysocki@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10425 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282AbaG2QOI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 12:14:08 -0400
In-Reply-To: <20140726151005.GA20445@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com]
> Sent: Saturday, July 26, 2014 8:10 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Ertman, David M; netdev@vger.kernel.org;
> nhorman@redhat.com; sassmann@redhat.com; Wysocki, Rafael J
> Subject: Re: [net-next 11/12] e1000e: Fix EEE in S5 w/ Runtime PM enabled
> 
> (Rafael Cced:)
> 
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> :
> > From: David Ertman <david.m.ertman@intel.com>
> >
> > The process of shutting down the system causes a call to the close PM
> > callback.  The reset in close causes a loss of link, and the resultant
> > LSC interrupt causes the Runtime PM idle callback to be called.  The
> > check for link (while link is down) in the idle callback is wiping the
> > information about the EEE ability of the link partner. The information
> > is still gone when the PHY is powered back up in the shutdown flow.
> > This causes EEE in S5 to fail when Runtime PM is active.
> >
> > Save the link partner's EEE ability in the idle callback so that a
> > Runtime PM event will not cause a loss of this information.
> 
> Why does e1000_check_for_copper_link_ich8lan unconditionally wipe the
> information about the EEE ability of the link partner instead of performing
> something similar to the eee_lp_ability detection part
> e1000_set_eee_pchlan ?
> 

It might be safe to not wipe the eee_lp_ability value in e1000_check_for_copper_link_ich8lan(), since the same function would be called on a link up event, but some validation would have to be done to determine the impact, as the timing of the events comes into play.  e1000_check_for_copper_link_ich8lan() starts with the assumption of link being false.  In such a case (under normal operating conditions) the value of the link partners EEE capability is eliminated so as to remove the chance of old information being used for a new/different link partner.  Then, if link is determined to be true it will re-populate eee_lp_ability with a current value.  This covers both link up and link down events in this one function.  It is only when Runtime PM, EEE and the transition flow from S0 to an Sx st
 ate all interact that the main problem with timing manifests itself.

The optimal fix for this timing error would be one of two things:  
  1) RuntimePM should not be actively calling the idle call-back when the system is transitioning from S0 to an Sx state.  Optimally, RuntimePM should have a mechanism in it to be self-aware enough to disable accessing call-backs during these transitions very early in the flow.

And/or 

  2) It would be nice if the kernel system_state variable was updated to "SYSTEM_HALT" or "SYSTEM_POWER_OFF" before the process of calling the close callback was initiated for a shutdown or suspend.  Then we could check for this condition and use this to determine our behavior in the RuntimePM call-backs (and at other points in the driver).

I don't currently have the time to take on either of these tasks.

> [...]
> > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> > b/drivers/net/ethernet/intel/e1000e/netdev.c
> > index fe3e42a..1ce0d74 100644
> > --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> > +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> > @@ -6357,9 +6357,14 @@ static int e1000e_pm_runtime_idle(struct device
> *dev)
> >  	struct pci_dev *pdev = to_pci_dev(dev);
> >  	struct net_device *netdev = pci_get_drvdata(pdev);
> >  	struct e1000_adapter *adapter = netdev_priv(netdev);
> > +	u16 eee_lp;
> >
> > -	if (!e1000e_has_link(adapter))
> > +	eee_lp = adapter->hw.dev_spec.ich8lan.eee_lp_ability;
> > +
> > +	if (!e1000e_has_link(adapter)) {
> > +		adapter->hw.dev_spec.ich8lan.eee_lp_ability = eee_lp;
> >  		pm_schedule_suspend(dev, 5 * MSEC_PER_SEC);
> > +	}
> >
> >  	return -EBUSY;
> 
> /me wonders...
> 
> commit 63eb48f151b5f1d8dba35d6176d0d7c9643b33af
> Author: David Ertman <davidx.m.ertman@intel.com>
> Date:   Fri Feb 14 07:16:46 2014 +0000
> 
>     e1000e Refactor of Runtime Power Management
> 
>     Fix issues with:
>     RuntimePM causing the device to repeatedly flip between suspend and
> resume
>     with the interface administratively downed.
>     Having RuntimePM enabled interfering with the functionality of Energy
>     Efficient Ethernet.
> 
>     Added checks to disallow functions that should not be executed if the
>     device is currently runtime suspended
> 
>     Make runtime_idle callback to use same deterministic behavior as the igb
>     driver.
> 
> pm_schedule_suspend is already called from the link change thread
> e1000_watchdog_task. You may consider removing everything from
> runtime_idle.
> 

According to Documentation/power/runtime_pm.txt and Documentation/power/pci.txt, the idle call-back is the correct place to put the check for applicability, and initiation, of a runtime suspend event.  The duplication of effort between watchdog and runtime_idle is something that I need to explore.  There are flow issues involved that will take some unraveling to fully evaluate.  This is an interesting point you raise, and any change will also need to have some validation effort to evaluate the impact.


Thanks for responding.

Dave Ertman

> --
> Ueimor
