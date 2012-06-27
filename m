From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: HSR: How to set IF_OPER_LOWERLAYERDOWN?
Date: Wed, 27 Jun 2012 08:40:44 -0700
Message-ID: <20120627084044.796524a5@nehalam.linuxnetplumber.net>
References: <4FEA37A0.309@xdin.com>
	<20120626153324.455c6081@nehalam.linuxnetplumber.net>
	<4FEA64F3.8000400@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Javier Boticario <jboticario@gmail.com>,
	Bruno Ferreira <balferreira@googlemail.com>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53823 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772Ab2F0Pk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 11:40:58 -0400
In-Reply-To: <4FEA64F3.8000400@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Jun 2012 01:42:12 +0000
Arvid Brodin <Arvid.Brodin@xdin.com> wrote:

> On 2012-06-27 00:33, Stephen Hemminger wrote:
> > On Tue, 26 Jun 2012 22:28:51 +0000
> > Arvid Brodin <Arvid.Brodin@xdin.com> wrote:
> > 
> >> Hi,
> >>
> >> According to Documentation/networking/operstates.txt a network interface have an
> >> operational state and an administrative state.
> >>
> >> If I understand things correctly the administrative state is the desired state set by
> >> userspace, and the operational state is the actual state which depends on things like the
> >> administrative state, whether a carrier is present, or (for virtual interfaces lite VLAN)
> >> whether the lower interface is available.
> >>
> >>
> >> In the driver I'm writing (for the "HSR" redundancy protocol) a hsr (virtual) interface is
> >> useable as long as any of its (physical) slaves are useable. I.e. the operstate of a hsr
> >> device might be set like this:
> >>
> >> void hsr_set_operstate()
> >> {
> >> 	if (!is_admin_up(hsr_dev)) /* Check IFF_UP */ {
> >> 		set_operstate(hsr_dev, IF_OPER_DOWN);
> >> 		return;
> >> 	}
> >>
> >> 	if (is_operstate_up(slave1) || is_operstate_up(slave2)) /* Check IF_OPER_UP */
> >> 		set_operstate(hsr_dev, IF_OPER_UP);
> >> 	else
> >> 		set_operstate(hsr_dev, IF_OPER_LOWERLAYERDOWN);
> >> }
> > 
> > 
> > According to 802.1X example in documentation to set it down you need to set IF_OPER_DORMANT
> > not IF_OPER_LOWERLAYERDOWN.  Probably a kernel bug in there somwhere.
> > 
> 
> Hmm... if you're referring to the example in Documentation/networking/operstates.txt it
> seems to me that the usage of IF_OPER_DORMANT there is in compliance with RFC2863 - i.e.
> the device is waiting for some kind of handshake to finish. I don't think it has anything
> to do with taking the device down?
> 
> Oh, and I see now that set_operstate() is called from do_setlink() in
> net/core/rtnetlink.c, which means this function is used to set operstate from userspace.
> The limitations then fits with the description in operstates.txt, and this function is
> probably not meant to set an interface's operational state from within the kernel. I wrote
> my own hsr_set_operstate that accepts any values, and it seems to work... (?)
> 
> 
> Is there a way to get notifications when an interface's operational state change?
> NETDEV_CHANGE seems to trigger on carrier change, and NETDEV_UP/DOWN triggers when the
> administrative state changes - is there something similar for operational state?
> 
> (Unfortunately NETDEV_UP/DOWN triggers before the operational state for the interface in
> question changes accordingly, so it's not possible to just check dev->operstate in the
> handler for these messages. NETDEV_CHANGE seems to trigger after the interface's
> operational state has been changed, though.)
> 

I think the original intention was for kernel drivers to use
netif_carrier_on/off rather than manipulating operstate directly.
