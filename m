From: "Scott M. Ferris" <sferris@acm.org>
Subject: TSO prevents cwnd growth on 2.6 kernels
Date: Fri, 25 Mar 2005 12:18:04 -0600
Message-ID: <20050325181804.GA11633@visi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

TSO still has problems in 2.6.12-rc1. 

tcp_ack() will only increase the congestion window if
(tcp_packets_in_flight() >= tp->snd_cwnd), which prevents cwnd from
growing when cwnd is larger than the flight size.

When TSO is in use, tcp_write_xmit() often won't be willing to send
enough to increase packets_in_flight all the way to tp->snd_cwnd,
because tcp_snd_test() does an all-or-nothing check to see if all of
tcp_skb_pcount(skb) can be sent without overflowing snd_cwnd.  Unless
the pcount happens to perfectly fill the cwnd, returning acks won't be
able to increase cwnd, because tcp_packets_in_flight() < tp->snd_cwnd.

In the particular case I was looking it, it resulted in some really
pathological behavior following packet loss and retransmission.  After
the last lost packet was retransmitted, both cwnd and packets_out were
1.  When the ack for the final retransmission arrived, cwnd was
incremented to 2, and packets_in_flight dropped to 0.

Because TSO was on, the head skb on the send queue had a pcount of 45.
This prevented tcp_write_xmit() from sending anything at all, because
tcp_snd_test() can't fit 45 packets into a cwnd of 2.  Because
tcp_write_xmit() failed, a timer was scheduled for a zero-window
probe.

The probe timer eventually went off, and tcp_write_wakeup() noticed
that in fact the window was not closed, and sent 1 data packet.  The
ack for that 1 packet can't increment cwnd, because the flight size of
1 is still less than cwnd of 2.  This began a sequence of 43 window
probes being sent by the timer, each of which peeled one packet off of
the head skb, slowly dropping it's tcp_skb_pcount().  Eventually the
pcount reached 2, and tcp_write_xmit() was finally willing to send the
skb and increase tcp_packets_in_flight() all the way to cwnd.  This
allowed an ack to finally increment cwnd to 3.

The problem then repeated, because the next skb in the send queue also
has a pcount of 45, which won't fit in a cwnd of 3, beginning another
long sequence of window probes which slowly drained the head skb's
pcount to 3, at which point tcp_write_xmit() was finally willing to
send some packets, which got acked, bringing cwnd to 4.

This just kept happening over and over again, giving pathetic
throughput until the cwnd finally grew larger than the typical
tcp_skb_pcount() values in the send queue.

tcp_write_xmit() really needs to be willing to increase
tcp_packets_in_flight() high enough that tcp_ack() will allow the
congestion window to grow, even when TSO is being used, otherwise
there may be a dramatic reduction in the cwnd growth rate.

I can easily test a patch if someone has time to create one.

-- 
Scott M. Ferris,
sferris@acm.org 
