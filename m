From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Mon, 22 Mar 2010 18:43:06 +0100
Message-ID: <877hp4i76d.fsf@basil.nowhere.org>
References: <alpine.DEB.2.00.1003181245050.23010@router.home>
	<87tysccjrn.fsf@basil.nowhere.org>
	<alpine.DEB.2.00.1003220916170.15360@router.home>
	<20100322163609.GZ20695@one.firstfloor.org>
	<alpine.DEB.2.00.1003221146260.17230@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1003221146260.17230@router.home> (Christoph Lameter's message of "Mon, 22 Mar 2010 11:51:08 -0500 (CDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter <cl@linux-foundation.org> writes:

> On Mon, 22 Mar 2010, Andi Kleen wrote:
>
>> Multicast reliable kernel protocols are somewhat new, I guess one
>> would need to make sure to come up with a clean generic interface
>> for them first.
>
> It has been around for a long time in another OS. I wonder if I should use
> the socket API realized there as a model or come up with something new
> from scratch?

If the other API doesn't have a serious flaw I guess it's better
to aim for a sub/superset at least, to make porting applications easier.

>
> What I have right now is:
>
> 1. Opening a socket

>
>         A. Native PGM
>
>                 fd = socket(AF_INET, SOCK_RDM, IPPROTO_PGM)

RDM = Reliable ? Multicast ? 

>         B. PGM over UDP
>
>                 fd = socket(AF_INET, SOCK_RDM, IPPROTO_UDP)
>
>         C. PGM over SHM (?)
>
>                 fd = socket(AF_UNIX, SOCK_RDM, 0)

Not sure how that should work.

> 3. Sending and receiving
>
>         Use the usual socket read and write operations and the various flavors of waiting
>         for a packet via select, poll, epoll etc.
>
>         Packet sizes are determined by the number of  packets in a single sendmsg() unless

Number of bytes surely?

>         overridden by the RM_SET_MESSAGE_BOUNDARY socket option.

That's unusual to have such a option (except the MTU). What is it good for?

>
> 4.      Transmitter Socket Options
>
>
>         A. Setting the window size / rate.
>
>                 struct pgm_send_window x;
>                 x.RateKbitsPerSec = 56;
>                 x.WindowSizeInMsecs = 60000;
>                 x.WindowSizeinBytes = 10000000;
>
>                 setsockopt(fd, SOCK_RDM, RM_RATE_WINDOW_SIZE, &x, sizeof(x));
>
>                 Default is sending at 56Kbps with a buffer of 10 Megabytes and buffering for a minute.

That's a very large buffer for a socket. It would be better to use the usual
auto shrinking/increasing mechanisms.

>         B. FEC mode
>
>                 struct pgm_fec_info x;
>
>                 x.FECBlocksize = 255;
>                 x.FECProActivePackets = 0;
>                 x.FECGroupSize = 0;
>                 x.fFECOnDemandParityEnabled = 1;
>
>                 setsockopt(fd, SOCK_RDM, RM_FEC_MODE, &x, sizeof(x));

Is that mode really needed?

> /* Socket API structures (established by M$DN) */
> struct pgm_receiver_stats {
>         u64     NumODataPacketsReceived;        /* Number of ODATA (original) sequences */

It's difficult to maintain 64 bit counters on 32bit hosts on all targets.
But I guess it would be ok to only fill in 32bit in this case.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
