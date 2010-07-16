From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/4] phylib: Allow reading and writing a mii bus from
 atomic context.
Date: Fri, 16 Jul 2010 13:25:47 +0200
Message-ID: <20100716112544.GA2996@riccoc20.at.omicron.at>
References: <cover.1278307573.git.richard.cochran@omicron.at>
 <a06cf09ed5096bf8f9434d90828adfa70586e936.1278307573.git.richard.cochran@omicron.at>
 <AANLkTikEF3B-0JGvqosY5jMaChbpYctOmKW1jJKOWsQE@mail.gmail.com>
 <20100707071832.GA2816@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57446 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965028Ab0GPLZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 07:25:51 -0400
Received: by bwz1 with SMTP id 1so1154832bwz.19
        for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 04:25:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100707071832.GA2816@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 07, 2010 at 09:18:32AM +0200, Richard Cochran wrote:
> Consider the receive path:
> 
> 1. PTP Packet passed through PHY. PHY recognizes it and stores a time
>    stamp along with some UID from the packet.
> 
> 2. Napi calls the MAC driver's poll function.
> 
> 3. MAC driver acquires packet. At this point, if we want to have a
>    hardware time stamp, we must read it out over the mdio bus, before
>    handing the packet over to the stack via netif_receive_skb().
> 
> If we decide to defer the packet delivery (in step 3), we have to know
> whether the PHY will have a time stamp for this packet. The only way
> to do this is to compare the UIDs, but that requires reading it over
> the mdio bus.

(Forwarding Andy's message to me that was missing a CC to the list)

On Thu, Jul 08, 2010 at 03:40:41PM -0500, Andy Fleming wrote:

Wait, is the intent for this mdio read to be done for *every* packet?
MDIO is spec'ed out to go up to 2.5MHz.  Each transaction takes 64
cycles.  And I see that reading the timestamp from the PHY you
submitted support for takes at *least* 2 transactions.  The fastest
you can process packets would then be under 20,000 packets per second.
Even on a 100Mb link with full-sized packets, you would be 40% done
receiving the next packet before you had passed the packet on to the
stack.  Each MDIO transaction takes 25,600 cycles on a gigahertz
processor.  It's just too long, IMO, and it looks like this code will
end up doing up to...10?

I wasn't able to find an example of how you were going to use the
time-stamp functions you provided.  Could you please go into a little
more detail about how you intended this to work?
