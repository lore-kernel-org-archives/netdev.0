From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Mon, 27 Aug 2007 18:02:47 +0200
Message-ID: <200708271802.48691.ossthema@de.ibm.com>
References: <46CF127D.1090609@katalix.com> <20070826.185815.93042514.davem@davemloft.net> <46D2F301.7050105@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, akepner@sgi.com,
	netdev@vger.kernel.org, raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	meder@de.ibm.com, tklein@de.ibm.com, stefan.roscher@de.ibm.com
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:6458 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759348AbXH0QDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 12:03:18 -0400
In-Reply-To: <46D2F301.7050105@katalix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 27 August 2007 17:51, James Chapman wrote:

> In the second half of my previous reply (which seems to have been 
> deleted), I suggest a way to avoid this problem without using hardware 
> interrupt mitigation / coalescing. Original text is quoted below.
> 
>  >> I've seen the same and I'm suggesting that the NAPI driver keeps
>  >> itself in polled mode for N polls or M jiffies after it sees
>  >> workdone=0. This has always worked for me in packet forwarding
>  >> scenarios to maximize packets/sec and minimize latency.
> 
> To implement this, there's no need for timers, hrtimers or generic NAPI 
> support that others have suggested. A driver's poll() would set an 
> internal flag and record the current jiffies value when finding 
> workdone=0 rather than doing an immediate napi_complete(). Early in 
> poll() it would test this flag and if set, do a low-cost test to see if 
> it had any work to do. If no work, it would check the saved jiffies 
> value and do the napi_complete() only if no work has been done for a 
> configurable number of jiffies. This keeps interrupts disabled longer at 
> the expense of many more calls to poll() where no work is done. So 
> critical to this scheme is modifying the driver's poll() to fastpath the 
> case of having no work to do while waiting for its local jiffy count to 
> expire.
> 

The problem I see with this approach is that the time that passes between
two jiffies might be too long for 10G ethernet adapters. (I tried to implement
a timer based approach with usual timers and the result was a disaster).
HW interrupts / or HP timer avoid the jiffy problem as they activate softIRQs
as soon as you call netif_rx_schedule. 
