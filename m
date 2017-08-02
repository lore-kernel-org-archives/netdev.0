From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [Intel-wired-lan] [PATCH 4/5] e1000e: Separate signaling for
 link check/link up
Date: Wed, 2 Aug 2017 10:34:37 -0400
Message-ID: <20170802143437.ggdlmsszqinuvcmc@csclub.uwaterloo.ca>
References: <20170721160937.GA22632@csclub.uwaterloo.ca>
 <20170721183627.13373-1-bpoirier@suse.com>
 <20170721183627.13373-4-bpoirier@suse.com>
 <14acedf3-e5d9-31e8-9ff6-fabc2127c021@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Poirier <bpoirier@suse.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        linux-kernel@vger.kernel.org
To: "Neftin, Sasha" <sasha.neftin@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <14acedf3-e5d9-31e8-9ff6-fabc2127c021@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 02, 2017 at 02:28:07PM +0300, Neftin, Sasha wrote:
> On 7/21/2017 21:36, Benjamin Poirier wrote:
> > Lennart reported the following race condition:
> > 
> > \ e1000_watchdog_task
> >      \ e1000e_has_link
> >          \ hw->mac.ops.check_for_link() === e1000e_check_for_copper_link
> >              /* link is up */
> >              mac->get_link_status = false;
> > 
> >                              /* interrupt */
> >                              \ e1000_msix_other
> >                                  hw->mac.get_link_status = true;
> > 
> >          link_active = !hw->mac.get_link_status
> >          /* link_active is false, wrongly */
> > 
> > This problem arises because the single flag get_link_status is used to
> > signal two different states: link status needs checking and link status is
> > down.
> > 
> > Avoid the problem by using the return value of .check_for_link to signal
> > the link status to e1000e_has_link().
> > 
> > Reported-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
> > Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> > ---
> >   drivers/net/ethernet/intel/e1000e/mac.c    | 11 ++++++++---
> >   drivers/net/ethernet/intel/e1000e/netdev.c |  2 +-
> >   2 files changed, 9 insertions(+), 4 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
> > index b322011ec282..f457c5703d0c 100644
> > --- a/drivers/net/ethernet/intel/e1000e/mac.c
> > +++ b/drivers/net/ethernet/intel/e1000e/mac.c
> > @@ -410,6 +410,9 @@ void e1000e_clear_hw_cntrs_base(struct e1000_hw *hw)
> >    *  Checks to see of the link status of the hardware has changed.  If a
> >    *  change in link status has been detected, then we read the PHY registers
> >    *  to get the current speed/duplex if link exists.
> > + *
> > + *  Returns a negative error code (-E1000_ERR_*) or 0 (link down) or 1 (link
> > + *  up).
> >    **/
> >   s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
> >   {
> > @@ -423,7 +426,7 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
> >   	 * Change or Rx Sequence Error interrupt.
> >   	 */
> >   	if (!mac->get_link_status)
> > -		return 0;
> > +		return 1;
> >   	/* First we want to see if the MII Status Register reports
> >   	 * link.  If so, then we want to get the current speed/duplex
> > @@ -461,10 +464,12 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
> >   	 * different link partner.
> >   	 */
> >   	ret_val = e1000e_config_fc_after_link_up(hw);
> > -	if (ret_val)
> > +	if (ret_val) {
> >   		e_dbg("Error configuring flow control\n");
> > +		return ret_val;
> > +	}
> > -	return ret_val;
> > +	return 1;
> >   }
> >   /**
> > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> > index fc6a1d9999b2..5a8ab1136566 100644
> > --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> > +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> > @@ -5081,7 +5081,7 @@ static bool e1000e_has_link(struct e1000_adapter *adapter)
> >   	case e1000_media_type_copper:
> >   		if (hw->mac.get_link_status) {
> >   			ret_val = hw->mac.ops.check_for_link(hw);
> > -			link_active = !hw->mac.get_link_status;
> > +			link_active = ret_val > 0;
> >   		} else {
> >   			link_active = true;
> >   		}
> 
> Hello Benjamin,
> 
> Will this patch fix any serious problem with link indication? Is it
> necessary? Can we consider your patch series without 4/5 part?

Without this patch, you have the race condition that can make the
watchdog_task mistakenly think the link is down when it isn't, and then
it resets the adapter, which does make the link go down.

So it is rather catastrophic for the interface.

The other patch to the interrupt handling should make it never get hit,
but the issue does still exist if not fixed and I wouldn't rule out that
it could possibly still happen even with the other fix in place.

-- 
Len Sorensen
