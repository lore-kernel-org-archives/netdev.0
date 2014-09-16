From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: bisected regression: 3c59x corrupts packets in 3.17-rc5
Date: Tue, 16 Sep 2014 06:17:04 -0400
Message-ID: <20140916101704.GA3792@hmsreliant.think-freely.org>
References: <alpine.LRH.2.11.1409160209280.21050@adalberg.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	netdev@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59192 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbaIPKRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 06:17:20 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.11.1409160209280.21050@adalberg.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 02:14:54AM +0300, Meelis Roos wrote:
> Somewhere between 3.17.0-rc3 and 3.17.0-rc5 I started seeing dropped ssh 
> connections to a couple of test servers with dual AthlonMP (32-bit) and 
> 3C90x family of NICs (3Com Corporation 3c980-C 10/100baseTX NIC 
> [Python-T] (rev 78) in one server and 3Com Corporation 3c905C-TX/TX-M 
> [Tornado] (rev 78) in the other server). Bisect leads to the following 
> commit:
> 
> 98ea232cf63961fad734cc8c5e07e8915ec73073 is the first bad commit
> commit 98ea232cf63961fad734cc8c5e07e8915ec73073
> Author: Neil Horman <nhorman@tuxdriver.com>
> Date:   Thu Sep 4 06:13:38 2014 -0400
> 
>     3c59x: avoid panic in boomerang_start_xmit when finding page address:
>     ...
> 
> -- 
> Meelis Roos (mroos@linux.ee)
> 
I'm guessing the above change has uncovered another bug, mostly likely an
exhaustion of dma space on your system.  Nothing in the transmit path there does
any error checking for successful dma mapping, which it really should.  I'd be
willing to be that any dma mapping error leads to a leak in the mapping table.
Does your system have an iommu, or does it use swiotlb?  If its the latter, can
you increase the swiotlb table space and see if that relieves the problem?  In
the interim, I'll start adding some error checking to the transmit path.

Neil
