From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Wed, 14 Jan 2015 09:20:52 -0800
Message-ID: <1421256052.11734.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1719052.SGOfRAJhfQ@storm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:42060 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402AbbANRU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 12:20:56 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so10037491ieb.3
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 09:20:56 -0800 (PST)
In-Reply-To: <1719052.SGOfRAJhfQ@storm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-14 at 16:32 +0100, Thomas Jarosch wrote:
> Hello,
> 
> after updating a good bunch of production level machines
> from kernel 3.4.101 to kernel 3.14.25, a few of them started
> to show serious trouble when there was a lot of network traffic.
> 
> ---------------------------------------------------------------
> Jan 14 11:14:57 intrartc kernel: e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
> Jan 14 11:14:57 intrartc kernel:  TDH                  <3b>
> Jan 14 11:14:57 intrartc kernel:  TDT                  <76>
> Jan 14 11:14:57 intrartc kernel:  next_to_use          <76>
> Jan 14 11:14:57 intrartc kernel:  next_to_clean        <31>
> Jan 14 11:14:57 intrartc kernel: buffer_info[next_to_clean]:
> Jan 14 11:14:57 intrartc kernel:  time_stamp           <ffff328c>
> Jan 14 11:14:57 intrartc kernel:  next_to_watch        <3b>
> Jan 14 11:14:57 intrartc kernel:  jiffies              <ffff33b9>
> Jan 14 11:14:57 intrartc kernel:  next_to_watch.status <0>
> Jan 14 11:14:57 intrartc kernel: MAC Status             <40080083>
> Jan 14 11:14:57 intrartc kernel: PHY Status             <796d>
> Jan 14 11:14:57 intrartc kernel: PHY 1000BASE-T Status  <3800>
> Jan 14 11:14:57 intrartc kernel: PHY Extended Status    <3000>
> Jan 14 11:14:57 intrartc kernel: PCI Status             <10>
> Jan 14 11:14:59 intrartc kernel: e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
> ..
> ---------------------------------------------------------------
> 
> All of those troubled machines use an Intel DH61CR board and
> are driven by the e1000e driver. Kernels 3.7.0 to 3.19-rc4 are affected.
> 
> The problem vanishes when you disable TSO. This is the
> recommended "solution" on serverfault and others.
> http://ehc.ac/p/e1000/bugs/378/
> http://serverfault.com/questions/616485/e1000e-reset-adapter-unexpectedly-detected-hardware-unit-hang
> 
> I have a test setup that can trigger the problem within seconds
> and bisected it down to this commit (hi Eric!):
> ---------------------------------------------------------------
> commit 69b08f62e17439ee3d436faf0b9a7ca6fffb78db
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Wed Sep 26 06:46:57 2012 +0000
> 
>     net: use bigger pages in __netdev_alloc_frag
> 
>     We currently use percpu order-0 pages in __netdev_alloc_frag
>     to deliver fragments used by __netdev_alloc_skb()
> 
>     Depending on NIC driver and arch being 32 or 64 bit, it allows a page to
>     be split in several fragments (between 1 and 8), assuming PAGE_SIZE=4096
> 
>     Switching to bigger pages (32768 bytes for PAGE_SIZE=4096 case) allows :
> 
>     - Better filling of space (the ending hole overhead is less an issue)
> 
>     - Less calls to page allocator or accesses to page->_count
> 
>     - Could allow struct skb_shared_info futures changes without major
>     performance impact.
> 
>     This patch implements a transparent fallback to smaller
>     pages in case of memory pressure.
> 
>     It also uses a standard "struct page_frag" instead of a custom one.
> 
>     Signed-off-by: Eric Dumazet <edumazet@google.com>
>     Cc: Alexander Duyck <alexander.h.duyck@intel.com>
>     Cc: Benjamin LaHaise <bcrl@kvack.org>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> ---------------------------------------------------------------
> 
> Reverting the commit f.e. in kernel 3.7.0  solves the issue.
> I've done some more tests:
> 
>     3.18.0 32bit + PAE: broken
>     3.6.0 32bit + PAE: works
>     3.7.0 32bit + PAE: broken
>     3.7.0 32bit + PAE + revert 69b08f62e17439ee3d436faf0b9a7ca6fffb78db -> works
> 
>     3.7.0 32bit (without PAE) -> broken
>     3.7.0 32bit + "GFP_COMP" flag removed in __netdev_alloc_frag(): broken
>     3.7.0 32bit + "GFP_COMP" flag replaced with
>                               "GFP_DMA" in __netdev_alloc_frag(): works!
>     3.7.0 32bit + "GFP_COMP" flag + "GFP_DMA" flag: broken
>     3.19-rc4 32bit: broken
> 
> 
> The problem is triggered only when the traffic is forwarded to another client.
> (this client is behind NAT). Generating traffic directly
> on the system did not trigger the issue.
> 
> To me it looks like Eric's change uncovered a memory allocation
> issue in the e1000e driver: It probably uses a memory address
> unsuitable for DMA or so. This is just a guess though.
> 
> Funny fact: I have another Intel DH61CR board that does not show the problem.
> I've borrowed (...) the mainboard from one affected box for my bisect test setup.
> 
> Please CC: comments. Thanks.

I would try to use lower data per txd. I am not sure 24KB is really
supported.

( check commit d821a4c4d11ad160925dab2bb009b8444beff484 for details)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e14fd85f64eb..8d973f7edfbd 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3897,7 +3897,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	 * limit of 24KB due to receive synchronization limitations.
 	 */
 	adapter->tx_fifo_limit = min_t(u32, ((er32(PBA) >> 16) << 10) - 96,
-				       24 << 10);
+				       8 << 10);
 
 	/* Disable Adaptive Interrupt Moderation if 2 full packets cannot
 	 * fit in receive buffer.
