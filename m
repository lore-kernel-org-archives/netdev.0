From: David Miller <davem@davemloft.net>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Wed, 06 Jan 2010 00:23:28 -0800 (PST)
Message-ID: <20100106.002328.141253811.davem@davemloft.net>
References: <20100105.163911.10233438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, ilpo.jarvinen@helsinki.fi
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48676
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754944Ab0AFIXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 03:23:23 -0500
In-Reply-To: <20100105.163911.10233438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 05 Jan 2010 16:39:11 -0800 (PST)

> To make a long story short, there are still some Windows 2000
> machines out there emitting BSD 4.2 style keepalives (one garbage
> byte instead of an empty out-of-window probe frame).
> 
> We don't ACK these because of how tcp_sequence() sees ->end_seq
> as being equal to ->rcv_wup
> 
> But we can't change tcp_sequence() to reject these frames, because if
> we do then we end up mishandling connection attempts (SYN, SYN+ACK)
> and retransmits of such.

After some digging I found commit:

commit 585d51805443d6caf10d468366bc6567e12cf090
Author: davem <davem>
Date:   Tue Jan 30 01:38:22 2001 +0000

    Make tcp_sequence check more loose, so that
    we respect control flags in packets which are not
    out-of-window after truncating to the current window.
    From Alexey.

in the netdev-vger-cvs tree, which is how we arrived at the
current implementation of tcp_sequence().

The old code looks like (ifdef'd sections removed and code
reformatted for brevity):

static int __tcp_sequence(struct tcp_opt *tp, u32 seq, u32 end_seq)
{
	u32 end_window = tp->rcv_wup + tp->rcv_wnd;
	u32 rcv_wnd = tcp_receive_window(tp);

	if (rcv_wnd && after(end_seq, tp->rcv_nxt) &&
	    before(seq, end_window))
		return 1;
	if (seq != end_window)
		return 0;
	return (seq == end_seq);
}
extern __inline__ int tcp_sequence(struct tcp_opt *tp, u32 seq, u32 end_seq, int rst)
{
	u32 rcv_wnd = tcp_receive_window(tp);
	if (seq == tp->rcv_nxt)
		return (rcv_wnd || (end_seq == seq) || rst);
	return __tcp_sequence(tp, seq, end_seq);
}

Whereas tcp_sequence() is now:

static inline int tcp_sequence(struct tcp_sock *tp, u32 seq, u32 end_seq)
{
	return	!before(end_seq, tp->rcv_wup) &&
		!after(seq, tp->rcv_nxt + tcp_receive_window(tp));
}

The key element (taken from FreeBSD, as per current comments) is to
allow sequences using tp->rcv_wup as the window edge so that we can
accept things like resets even when our delayed ACK has caused the
sender to not advance his snd.una yet.

That's fine.

So everywhere you see tp->rcv_nxt in the old code, it should correspond
to things using tp->rcv_wup in the new code.

Would the old code cause us to properly ACK the zero window probes
that have the garbage byte?  It seems it would.

Assuming we still have a zero window being advertised when we receive
the probe:

1) seq is one byte behind edge of the window so the
   seq == tp->rcv_nxt check will not pass, therefore
   we get to __tcp_sequence()

2) rcv_wnd is zero, so first check there does not pass

3) seq != end_window (it's something like tp->rcv_wup - 1) so
   we return 0

and thus end up in the code (two functions up) which emits the ACK.

However, we can't just change

		!before(end_seq, tp->rcv_wup) &&

to be:

		after(end_seq, tp->rcv_wup) &&

As that would even reject the first bare ACK we receive
in the SYN, SYN+ACK, ACK sequence.  (where seq == end_seq and
end_seq == tp->rcv_wup, which would be rejected by
after(end_seq, tp->rcv_wup)).

Special casing the seq == end_seq == tp->rcv_wup case using
something like:

		(after(end_seq, tp->rcv_wup) ||
		 (end_seq == tp->rcv_wup && seq == end_seq)) &&

might work, but I'm not confident that's exactly what we want at the
moment, as it partially defeats what this code is trying to do (let us
accept URG/FIN/RST after seq and end_seq are truncated to the window).
