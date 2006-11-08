From: Stephen Hemminger <shemminger@osdl.org>
Subject: General network driver suspend/resume (was e1000 carrier related)
Date: Wed, 8 Nov 2006 11:54:14 -0800
Message-ID: <20061108115414.7e089a58@freekitty>
References: <20061106013153.GN15897@curie-int.orbis-terrarum.net>
	<20061107071449.GB21655@elf.ucw.cz>
	<4550AB7A.10508@intel.com>
	<20061108120407.GA9506@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12747 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1754660AbWKHTyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 14:54:31 -0500
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20061108120407.GA9506@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 8 Nov 2006 13:04:07 +0100
Pavel Machek <pavel@ucw.cz> wrote:

> Hi!
> 
> > >>This behavior differs from every other network card, and is also present 
> > >>in the
> > >>7.3* version of the driver from sourceforge.
> > >>
> > >>I think the e1000 should try to raise the link during the probe, so that 
> > >>it
> > >>works properly, without having to set ifconfig ethX up first.
> > >
> > >I think you should cc e1000 maintainers, and perhaps provide a patch....
> > 
> > I've read it and not come up with an answer due to some other issues at 
> > hand. E1000 hardware works differently and this has been asked before, but 
> > the cards itself are in low power state when down. Changing this to bring 
> > up the link would make the card start to consume lots more power, which 
> > would automatically suck enormously for anyone using a laptop.
> 
> Well, maybe E1000 should behave as the other cards behave, and
> different solution needs to be found for power saving? ifconfig eth0
> suspend?
> 
> 									Pavel
>  
> 

The standard which all network drivers should use is:

module insertion:
	start in initial powerdown state

open:
	power up, bring up link

stop:
	bring down link
	return to powerdown state unless WOL is set.
	if doing WOL go to lowest power sensing state

suspend:
	same as stop

resume:
	same as open

module removal:
	stop already called so device should be in power down state.


Since suspend is basically same as stop, and resume is open
I am going to investigate doing suspend/resume in the network device layer
(unless subclassed by driver), so we can rip out the suspend/resume hook
from many network drivers. There will still be boards like sky2
that need own suspend/resume to deal with dual port etc.

-- 
Stephen Hemminger <shemminger@osdl.org>
