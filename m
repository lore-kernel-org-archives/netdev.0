From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/4] phylib: Allow reading and writing a mii bus from
 atomic context.
Date: Fri, 16 Jul 2010 13:49:03 +0200
Message-ID: <20100716114903.GB2996@riccoc20.at.omicron.at>
References: <cover.1278307573.git.richard.cochran@omicron.at>
 <a06cf09ed5096bf8f9434d90828adfa70586e936.1278307573.git.richard.cochran@omicron.at>
 <AANLkTikEF3B-0JGvqosY5jMaChbpYctOmKW1jJKOWsQE@mail.gmail.com>
 <20100707071832.GA2816@riccoc20.at.omicron.at>
 <20100716112544.GA2996@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46934 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965166Ab0GPLtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 07:49:07 -0400
Received: by bwz1 with SMTP id 1so1166779bwz.19
        for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 04:49:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100716112544.GA2996@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 08, 2010 at 03:40:41PM -0500, Andy Fleming wrote:
> 
> Wait, is the intent for this mdio read to be done for *every* packet?
> MDIO is spec'ed out to go up to 2.5MHz.  Each transaction takes 64
> cycles.  And I see that reading the timestamp from the PHY you
> submitted support for takes at *least* 2 transactions.  The fastest
> you can process packets would then be under 20,000 packets per second.
> Even on a 100Mb link with full-sized packets, you would be 40% done
> receiving the next packet before you had passed the packet on to the
> stack.  Each MDIO transaction takes 25,600 cycles on a gigahertz
> processor.  It's just too long, IMO, and it looks like this code will
> end up doing up to...10?

Well, it is actually worse than that. From my measurements, 64 cycles
at 2.5 MHz (25.6 usec) is too optimistic. On one Xscale IXP platform,
I get 35 to 40 usec per read. Also, the PHYTER needs six reads for a
Rx and four for a Tx time stamp.

So you are right, it is a very long time to leave interrupts off.

However, not every packet needs a time stamp. The PHY devices that I
know of all are selective. That is, they recognize PTP packets in
hardware and only provide time stamps for those special packets. The
packet rate is not that hight. For example, the "sync" message comes
once every two seconds in PTPv1 and up to ten times per second in
PTPv2.

I have been working on an alternative, which I will post soon. It goes
like this... (comments, please, before I get too far into it!)

* General
   - phy registers itself with net_device { opaque pointer }

   - ts_candidate(skb):
     function to detect likely packets, returns true if
       1. phy_device pointer exists in net_device
       2. data look like PTP, using a BPF

   - work queue:
     1. read out time stamps
     2. match times with queued skbs
     3. deliver skbs with time stamps (or without on timeout)

* Rx path
   - netif_receive_skb:
     if ts_candidate(skb), defer(skb).

* Tx path
   - hook in each MAC driver
   - if ts_candidate(skb), clone and defer(skb).


> I wasn't able to find an example of how you were going to use the
> time-stamp functions you provided.  Could you please go into a little
> more detail about how you intended this to work?

My last PTP series included the PHY stuff, too. There you can see how
it all fits together.

   http://marc.info/?l=linux-netdev&m=127661796627120&w=3


Thanks,
Richard
