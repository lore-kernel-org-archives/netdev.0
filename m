From: "David S. Miller" <davem@davemloft.net>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Fri, 21 Jan 2005 14:18:20 -0800
Message-ID: <20050121141820.7d59a2d1.davem@davemloft.net>
References: <41F1516D.5010101@hp.com>
	<200501211358.53783.jdmason@us.ibm.com>
	<41F163AD.5070400@hp.com>
	<20050121124441.76cbbfb9.davem@davemloft.net>
	<41F17B7E.2020002@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <41F17B7E.2020002@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 Jan 2005 14:00:30 -0800
Rick Jones <rick.jones2@hp.com> wrote:

> Indeed, it waited for the ACK 4335, but then shouldn't it have emitted 4344+1448 or 5792 bytes or perhaps 7240 (since there were two 
> ACKs?

The tcp_tso_win_divisor calculation occurs on the congestion window at the
time of the user request, not at the time of the ACK.

That's an interesting observation actually, thanks for showing it.

It means that ideally we might want to try and find a way to either:

1) defer the TSO window size calculation to some later moment, ie.
   at tcp_write_xmit() time

2) use an optimistic TSO size calculation at the same moment we compute
   it now, and later if it is found to be too aggressive we chop up the
   TSO frame and resegment the transmit queue to accomodate

Neither is easy to implement as far as I can tell, but it should fix
all the problems IBM and others are trying to work around by setting
the tcp_tso_win_divisor really small.
