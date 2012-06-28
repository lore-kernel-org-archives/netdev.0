From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Thu, 28 Jun 2012 07:00:54 +0200
Message-ID: <1340859654.26242.201.camel@edumazet-glaptop>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com>
	 <1340823810.26242.81.camel@edumazet-glaptop> <4FEB6B64.5060708@hp.com>
	 <1340829541.26242.90.camel@edumazet-glaptop>
	 <20120627135034.7db7d0eb@nehalam.linuxnetplumber.net>
	 <4FEB73EF.9090702@candelatech.com>
	 <1340832022.26242.131.camel@edumazet-glaptop>
	 <4FEB7BB9.1080905@candelatech.com>
	 <1340832947.26242.169.camel@edumazet-glaptop>  <4FEB90C3.9050607@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, James Chapman <jchapman@katalix.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:46596 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184Ab2F1FA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 01:00:59 -0400
Received: by wgbdr13 with SMTP id dr13so1804584wgb.1
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 22:00:58 -0700 (PDT)
In-Reply-To: <4FEB90C3.9050607@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 16:01 -0700, Rick Jones wrote:

> Today, sure, generalizing to packet counters in general, that bloat is 
> likely on its way.  At 100 Gbit/s Ethernet, that is upwards of 147 
> million packets per second each way.  At 1 GbE it is 125 million octets 
> per second.  So, if 32 bit octet counters were insufficient for 1 GbE, 
> 32 bit packet counters likely will be insufficient for 100GbE.
> 
> Or, I suppose, 3 or more bonded 40 GbEs or 10 or more bonded 10 GbEs 
> (unlikely though that last one may be) assuming there is stats 
> aggregation in the bond interface.

Note that I am all for 64bit counters on 64bit kernels because they are
almost[1] free, since they fit in a machine word (unsigned long).

tx_dropped is the count of dropped _packets_.

If more than 32bits are needed, and someone must run this 100GbE on a
32bit machine of the last century, he really has a big problem.


[1] : LLTX drivers case 
   since ndo_start_xmit() can be run concurrently by many cpus, safely
updating an "unsigned long" requires additional hassle :

   1) Use of a spinlock to protect the update.
   2) Use atomic_long_t instead of "unsigned long"
   3) Use percpu data

3) is overkill for devices with light traffic, because it consumes lot
of RAM on machines with 2048 possible cpus, _and_ the reader must fold
the data of all possible values.
