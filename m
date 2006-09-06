From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Subject: Re: ProxyARP and IPSec
Date: Tue, 5 Sep 2006 19:25:21 -0700
Message-ID: <17662.12689.423903.430390@localhost.localdomain>
References: <20060823.151424.78711856.davem@davemloft.net>
	<20060823231812.GA32394@ms2.inr.ac.ru>
	<44ECFCF1.10500@zytor.com>
	<44ECFD5F.6060901@zytor.com>
	<1156386043.7302.773.camel@tahini.andynet.net>
	<44ED2797.4070304@zytor.com>
	<20060824125046.GA25439@ms2.inr.ac.ru>
	<44EFCB0F.5080506@zytor.com>
	<17657.42254.455342.157858@localhost.localdomain>
	<44F9BFC2.4050001@zytor.com>
	<20060904222722.GA24078@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	"Stephen J. Bevan" <stephen@dino.dnsalias.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from S010600014e000000.vc.shawcable.net ([70.79.40.36]:58946 "EHLO
	dino.dnsalias.com") by vger.kernel.org with ESMTP id S965271AbWIFC0D
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 22:26:03 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060904222722.GA24078@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov writes:
 > Probably, you are not aware that "standard IPsec tunnel device",
 > if it is created:
 > 
 > 1. Probably, will not accept fragmented frames, because IPsec cannot
 >    handle them

IPsec can handle them, though not particularly smoothly if the IPsec
tunnel is only supposed to carry a particular port&protocol
combination.


 > 2. Probably, will have undefined MTU (65536), because of 1

An MTU that is more likely to make most things work (at least over
Ethernet) is ETH_DATA_LEN - MAX_SA_LEN where MAX_SA_LEN is however
much is required for IPsec (something like IP + UDP if NAT-T + ESP
header + IV + padding + ESP trailer).  The simplest thing is to just
statically configure it.  However, some implementations dynamically
calculate the IPsec device MTU based on the maximum size required by
any of the IPsec SAs that will go over the interface, using either a
pessimistic (255) or optimistic (2) padding estimate.  This can cause
problems for OPSF adjacency if each side arrives at a different MTU
but that can be handled by either manually configuring the device MTU
or explicitly configuring the MTU that OSPF will advertise (I think
Quagga supports that).


 > Actually, this is the reason why it is not implemented.
 > It is dirty business. :-) And the person, who implements this,
 > has to be really... unscrupulous. :-)

Exactly the same issue occurs if one implements IPsec (or any other
encryption method) in user-level using a tun/tap device.  Consequently
while I agree that fragmentation causes an additional level of
problems if one wants to have port/protocol based selectors in IPsec,
I believe that most (but not all) VPN users are quite satisfied with
policies containing all traffic, all ports and so will not encounter
any IPsec specific problems.
