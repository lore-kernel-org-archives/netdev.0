From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: high latency with TCP connections
Date: Mon, 4 Sep 2006 13:10:28 +0400
Message-ID: <20060904091028.GB19793@ms2.inr.ac.ru>
References: <20060831151456.12a4e080@dxpl.pdx.osdl.net> <20060831.154428.35684218.davem@davemloft.net> <20060831232923.GA10036@ms2.inr.ac.ru> <20060831.165701.104033558.davem@davemloft.net> <20060901094715.GB13855@ms2.inr.ac.ru> <20060901110038.GA3651@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:45031 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751222AbWIDJLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 05:11:37 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060901110038.GA3651@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> At least for slow start it is safe, but experiments with atcp for
> netchannels showed that it is better not to send excessive number of
> acks when slow start is over,

If this thing is done from tcp_cleanup_rbuf(), it should not affect
performance too much.

Note, that with ABC and another pathological cases, which do not allow
to send more than a fixed amount of segments [ we have lots of them,
f.e. sending tiny segments, we can hit sndbuf limit ], we deal with case,
when slow start is _never_ over.


>				 instead we can introduce some tricky
> ack avoidance scheme and ack at least 2-3-4 packets or full MSS instead
> of two mss-sized frames.

One smart scheme was used at some stage (2000, probably never merged
in this form to mainstream): tcp counted amount of unacked small segments
in ack.rcv_small and kept threshold in ack.rcv_thresh.

+
+       /* If we ever saw N>1 small segments from peer, it has
+        * enough of send buffer to send N packets and does not nagle.
+        * Hence, we may delay acks more aggresively.
+        */
+       if (tp->ack.rcv_small > tp->ack.rcv_thresh+1)
+               tp->ack.rcv_thresh = tp->ack.rcv_small-1;
+       tp->ack.rcv_small = 0;


That was too much of trouble for such simple thing. So, eventually
it was replaced with much dumber scheme. Look at current tcp_cleanup_rbuf().
It forces ACK, each time when it sees, that some small segment was received.
It survived for 6 years, so that I guess it did not hurt anybody. :-)

What I would suggest to do now, is to replace:

	(copied > 0 &&
	(icsk->icsk_ack.pending & ICSK_ACK_PUSHED) &&
	!icsk->icsk_ack.pingpong &&
	!atomic_read(&sk->sk_rmem_alloc)))
		time_to_ack = 1;

with:

	(copied > 0 &&
	(icsk->icsk_ack.unacked > 1 ||
	(icsk->icsk_ack.pending & ICSK_ACK_PUSHED) && !icsk->icsk_ack.pingpong) &&
	!atomic_read(&sk->sk_rmem_alloc)))
		time_to_ack = 1;

I would not hesitate even a minute, if variable "unacked" could be caluclated
using some existing state variables.

Alexey

-- 
VGER BF report: U 0.500017
