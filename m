From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: BUG: NIU driver: strange issues with multicast "UDP: short
	packet"
Date: Wed, 04 Feb 2009 09:55:04 +0100
Message-ID: <1233737704.20497.70.camel@localhost.localdomain>
References: <1233668300.20497.49.camel@localhost.localdomain>
	 <20090203.153853.163818774.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:59369 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbZBDIzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 03:55:07 -0500
In-Reply-To: <20090203.153853.163818774.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-02-03 at 15:38 -0800, David Miller wrote:
> From: Jesper Dangaard Brouer <jdb@comx.dk>
> Date: Tue, 03 Feb 2009 14:38:20 +0100
> 
> >   UDP: short packet: From 81.161.2.106:0 44063/1324 to 233.123.173.7:0
> >   UDP: short packet: From 81.161.2.106:0 44063/1324 to 233.123.173.7:0
> >   UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
> >   UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
> >   UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
> >   UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
> 
> The UDP header length field is garbage in all of these packets.

Yes, but this only happens on the NIU/netpune NIC.  I works with the igb
driver, I have both a 82575 and a 82576 NIC.


> In the first two packets here, the source and dest ports are
> both zero.  This is also garbage.,
> 
> > Tcpdumping the packets, the contents of the packets are correct.
> 
> So something corrupts the packet on the way to UDP input.
> 
> > The next strange thing is that I can make the log messages go away, if I
> > setup a static multicast route out another interface.
> > 
> >   smcroute -a eth52 81.161.2.106 233.123.173.7 eth21
> 
> That could be a good clue.
> 
> Do you happen to have multicast routing enabled on this machine?

Yes
CONFIG_IP_MULTICAST=y

Looking through ipmr.c, I should also tell you that I have enabled:

CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y


> If the multicast destination is non-local and IN_DEV_FORWARD is set on
> the interface, that puts the packet through ip_mr_input.

Don't you mean IN_DEV_MFORWARD ?

> ip_mr_input() will clone the SKB if it should be delivered locally
> as well as be forwarded.

Interesting another path is choosen for mc forwarding.

If I setup a bridge for L2 forward the packets, what path is choosen
then?


> If the packet does get multicast forwarded, there is all kinds of
> funny code that mangles the packet, for example ipmr_cache_report().
> 
> Any of this could be corrupting what UDP ends up seeing.
> 
> To be honest all of the SKB handling in the ipmr.c file is very scary.

Hmmm, that doesn't sound very reassuring... 

See you around...
-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
