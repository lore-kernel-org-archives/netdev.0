From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Wed, 18 Jun 2008 20:03:37 +0300
Message-ID: <200806182003.37120.denys@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <200806180004.49272.denys@visp.net.lb> <36D9DB17C6DE9E40B059440DB8D95F52056F2823@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:52756 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396AbYFRRDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 13:03:37 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52056F2823@orsmsx418.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 18 June 2008 19:50, Brandeburg, Jesse wrote:
> Denys Fedoryshchenko wrote:
> > After trying everything, it looks like that problem in PBS size, and
> > as result PBA (rx fifo) size. 
> 
> agreed
>  
> > On ICH8 it is small, only 16K PBS (0x10), and RX/TX set each 8k, even
> > i can set 0xd/0x3 it doesn't help (i didn't measure if it make less
> 
> just to make sure, you set PBA=0xd, correct?
Yes
> 
> > packetloss). As i understand, i need to set only RX, TX calculated
> > automatically.  Both motherboards i tried had ICH8.
> 
> your understanding is correct, the lower 8 bits represent rx fifo size,
> and the tx fifo size is computed based on the result of (PBS - (lower 8
> bits of)PBA)
> 
> Please note this is mostly documented in the software developers manuals
> posted both at intel.com and e1000.sourceforge.net.  ICH8 documentation
> is mostly covered in the chipset documentation.
>  
> > All other servers which i mention, and which have enough big load
> > have: 1)Sun - PBA 48K (82546EB)
> > 2)DP35DP - PBA 16K (ICH9)
> > 
> > Also ICH8 missing some features, that ICH9 supports, such as
> > FLAG_HAS_ERT, but it looks ERT useful only for Jumbo frames. 
> > And sure ICH8 doesn't support Jumbo frames, maybe because of limited
> > PBS. 
> > 
> > Is PBS size hardware limitation of ICH8?
> yes, working size of the FIFO is 16kB total (PBS)
> 
> > Is it possible i am right in my conclusions?
> yes, client parts will not buffer as much data (generally) due to
> smaller FIFO as the server parts, which typically have 64kB total FIFO.
> 
> > Probably such details in network adapters will be useful for Vyatta
> > guys, to choose proper network adapter for their systems :-) 
> 
> agreed, the rule here would be don't use client parts for server class
> workloads, unfortunately we don't control what machines certain server
> vendors put client parts like 82573, ICH8/ICH9 in, so sometimes you have
> a "low end" server with a client gigabit ethernet part.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Yes, 0xd. I am using now onboard 82546GB on old Intel Xeon 3.0 Ghz, flow-control works flawlessly.
cpu family      : 15
model           : 4
model name      : Intel(R) Xeon(TM) CPU 3.00GHz
stepping        : 1
cpu MHz         : 2992.650
cache size      : 1024 KB                                                                                                                                    

I have packetloss, but now it is 1.516-e06 %, which is acceptable number for me.
I had to increase ring size, otherwise i was getting rx_no_buffer_count in stats.

It is still famous  rx_missed_errors: 3616 .
But as i reported in personal mail, before rx_missed_errors was larger than tx_deferred_ok, now it is:
     rx_missed_errors: 3633
     tx_deferred_ok: 19145380

Now server handling 180Kpps RX, 800Mbps RX+TX, 4 VLAN.
latest git kernel running. I will do probably soon profiling iptables on it and some other tasks to test.
Maybe i will try also just to compare ICH9, if will have chance and way to buy it.

MegaRouterXeon-KARAM ~ # mpstat 30
Linux 2.6.26-rc6-git4-build-0029 (MegaRouterXeon-KARAM)         06/18/08

20:04:02     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal   %idle    intr/s
20:04:32     all    0.09    0.00    1.19    0.00    1.94   14.93    0.00   81.84  17775.00
20:05:02     all    0.09    0.00    1.32    0.00    1.72   14.70    0.00   82.17  17810.23


-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon
