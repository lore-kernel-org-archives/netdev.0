From: Jean Delvare <jdelvare@suse.de>
Subject: Re: bonding with 3c59x driver
Date: Tue, 14 Feb 2012 11:22:10 +0100
Message-ID: <201202141122.10705.jdelvare@suse.de>
References: <201202132253.16496.jdelvare@suse.de> <22039.1329171191@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48171 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752268Ab2BNKWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 05:22:13 -0500
In-Reply-To: <22039.1329171191@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

Thanks for the fast answer.

On Monday 13 February 2012 11:13:11 pm Jay Vosburgh wrote:
> Jean Delvare <jdelvare@suse.de> wrote:
> >I am trying to do network bonding on top of 3com 3C905C ethernet
> >adapters. I am facing the problem that network cable removal isn't
> >detected. It is detected when using Realtek hardware with driver
> > 8139too or VIA hardware with driver via-rhine, but no luck with
> > driver 3c59x. I'm using bonding option miimon=100 for link
> > detection.
> >
> >Does anyone know if this is a hardware limitation, or a missing
> > feature of the 3c59x driver, or a bug in that driver?
> 
> 	It just so happens that I was looking at 3c59x earlier today for
> something else.  It appears to run its internal link state detection
>  on a 5 second timer, after which (in theory) bonding's miimon would
>  notice (provided that the driver notices and calls
>  netif_carrier_off).

Thanks for the pointer. There is indeed a 5 second timer to detect 
transitions from link down to link up. However the timer period to 
detect transitions from link up to link down is 1 minute. Knowing that, 
I tested again and indeed the bonding module end up detecting the link 
going down, after up to 1 minute. That's not exactly convenient for 
bonding.

I admit I don't quite get the rationale for having different timer 
periods for detecting the link going up or down. Steffen, this was done 
by you in:

commit b4ff6450f5336c492d1e2f184d3b8186e0716b7a
Author: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Date:   Sun Mar 26 01:37:40 2006 -0800

    [PATCH] 3c59x: decrease polling interval

No rationale explained in the commit message. Can you explain? I find 
the asymmetry confusing, I'd rather use 5 seconds (if not less) for both 
cases.

> 	If that's not working, did you try use_carrier=0 to probe the
> mii register state directly?

I tried use_carrier=0 but it makes no difference.

> 	I have used 3c59x with bonding in the distant past, but I don't
> recall exactly what tweaks were necessary; it may have required
> use_carrier=0 to work at all.

Well I am still curious why the 3c59x driver has such slow polling when 
other drivers I have been testing are able to report almost instantly 
when I remove a network cable. Could it be that other network chips 
generate an interrupt on cable removal and the 3com chips do not?

-- 
Jean Delvare
Suse L3
