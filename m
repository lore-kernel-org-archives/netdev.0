From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Tue, 10 May 2016 14:06:18 +0200
Message-ID: <20160510140618.3ad4a35f@griffin>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
	<1462347393-22354-5-git-send-email-simon.horman@netronome.com>
	<20160506113504.77a9504e@griffin>
	<20160509081818.GB4470@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741AbcEJMGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 08:06:22 -0400
In-Reply-To: <20160509081818.GB4470@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 9 May 2016 17:18:20 +0900, Simon Horman wrote:
> On Fri, May 06, 2016 at 11:35:04AM +0200, Jiri Benc wrote:
> > In addition, we should check whether mac_len > 0 and in such case,
> > change skb->protocol to ETH_P_TEB first (and store that value in the
> > pushed eth header).
> > 
> > Similarly on pop_eth, we need to check skb->protocol and if it is
> > ETH_P_TEB, call eth_type_trans on the modified frame to set the new
> > skb->protocol correctly. It's probably not that simple, as we'd need a
> > version of eth_type_trans that doesn't need a net device.
> 
> I'm not sure I understand the interaction with ETH_P_TEB here.
> 
> In my mind skb->protocol == ETH_P_TEB may be used early on in OvS's receive
> processing to find the inner protocol from the packet and at that point
> skb->protocol is set to that value. And that for further packet processing
> the fact the packet was received as TEB is transparent.

Yes but think about the case when you have two Ethernet headers pushed.

We can either disallow it, or do what I described.

Specifically, let's assume we have an IP packet with an Ethernet
header present. skb->protocol is ETH_P_IP. Now, when there's skb_push,
the correct operation would be setting skb->protocol to ETH_P_TEB,
pushing a new Ethernet header and filing ETH_P_TEB to the ethertype
field in the new header. The packet is not ETH_P_IP anymore, as the L2
header is followed by another Ethernet header now.

 Jiri
