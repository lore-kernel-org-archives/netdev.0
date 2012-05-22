From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bug 43277] New: net/e1000e set mtu larger than 1500 fails
Date: Tue, 22 May 2012 14:29:23 -0700
Message-ID: <20120522142923.4472c195@nehalam.linuxnetplumber.net>
References: <20120522111950.4548747c@nehalam.linuxnetplumber.net>
	<20120522112518.70294c0e@nehalam.linuxnetplumber.net>
	<20411.56693.728125.121309@ender.chrekh.se>
	<1337713156.2922.12.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christer Ekholm <che@chrekh.se>, <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	<e1000-devel@lists.sf.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55727 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753482Ab2EVV3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 17:29:30 -0400
In-Reply-To: <1337713156.2922.12.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 May 2012 19:59:16 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Tue, 2012-05-22 at 20:39 +0200, Christer Ekholm wrote:
> > Stephen Hemminger writes:
> >  > On Tue, 22 May 2012 11:19:50 -0700
> >  > Stephen Hemminger <shemminger@vyatta.com> wrote:
> >  > 
> >  > 
> >  > I believe the problem is detected here. Check system console log (dmesg).
> >  > The hardware does not allow receive hashing and checksum offload together
> >  > in Jumbo mode.
> >  > 
> >  > 	/*
> >  > 	 * IP payload checksum (enabled with jumbos/packet-split when
> >  > 	 * Rx checksum is enabled) and generation of RSS hash is
> >  > 	 * mutually exclusive in the hardware.
> >  > 	 */
> >  > 	if ((netdev->features & NETIF_F_RXCSUM) &&
> >  > 	    (netdev->features & NETIF_F_RXHASH)) {
> >  > 		e_err("Jumbo frames cannot be enabled when both receive checksum offload and receive hashing are enabled.  Disable one of the receive offload features before enabling jumbos.\n");
> >  > 		return -EINVAL;
> >  > 	}
> > 
> > Yes you are right.
> > 
> >  e1000e 0000:05:00.1: eth1: Jumbo frames cannot be enabled when both receive checksum offload and receive hashing are enabled.  Disable one of the receive offload features before enabling jumbos.
> > 
> > How stupid of me to not see that. 
> > 
> > After turning rxhash of, setting of mtu to 9000 is possible again.
> > 
> > $ sudo ethtool -K eth1 rxhash off
> > 
> > $ sudo ip link set eth1 mtu 9000
> > 
> > 
> > Sorry to have wasted your time.
> 
> It's not a waste of time.
> 
> I think this behaviour is broken: NETIF_F_RXHASH is turned on by default
> and user and distribution scripts that set MTU will now be broken until
> they know that they need to work around this hardware limitation.  And
> why should they ever need to know that?
> 
> I think the proper thing to do is to automatically turn off
> NETIF_F_RXHASH when the MTU is too high for it to work.  The netdev
> still keeps track of whether it is 'wanted'.
> 
> Ben.
> 

Agreed. Principal of least surprise says the best thing to
do would be turn off features that are performance improvements to allow
user to do what they wanted (and turn the error into a warning).
