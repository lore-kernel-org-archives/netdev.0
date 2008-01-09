From: Karsten Keil <kkeil@suse.de>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Wed, 9 Jan 2008 21:26:53 +0100
Message-ID: <20080109202653.GA26160@pingi.kke.suse.de>
References: <20080109153656.GA16962@pingi.kke.suse.de> <20080109161748.GA25106@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:48809 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756590AbYAIU0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 15:26:55 -0500
Received: from Relay2.suse.de (relay-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 4A66126329
	for <netdev@vger.kernel.org>; Wed,  9 Jan 2008 21:26:54 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20080109161748.GA25106@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2008 at 11:17:48AM -0500, Neil Horman wrote:
> On Wed, Jan 09, 2008 at 04:36:56PM +0100, Karsten Keil wrote:
> > Hi,
> > 
> > I tried to run the 1.5.0 Beta2  TAHI Selftest on recent Linux kernel.
> > It fails in the Stateless Address Autoconfiguration section with
> > 6 tests.
> > These tests are for Duplicate Address Detection (DAD).
> > They are detect for the Link Local Address a duplicate address on the
> > network. It seems that our current behavior is to log an message and
> > do not assign this address.
> > 
> > But the RFC 4862 says:
> > 
> > 5.4.5.  When Duplicate Address Detection Fails
> > 
> >    A tentative address that is determined to be a duplicate as described
> >    above MUST NOT be assigned to an interface, and the node SHOULD log a
> >    system management error.
> > 
> >    If the address is a link-local address formed from an interface
> >    identifier based on the hardware address, which is supposed to be
> >    uniquely assigned (e.g., EUI-64 for an Ethernet interface), IP
> >    operation on the interface SHOULD be disabled.  By disabling IP
> >    operation, the node will then:
> > 
> >    -  not send any IP packets from the interface,
> > 
> >    -  silently drop any IP packets received on the interface, and
> > 
> >    -  not forward any IP packets to the interface (when acting as a
> >       router or processing a packet with a Routing header).
> > 
> >    In this case, the IP address duplication probably means duplicate
> >    hardware addresses are in use, and trying to recover from it by
> >    configuring another IP address will not result in a usable network.
> >    In fact, it probably makes things worse by creating problems that are
> >    harder to diagnose than just disabling network operation on the
> >    interface; the user will see a partially working network where some
> >    things work, and other things do not.
> > 
> >    On the other hand, if the duplicate link-local address is not formed
> >    from an interface identifier based on the hardware address, which is
> >    supposed to be uniquely assigned, IP operation on the interface MAY
> >    be continued.
> > 
> > 
> > So I think we should disable the interface now, if DAD fails on a
> > hardware based LLA.
> > 
> 
> Not sure I agree with that.  I assume that by disable, you mean that we should
> clear the IFF_UP flag?  If we do that, and another ip address is assigned to
> that interface, then your proposal would discontinue the functionality of those
> already established addresses, which would be bad.  I could see a DOS scenario
> comming out of that as well.  Simply send ndisc na's for a recently advertised
> address, and you could prevent network communication for an entire system.
> 
> Reading the section you reference, we do follow all the MUST requirements, and
> we log an error.  Given that the disable section is a SHOULD, I think we can at
> least be somewhat more restrictive in our implementation.  Perhaps we should
> just disable the interface iff the failed address is link-local AND there are no
> other functional address assigned to the interface.

I agree here, but it seems that currently the IPv6 Logo Committee thinks
that it has to be disable the interface to get the IPv6 ready Logo in
future. I already claim that on a discussion at the TAHI users list.


So far I remember a SHOULD in RFC has to interpreted as "You should
implement that in this way, exceptions are only acceptable for a good
reason". Maybe the DOS scenario is such a good reason.

-- 
Karsten Keil
SuSE Labs
