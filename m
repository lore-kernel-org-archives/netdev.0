From: NetArt - Grzegorz Nosek <grzegorz.nosek@netart.pl>
Subject: Re: (2.6.18.8) tg3: eth0: The system may be re-ordering memory-mapped I/O cycles to the network device, attempting to recover.
Date: Fri, 5 Oct 2007 16:44:06 +0200
Message-ID: <20071005144406.GB23224@tech.serwery.pl>
References: <20071005095722.GA23224@tech.serwery.pl> <1551EAE59135BE47B544934E30FC4FC002AABAA7@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetArt - Grzegorz Nosek <grzegorz.nosek@netart.pl>,
	netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tech.netart.pl ([85.128.128.114]:42264 "EHLO tech.serwery.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755781AbXJEOoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 10:44:14 -0400
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AABAA7@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 05, 2007 at 07:16:50AM -0700, Michael Chan wrote:
> NetArt - Grzegorz Nosek wrote:
> 
> > 
> > I have encountered an error which looks tg3-related. Upon adding some
> > htb queue rules (which I don't have handy ATM but can provide if
> > needed), after some time we get such messages in the kernel log:
> > 
> 
> Please provide the HTB queue rules and the type of traffic to make
> this happen.  Thanks.
> 

The HTB rules are as simple as below:

INTERFACE="eth0"
TC="/sbin/tc"

$TC qdisc del dev $INTERFACE root
$TC qdisc add dev $INTERFACE root handle 1:0 htb
$TC class add dev $INTERFACE parent 1:0 classid 1:1 htb rate 1000Mbit ceil 1000Mbit
$TC class add dev $INTERFACE parent 1:1 classid 1:2 htb rate 5Mbit ceil 5Mbit
$TC qdisc add dev $INTERFACE parent 1:2 sfq
$TC filter add dev $INTERFACE parent 1:0 protocol ip prio 10 u32 match ip src 10.10.10.10 flowid 1:2

(the IP address was changed but it's one of the machine's 65 local IP
addresses)

The traffic is 4-5kpps both ways, 2Mbps in, 40Mbps out. There are
several database servers running. The point of these rules was to
limit the data rate of 10.10.10.10 (a mysql server) to 5Mbps. Currently
the traffic from this IP accounts for much of the whole traffic but overall
it's pretty bursty. It ranges from nothing at all to 10Mbps to 70Mbps
peaks.

It may be related that on other machines the HTB queues are saturated
only occasionally and usually the data rates are well below HTB
settings, so a drastically overlimit queue may well be unique to this
server.

Best regards,
 Grzegorz Nosek


