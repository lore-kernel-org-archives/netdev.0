From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: RFC crap-patch [PATCH] net: Per CPU separate frag mem accounting
Date: Thu, 14 Mar 2013 09:59:21 +0100
Message-ID: <1363251561.14913.33.camel@localhost>
References: <20130308221647.5312.33631.stgit@dragon>
	 <20130308221744.5312.14924.stgit@dragon>
	 <1363245955.14913.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40042 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752621Ab3CNI73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 04:59:29 -0400
In-Reply-To: <1363245955.14913.21.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-14 at 08:25 +0100, Jesper Dangaard Brouer wrote:
> This is NOT the patch I just mentioned in the other thread, of removing
> the LRU list.  This patch does real per cpu mem acct, and LRU per CPU.
> 
> I get really good performance number with this patch, but I still think
> this might not be the correct solution.

The reason is this depend on fragments entering the same HW queue, some
NICs might not put the first fragment (which have the full header
tuples) and the remaining fragments on the same queue. In which case
this patch will loose its performance gain.

> My current best results, which got applied recently, compared to this
> patch:
>  - Test-type:  Test-20G64K    Test-20G3F  20G64K+DoS   20G3F+DoS
>  - Patch-06:   18486.7 Mbit/s  10723.20     3657.85     4560.64 Mbit/s
>  - curr-best:  19041.0 Mbit/s  12105.20    10160.40    11179.30 Mbit/s

I noticed that this also included some other patches in my stack
 - New patchset-B:
 - PatchB-07: Fix LRU list head multi CPU race
 - PatchB-07:  18731.5 Mbit/s  10721.9      4079.22     5208.73 Mbit/s
 - PatchB-08: Per hash bucket locking
 - PatchB-08:  15959.5 Mbit/s  10968.9      4294.63     6365.16 Mbit/s

As you can see I'm looking into why "PatchB-08" which implement per hash
bucket locking is reducing throughput in Test-20G64K.


> Thus, I have almost solved DoS effect Test-20G3F 12GBit/s -> 11Gbit/s
> under DoS. The 64K+DoS case is not perfect yet, 19Gbit/s -> 11 Gbit/s.
> 
> --Jesper
