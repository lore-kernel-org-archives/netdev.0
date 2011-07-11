From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridging behavior apparently changed around the Fedora 14 time
Date: Mon, 11 Jul 2011 14:24:49 -0700
Message-ID: <20110711142449.1f957af5@nehalam.ftrdhcpuser.net>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com>
	<20110711130729.607d461e@nehalam.ftrdhcpuser.net>
	<925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com>
	<20110711134938.5178797c@nehalam.ftrdhcpuser.net>
	<925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com>
	<20110711141028.19f0de46@nehalam.ftrdhcpuser.net>
	<925A849792280C4E80C5461017A4B8A2A040F7@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Lynn Hanson" <LynnHanson@eaganhills.org>,
	"Joe Whalen" <JoeWhalen@eaganhills.org>
To: "Greg Scott" <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39264 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750870Ab1GKVYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 17:24:53 -0400
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A040F7@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Jul 2011 16:16:40 -0500
"Greg Scott" <GregScott@Infrasupport.com> wrote:

> > The bridge code calls dev_set_promiscuity() which should
> > be changing device mode. But it could be that netdev core is 
> > resetting/changing/breaking that.
> 
> Is it supposed to change the physical ethnn devices or the br device?

The physical device ethnn.

> Here is what I do to set up the bridging. I do it myself right in the
> script so I can control all the details.
> 
> .
> .
> .
> #
> # Setup bridging
> #
> 
> echo "Setting up bridge $BR_IFACE to bridge $INET_IFACE with
> $TRUSTED1_IFACE"
> 
> $BRCTL addbr $BR_IFACE
> $BRCTL addif $BR_IFACE $INET_IFACE
> $BRCTL addif $BR_IFACE $TRUSTED1_IFACE
> 
> echo "  Adding $BR_IP_SLASH and $TRUSTED1_IP_SLASH IP Addresses to
> $BR_IFACE"
> /sbin/ip addr add $BR_IP_SLASH broadcast $BR_BCAST_ADDRESS dev $BR_IFACE
> /sbin/ip addr add $TRUSTED1_IP_SLASH broadcast $TRUSTED1_BCAST_ADDRESS
> dev $BR_IFACE
> /sbin/ip link set $BR_IFACE up
> 
> echo "  Removing $INET_IP_SLASH and $TRUSTED1_IP_SLASH from $INET_IFACE
> and $TRUSTED1_IFACE"
> /sbin/ip addr del $INET_IP_SLASH dev $INET_IFACE
> /sbin/ip addr del $INET_IP_SLASH dev $INET_IFACE
> /sbin/ip addr del $TRUSTED1_IP_SLASH dev $TRUSTED1_IFACE
> /sbin/ip addr del $TRUSTED1_IP_SLASH dev $TRUSTED1_IFACE
> 
> echo "  Putting $BR_IFACE into promiscuous mode"
> # This fixes a bug forwarding packets bound for external IP Addresses
> # from the private LAN.
> 
> ip link set $BR_IFACE promisc on
> 

What is supposed to happen is that the bridge adds all the interface
MAC addresses to the forwarding table as permanent entries. To show the
forwarding table:
  # brctl showmacs br0

port no	mac addr		is local?	ageing timer
  1	c6:eb:2a:0c:12:eb	yes		   0.00

Then when packet arrives with that mac address it is handed up to
netfilter, then if not firewalled, it goes on to the IP stack.

There maybe protections against packet going back out the same interface
that are getting tripped by all the rewriting.



