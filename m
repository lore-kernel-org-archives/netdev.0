From: Rick Jones <rick.jones2@hp.com>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Fri, 21 Jan 2005 14:48:08 -0800
Message-ID: <41F186A8.9030805@hp.com>
References: <41F1516D.5010101@hp.com> <200501211358.53783.jdmason@us.ibm.com>	<41F163AD.5070400@hp.com>	<20050121124441.76cbbfb9.davem@davemloft.net>	<41F17B7E.2020002@hp.com> <20050121141820.7d59a2d1.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050121141820.7d59a2d1.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 21 Jan 2005 14:00:30 -0800 Rick Jones <rick.jones2@hp.com> wrote:
> 
> 
>> Indeed, it waited for the ACK 4335, but then shouldn't it have emitted
>> 4344+1448 or 5792 bytes or perhaps 7240 (since there were two ACKs?
> 
> 
> The tcp_tso_win_divisor calculation occurs on the congestion window at the 
> time of the user request, not at the time of the ACK.

Ah, _that_ explains why in so many of my traces it stays at one value for sooo 
long.  And in some places it seemed to jump by fairly large quantities. I 
thought it was related to the window size, but in a netperf TCP_STREAM test, 
unless the sender sets the -m option, it is set based on the getsockopt() that 
follows the setsockopt() from the -s, and since -S was 128K, and since Linux 
doubles that on the getsockopt().... that explains the O(200K) bit before > 1448 
byte sends when the divisor was set to 8.

> That's an interesting observation actually, thanks for showing it.

My pleasure.

> It means that ideally we might want to try and find a way to either:
> 
> 1) defer the TSO window size calculation to some later moment, ie. at
> tcp_write_xmit() time
> 
> 2) use an optimistic TSO size calculation at the same moment we compute it
> now, and later if it is found to be too aggressive we chop up the TSO frame
> and resegment the transmit queue to accomodate
> 
> Neither is easy to implement as far as I can tell, but it should fix all the
> problems IBM and others are trying to work around by setting the
> tcp_tso_win_divisor really small.

Indeed, it seems that one would want to decide about TSO when one is about to 
transmit, not when the user does a send since otherwise, you penalize users 
doing larger sends.  Someone doing say a sendfile() of a large file would be 
pretty much precluded from getting benefit from TSO the way things are now right?

(There is a netperf TCP_SENDFILE test, but it defaults the send size to the 
socket buffer size just like TCP_STREAM)

And I suspect that is the case for some of the (un)spoken workloads of interest 
among the system vendors.  That's not to say that we still won't have incentive 
to set tcp_tso_win_divisor (shouldn't that really be tcp_tso_cwnd_divisor?) to 1 
:)  I suspect we will still want that initial "4380" cwnd bytes to be a single 
TSO transmission... every cycle's sacred, every cycle's great... :)

rick jones

BTW, has the whole "reply-to" question already been thrashed about on this list? 
  Is it an open or closed list?  I ask because I keep getting two copies of 
everyone's replies - one to me, one to the list... just a nit...
