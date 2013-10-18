From: Jimmy PERCHET <jimmy.perchet@parrot.com>
Subject: Re: [PATCH RFC 0/5] net:stmmac: fix jumbo frames handling and optimisation
Date: Fri, 18 Oct 2013 18:24:04 +0200
Message-ID: <526160A4.7030507@parrot.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com> <525EF8FF.2010206@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Jimmy Perchet <jimmy.perchet@parrot.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co202.xi-lite.net ([149.6.83.202]:32957 "EHLO co202.xi-lite.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752525Ab3JRQYF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 12:24:05 -0400
In-Reply-To: <525EF8FF.2010206@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Peppe,

Thanks for your concern,

I add some details :

> I tested jumbo on chips w/o enhanced some time ago, so welcome further
> tests as you did (maybe on new chips).

I'm working with 3.71a version, in 2KiB + 2KiB configuration.

>> *(1/5) Threshold dma mode is needed on rx path if jumbo frames are expected.
> 
> hmm, this depends on the HW. In the past I used HW with a Fifo that is
> 16KiB for rx buffers and 8KiB for tx.

I used rxfifo_over_2048 flag in order to guess if threshold mode is necessary.


>> *(3/5) On low speed link (10MBit/s), some TX descriptors can remain dirty
>> if the tx coalescence timer expires before they were treated. Re-arm timer
>> in this case.
> 
> hmm not clear to me, let me look at the patch. I hope the link should
> not impact... never seen on my side.
> 
Tx coalescence default parameters are : one interrupt every 64 descriptors
and 40ms timer.
Let say, one is transferring 63 jumbo frames(9KiB) over 10Mb/s link:
* 63<64 there is no interrupt.
* when the timer expires, only 5 descriptors have to be cleaned.(40ms@10Mb/s)
* at the end, 58 dirty descriptors remain.
Normally, they will be cleaned at the next transfer. The real problem appears
if the socket's "wmem" is too small. The transfer stall :
*Socket is waiting for buffer's cleanup before performing a new transfer.
*Driver is waiting for new transfer before performing cleanup.
Re-arming the timer allows to continue cleanup, thus the socket's
wake-up threshold will be reach.


Best Regards,
Jimmy
