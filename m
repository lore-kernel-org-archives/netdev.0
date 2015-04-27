From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] ehea: Fix memory hook reference counting crashes
Date: Mon, 27 Apr 2015 10:30:36 +1000
Message-ID: <1430094636.8494.3.camel@ellerman.id.au>
References: <1429854752-5698-1-git-send-email-mpe@ellerman.id.au>
	 <20150425.144354.1149917806926276049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, anton@samba.org,
	cascardo@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:51663 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbbD0Aai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Apr 2015 20:30:38 -0400
In-Reply-To: <20150425.144354.1149917806926276049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-04-25 at 14:43 -0400, David Miller wrote:
> From: Michael Ellerman <mpe@ellerman.id.au>
> Date: Fri, 24 Apr 2015 15:52:32 +1000
> 
> > The recent commit to only register the EHEA memory hotplug hooks on
> > adapter probe has a few problems.
> > 
> > Firstly the reference counting is wrong for multiple adapters, in that
> > the hooks are registered multiple times. Secondly the check in the tear
> > down path is backward. Finally the error path doesn't decrement the
> > count.
> > 
> > The multiple registration of the hooks is the biggest problem, as it
> > leads to oopses when the system is rebooted, and/or errors during memory
> > hotplug, eg:
>  ...
> > Fixes: aa183323312d ("ehea: Register memory hotplug, reboot and crash hooks on adapter probe")
> > Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> 
> Applied, but using an atomic counter for this is really inappropriate
> and is what lead to this bug in the first place.
> 
> You're not counting anything, because if you were, then you would be
> decrementing this thing somewhere.
> 
> Rather, it's purely a boolean state saying "I did X".  So it should be
> a boolean, and no atomicity nor other special considerations are
> needed for setting it to true.

Yeah I agree, it's a mess.

We should be unregistering the hooks when the last adapter is removed, which is
where we'd do the decrement. As it's written the hooks stay registered until
the driver is removed.

I'll try and find time, or someone else with time, to fix it up properly for 4.2.

cheers
