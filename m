From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bna: page allocation during interrupts to use a
 mempool.
Date: Mon, 06 Oct 2014 21:04:52 -0700
Message-ID: <1412654692.11091.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>
	  <20140929092833.6c2cb7e9@urahara>
	  <262CB373A6D1F14F9B81E82F74F77D5A4704FAE7@avmb2.qlogic.org>
	  <alpine.DEB.2.00.1410061850120.5129@ware.dreamhost.com>
	 <1412646735.11091.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.00.1410061956410.7392@ware.dreamhost.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: Eric Wheeler <netdev@lists.ewheeler.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35755 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbaJGEEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 00:04:54 -0400
Received: by mail-pd0-f169.google.com with SMTP id w10so4419668pde.0
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 21:04:53 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1410061956410.7392@ware.dreamhost.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-06 at 20:05 -0700, Eric Wheeler wrote:

> The patch in question implements a simple mempool for the interrupt page 
> allocs---which definitely fixes the problem even if a better solution 
> might exist.  I have no problem giving up a small amount of memory to 
> guarantee page allocs in the interrupt handler.

You have no such guarantee.

Once page is consumed by some networking frame, this frame can be
sitting in some socket receive queue. page cant be reused by the driver.

If you receive (small) burst of 100 frames, your 32 mempool will be
depleted anyway.

Even if you use a mempool with 10000 elements, there is no guarantee, it
really depends on the number of sockets and their SO_RCVBUF limits.

If your NIC depends of having order-2 pages available for its operation,
then I am afraid it cannot possibly work.

Memory will be eventually fragmented and order-2 allocations fail.

Run your patch with 100 concurrent TCP flows, add some losses to force
usage of out or order queue, you'll get errors quite fast.
