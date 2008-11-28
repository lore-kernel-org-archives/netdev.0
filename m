From: Jay Cliburn <jcliburn@gmail.com>
Subject: atl1 transmit timeout Was: Re: oops/warning report for the week of
 November 26, 2008
Date: Fri, 28 Nov 2008 15:12:07 -0600
Message-ID: <20081128151207.3999a097@osprey.hogchain.net>
References: <492DD792.6080302@linux.intel.com>
	<20081128111827.79b12739@osprey.hogchain.net>
	<20081128093217.3888fb46@linux.intel.com>
	<20081128123631.5209d0b8@osprey.hogchain.net>
	<20081128105044.241d43c0@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:42964 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596AbYK1VMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 16:12:14 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1514841rvb.1
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2008 13:12:13 -0800 (PST)
In-Reply-To: <20081128105044.241d43c0@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Nov 2008 10:50:44 -0800
Arjan van de Ven <arjan@linux.intel.com> wrote:

> => select count(version), version from oopses where
> guilty='dev_watchdog(atl1)' group by version order by version desc;
> count |     version -------+-----------------
>     93 | 2.6.27.5
>      6 | 2.6.27.4
>      1 | 2.6.27.3
>      1 | 2.6.27.2
>      1 | 2.6.27-rc9
>      1 | 2.6.27-rc7-git1
>      1 | 2.6.27-rc7
>      1 | 2.6.27-rc6
>      6 | 2.6.27-rc3
>      7 | 2.6.27
>      4 | 2.6.26.6
> (11 rows)

Wow.  4 hits in 2.6.26, then 118 in 2.6.27.

A history of changes between 2.6.26 and 2.6.27.5 shows a mere six
changes to the driver.

commit    event
======    =====
788a5f3f  2.6.27.5
8dc186c1  atl1: fix vlan tag regression
056c7145  2.6.27.4
322df44b  2.6.27.3
6bcd6d77  2.6.27.2
bc5b8bb6  2.6.27.1
3fa8749e  2.6.27
4330ed8e  2.6.27-rc9
94aca1da  2.6.27-rc8
72d31053  2.6.27-rc7
adee14b2  2.6.27-rc6
24342c34  2.6.27-rc5
82c26a9d  atl1: disable TSO by default
6a55617e  2.6.27-rc4
30a2f3c6  2.6.27-rc3
c2ac3ef3  atl1: deal with hardware rx checksum bug
0967d61e  2.6.27-rc2
6e86841d  2.6.27-rc1
39d48157  atl1: Do not wake queue before queue has been started.
b102df14  atl1: use netdev_alloc_skb
d63ddcec  misc drivers/net endianness noise
bce7f793  2.6.26

The only one that jumps out at me is 39d48157, which contains, in part:

commit 39d48157ac1a0ff3ec81212e5451bfd1bf5f50db
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Jul 21 08:28:37 2008 -0700

    atl1: Do not wake queue before queue has been started.
    
    Based upon a bug report by Alexey Dobriyan, the patch is
    also tested by him and confirmed to fix the problem.
    
    Packet flow during link state events should not be done by
    waking and stopping the TX queue anyways, that is handled
    transparently by netif_carrier_{on,off}().
    
    So, remove the netif_{wake,stop}_queue() calls in the link
    check code, and add the necessary netif_start_queue() call
    to atl1_up().
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

[...]
@@ -2627,6 +2625,7 @@ static s32 atl1_up(struct atl1_adapter *adapter)
        mod_timer(&adapter->watchdog_timer, jiffies);
        atlx_irq_enable(adapter);
        atl1_check_link(adapter);
+       netif_start_queue(netdev);
        return 0;

Would it be reasonable to increase the above mod_timer() expiry to
jiffies + (5 * HZ)?
