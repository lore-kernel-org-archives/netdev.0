From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: Bonding ALB sends bogus packets
Date: Fri, 31 Jul 2009 09:06:58 +0930
Message-ID: <20090731090658.db36b555.lk-netdev@lk-netdev.nosense.org>
References: <20090730130656.680e9152@nehalam>
	<22132.1248985699@death.nxdomain.ibm.com>
	<20090730133545.77e5a76a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Ben Greear <greearb@candelatech.com>,
	bonding-devel@lists.sf.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:43199 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbZG3XhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 19:37:12 -0400
In-Reply-To: <20090730133545.77e5a76a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Jul 2009 13:35:45 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Thu, 30 Jul 2009 13:28:19 -0700
> Jay Vosburgh <fubar@us.ibm.com> wrote:
> 
> > Stephen Hemminger <shemminger@vyatta.com> wrote:
> > 
> > >The bonding ALB mode builds packets with type, ETH_P_LOOP.
> > >
> > >Well ETH_P_LOOP is defined as 0x0060 which looks completely bogus.
> > >All Ethernet types less than 1536 are interpreted as 802.2 frames.
> > >The result is that the resulting packet looks like a bogus 802.2
> > >frame to the other host (or switch).  I have no idea what the 
> > >initial design was or what the purpose of this code is, but it
> > >should either send a real packet or nothing at all.
> > 
> > 	I've looked at that code before, too, although I hadn't noticed
> > that ETH_P_LOOP is under the limit for interpretation as a length
> > instead of a type.
> > 
> > 	I believe the purpose of the code is to update the switch's MAC
> > address table for the port and insure it's correct, since the alb mode
> > can move MAC addresses around amongst the set of slaves.
> > 
> > 	-J
> 
> Then it ought to send an ARP or at least a real-looking 802.2 packet.
> Also, if the purpose was to update switch MAC table, why does it need
> to do it so often, rather than only when MAC address is swapped.

Generally to overcome the 300 second address timeout. You can't be sure
that any actual traffic is going to come from that address within the
timeout period. Netflow collectors are a good example of something that
receives traffic but doesn't send any. It's a common problem to have
their MAC address timeout of the upstream switch and then start seeing
the UDP Netflow traffic being flooded to all switch ports. You then
have to set up something like a persistent periodic ping to refresh the
MAC address table.

ETH_P_LOOP should probably have been avoided, as "LOOP" or "loopback"
is commonly used to refer to the Ethernet Configuration Testing
Protocol (google search for "Ethernet Loop protocol"). 

I'd suggest not using any form of ARP for this purpose. It'd place an
IPv4 requirement on the bonded interface, and various "empty" ARP
frames have meaning e.g. duplicate address detection. 802.2 test frames
or the original Ethernet V2.0 Configuration Testing Protocol have been
used for this bridge table address refresh purpose in the past.


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
