From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH 0/4][RFC] lro: Generic Large Receive Offload for TCP traffic
Date: Tue, 31 Jul 2007 12:33:29 +0200
Message-ID: <200707311233.31227.ossthema@de.ibm.com>
References: <200707301724.33865.ossthema@de.ibm.com> <46AE4AC9.6060109@myri.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:19963 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755150AbXGaLDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 07:03:00 -0400
In-Reply-To: <46AE4AC9.6060109@myri.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thanks for finding these bugs! I'll post an updated version soon (2 patches
with no separate Kconfig patches, one LRO and one eHEA patch). See comments below.

Thanks,
Jan-Bernd

On Monday 30 July 2007 22:32, Andrew Gallatin wrote:
> I was working on testing the myri10ge patch, and I ran into a few
> problems.  I've attached a patch to inet_lro.c to fix some of them,
> and a patch to myri10ge.c to show how to use the page based
> interface.  Both patches are signed off by Andrew Gallatin
> <gallatin@myri.com>
> 
> First, the LRO_MAX_PG_HLEN is still a problem.  Minimally sized 60
> byte frames still cause problems in lro_gen_skb due to skb->len
> going negative.  Fixed in the attached patch.  It may be simpler
> to just drop LRO_MAX_PG_HLEN to ETH_ZLEN, but I'm not sure if
> that is enough.  Are there "smart" NICs which might chop off padding
> themselves?

I'd tend to stick to an explicit check as implemented in your patch
for now

> 
> Second, you still need to set skb->ip_summed = CHECKSUM_UNNECESSARY
> when modified packets are flushed, else the stack will see bad
> checksums for packets from CHECKSUM_COMPLETE drivers using the
> skb interface.  Fixed in the attached patch.

I thought about it... As we do update the TCP checksum for aggregated
packets we could add a second ip_summed field in the net_lro_mgr struct 
used for aggregated packets to support HW that does not have any checksum helper
functionality. These drivers could set this ip_summed field to CHECKSUM_NONE, 
and thus leave the checksum check to the stack. I'm not sure if these old devices benefit
a lot from LRO. So what do you think?

> 
> Fourth, I did some traffic sniffing to try to figure out what's going
> on above, and saw tcpdump complain about bad checksums.  Have you tried
> running tcpdump -s 65535 -vvv?  Have you also seen bad checksums?
> I seem to see this for both page- and skb-based versions of the driver.
> 

Hmmm, can't confirm that. For our skb-based version I see
correct checksums for aggregated packets and for the page-based version as well.
I used: (tcpdump -i ethX -s 0 -w dump.bin) in combination with ethereal.
Don't see problems as well with your tcpdump command.

