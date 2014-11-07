From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [net-next 1/9] i40e: poll firmware slower
Date: Fri, 7 Nov 2014 14:58:19 -0800
Message-ID: <20141107145819.00007fa0@unknown>
References: <1415350670-15333-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1415350670-15333-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<063D6719AE5E284EB5DD2968C1650D6D1C9EAE27@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Kamil Krawczyk <kamil.krawczyk@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	jesse.brandeburg@intel.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42432 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772AbaKGW62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 17:58:28 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9EAE27@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the review David, comments follow.

On Fri, 7 Nov 2014 09:40:08 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

> From: Jeff Kirsher
> > From: Kamil Krawczyk <kamil.krawczyk@intel.com>
> > 
> > The code was polling the firmware tail register for completion every
> > 10 microseconds, which is way faster than the firmware can respond.
> > This changes the poll interval to 1ms, which reduces polling CPU
> > utilization, and the number of times we loop.
> 
> Are you sure the code path is allowed to sleep?

Yes, we are never (should never be) in interrupt context when calling
these routines.

> 
> > The maximum delay is still 100ms.
> 
> Actually it is now likely to be up to 200ms or more.
> You could convert the maximum delay check to one that
> looks at jiffies - but maybe it doesn't matter.

Thats okay, this is all init or reset or shutdown level code.  If the
delay goes up it won't hurt anything.

> 
> > --- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
> > @@ -853,7 +853,6 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
> >  	 */
> >  	if (!details->async && !details->postpone) {
> >  		u32 total_delay = 0;
> > -		u32 delay_len = 10;
> > 
> >  		do {
> >  			/* AQ designers suggest use of head for better
> > @@ -862,8 +861,8 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
> >  			if (i40e_asq_done(hw))
> >  				break;
> >  			/* ugh! delay while spin_lock */
> 
> The comment is not right any more.

yes it should have been removed.

> 
> > -			udelay(delay_len);
> > -			total_delay += delay_len;
> > +			usleep_range(1000, 2000);
> > +			total_delay++;
> >  		} while (total_delay < hw->aq.asq_cmd_timeout);
> >  	}
> > 
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> > b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> > index ba38a89..df0bd09 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> > @@ -141,7 +141,7 @@ static inline int i40e_aq_rc_to_posix(u16 aq_rc)
> > 
> >  /* general information */
> >  #define I40E_AQ_LARGE_BUF	512
> > -#define I40E_ASQ_CMD_TIMEOUT	100000  /* usecs */
> > +#define I40E_ASQ_CMD_TIMEOUT	100  /* msecs */
> 
> It looks like this value is written to asq_cmd_timeout, that makes
> be wonder whether anything else can change it - otherwise the compile
> time constant would be used.
> Changing the units has broken anything else that modifies the value.

I pretty much agree with you, but I can tell you why it's there.
Currently nothing in the code changes it.  The code was designed such
that it can run on hardware requiring different timeouts.
