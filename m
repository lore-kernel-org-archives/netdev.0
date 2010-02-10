From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: bnx2 limits user-specified advertised speeds to one
Date: Wed, 10 Feb 2010 23:35:29 +0000
Message-ID: <1265844929.28110.16.camel@localhost>
References: <4B731F8A.20508@hp.com>
	 <1265839887.8125.39.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28603 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755765Ab0BJXfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 18:35:36 -0500
In-Reply-To: <1265839887.8125.39.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-10 at 14:11 -0800, Michael Chan wrote:
> On Wed, 2010-02-10 at 13:05 -0800, Vlad Yasevich wrote:
> > Hi
> > 
> > A customer has noted that when attempting to change the advertised speeds
> > setting on card using a bnx2 driver, the driver advertises either all available
> > speeds or just one.  In other words, if a user attempts to set multiple
> > advertised speeds,  the settings will not be honored.
> > 
> > Looking at the code in bnx2_set_settings, the checks for 10baseT and 100baseT
> > make an assumption that the user provided only 1 speed setting.
> > 
> > e1000 and e1000e work correctly when the user specifies multiple advertised
> > speeds.
> > 
> > Before attempting to fix this, I wanted to ask if there was a reason for the
> > current functionality.
> > 
> 
> Probably code to handle limitations in older versions of the ethtool
> program.  There is no reason for it to be like this anymore.  I'll fix
> this in my next patch set.  Thanks for reporting this.

Older versions of ethtool can request invalid advertising masks
(including flags not set in the supported mask) and do not enable
advertising of 10G modes.  In the out-of-tree version of sfc we use this
workaround:

        /* Older versions of ethtool don't set all the right bits when
         * turning autoneg on with no speed/duplex specified.  But they
         * always set more than one bit in this case, so test for that.
         * Allow overriding this in ethtool 6 by setting
         * ADVERTISED_Autoneg = 0x40.
         */
        if (ecmd->advertising & (ecmd->advertising - 1) &&
            !(ecmd->advertising & ADVERTISED_Autoneg))
                ecmd->advertising = ecmd->supported;

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

