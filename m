From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/9] iPhase: 64bit cleanup
Date: Thu, 09 Nov 2006 16:12:30 -0800 (PST)
Message-ID: <20061109.161230.71161297.davem@davemloft.net>
References: <200611090351.kA93p4ho003684@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk, alan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47775
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424295AbWKJAMW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 19:12:22 -0500
To: akpm@osdl.org
In-Reply-To: <200611090351.kA93p4ho003684@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Wed, 08 Nov 2006 19:51:04 -0800

> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> 
> Signed-off-by: Alan Cox <alan@redhat.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

This fixes the most obvious 64-bit problems, but it is still very very
broken in other aspects.  It is bad enough that I feel irresponsible
turning it on in the 64-bit build.

For example, it takes an ioremap()'d value, and accesses it as a
regular cpu pointer which will explode on many architectures since
all such accesses should go through asm/io.h accessors.

Specifically I'm talking about dev->seg_ram, it is initialized like
this:

	base = ioremap(real_base,iadev->pci_map_size);  /* ioremap is not resolved ??? */  
 ...
	iadev->seg_ram = base + ACTUAL_SEG_RAM_BASE;  
 ...

Then used like this:

     desc1 = *(u_short *)(dev->seg_ram + dev->host_tcq_wr);

and this:

        *(u_short *) (dev->seg_ram + dev->host_tcq_wr) = 0;

and this:

           *(u_short *)(dev->seg_ram + dev->ffL.tcq_rd) = i+1;

and this:

  desc_num = *(u_short *)(dev->seg_ram + dev->ffL.tcq_rd);

and this:

     desc_num = *(u_short *)(dev->seg_ram + dev->ffL.tcq_rd);

and this:

      SchedTbl = (u16*)(dev->seg_ram+CBR_SCHED_TABLE*dev->memSize); 
 ...
      TstSchedTbl = (u16*)(SchedTbl+testSlot);  //set index and read in value
 ...
          memcpy((caddr_t)&cbrVC,(caddr_t)TstSchedTbl,sizeof(cbrVC));
 ...
       memcpy((caddr_t)TstSchedTbl, (caddr_t)&vcIndex,sizeof(TstSchedTbl));

Really, this driver has a ton of unresolved portability problems.
