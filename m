From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: Re: [PATCH 1/2] bridge: Adjust min age inc for HZ > 256
Date: Mon, 5 Mar 2012 12:15:37 +0200
Message-ID: <201203051215.38210.vitas@nppfactor.kiev.ua>
References: <1330625539-10247-1-git-send-email-Joakim.Tjernlund@transmode.se> <20120304210350.629ec5c6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.cyfra.ua ([62.80.160.182]:38155 "EHLO mx3.cyfra.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756578Ab2CEKjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 05:39:20 -0500
In-Reply-To: <20120304210350.629ec5c6@nehalam.linuxnetplumber.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 05 March 2012 07:03:50 Stephen Hemminger wrote:
> >
> >  /* since time values in bpdu are in jiffies and then scaled (1/256)
> > - * before sending, make sure that is at least one.
> > + * before sending, make sure that is at least one STP tick.
> >   */
> > -#define MESSAGE_AGE_INCR	((HZ < 256) ? 1 : (HZ/256))
> > +#define MESSAGE_AGE_INCR	((HZ / 256) + 1)
> >
> >  static const char *const br_port_state_names[] = {
> >  	[BR_STATE_DISABLED] = "disabled",
>
> I don't understand why this is required.
>   HZ = 100 then incr = 1
>   HZ = 1000 then incr = 3 (your patch would make it for 4).

And then we have in br_transmit_config():
bpdu.message_age = (jiffies - root->designated_age)
			+ MESSAGE_AGE_INCR;
So in the corner case when jiffies == root->designated_age the message age 
increase only by 3 (when HZ=1000).
Then, in br_set_ticks() we have:
ticks = (STP_HZ * j)/ HZ;
So, again in the corner case, the increase in age is (256*3)/1000 == 0.
That's the case Joakim wanted to avoid.

-- 
Vitalii Demianets
