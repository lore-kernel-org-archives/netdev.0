From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: (Lack of) specification for RX n-tuple filtering
Date: Wed, 8 Dec 2010 18:24:03 +0200
Message-ID: <1291825443.31064.193.camel@lb-tlvb-vladz>
References: <1279832544.2104.63.camel@achroite.uk.solarflarecom.com>
 <4C48BD1A.4060409@chelsio.com>
 <1283870637.2270.10.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Dimitris Michailidis" <dm@chelsio.com>,
	"Peter Waskiewicz" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2804 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752419Ab0LHQYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 11:24:16 -0500
In-Reply-To: <1283870637.2270.10.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > It's a bit worse than that.  Currently one can only append filters, not
> > insert at a given position, as ethtool_rx_ntuple doesn't have an index
> > field.  For devices that use TCAMs, where position matters, it's quite an
> > obstacle.  It also means one cannot modify an existing filter by specifying
> > a new filter for the same index.
> 
> It looks like drivers for devices that use TCAMs should implement the
> RXNFC interface instead.
> 

Ben, from ethtool manpage it sounds like RXNFC option defines the way
the RSS hash should be calculated, while SRXNTUPLE is meant to control
the destination Rx queue for a stream specified by a filter/filters. The
semantics for a specification of the steam is also quite different. For
instance, how do u define a rule to drop all packets with source IP
address 192.168.10.200 by means of RXNFC? While with SRXNTUPLE it's
straight forward. So, if I understood the semantics of both interfaces
correctly, there is a very limited range of functionality where they may
replace one another. Pls., correct me if I'm wrong.

I also agree with Dimitris: what we have here is an offload of some
Netfilter functionality to HW. Regardless the HW implementation (TCAM or
not) if it's allowed to configure more than one rule for the same
protocol the ordering of filtering rules is important: for instance if u
change the order of applying the rules in the example below the result
of the filtering for the traffic with both VLAN 4 and destination port
3000 will be different.

ethtool -U ethX flow-type tcp4 vlan 4 action 0
ethtool -U ethX flow-type tcp4 dst-port 3000 action 3

By the way it's also unclear from the ethtool man page if it's allowed
to configure more than one rule for the same protocol. If it's not then
the above example is void... ;) However, if we want to define a proper
filtering interface I think we shouldn't restrict the driver
implementation from defining a set of rules for the same protocol,
allowing not to though.

So, I think that attaching an index to each rule could be a good idea -
this would allow us both inserting rules at the desired positions in the
filtering rule table and editing the existing rules.

It's also unclear what is the relation between RXNFC and SRXNTUPLE. The
last in general may override the decision made based on the hash result.
So, it sounds like applying rules of SRXNTUPLE should come before
applying the RSS logic and only if there was no match RSS should be
applied to that frame. Do I get it right?

Pls., comment.

thanks,
vlad


