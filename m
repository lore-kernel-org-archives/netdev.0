From: Martin Pool <mbp@samba.org>
Subject: linux 2.2 TCP_CORK FIN_WAIT1 reproducible bug
Date: Fri, 6 Sep 2002 17:11:08 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020906071108.GC26914@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: alan@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I think I've found a bug in 2.2's TCP stack, in which sockets can get
into FIN_WAIT1 with no timer and stay stuck indefinitely.

Steps to reproduce seem to be basically as follows:

>From a client running 2.2.16, open a TCP socket to a server.  Set
TCP_CORK, write some data, exit.  The exit ought to implicitly close
the socket, but instead the socket goes into FIN_WAIT1 and never
closes properly.

netstat on the client shows 

tcp        0     44 192.168.0.146:1146     192.168.0.209:4200      FIN_WAIT1   off (0.00/0/0)

As far as I can make out, this is a state that should never occur: if
there is data still in the send queue, then there should always be a
timer running to retransmit it and/or probe the remote machine for
more window space.  Also, I would think that in FIN_WAIT1 there ought
to be a timer that will cause the FIN to be retransmitted in case it
was lost.

On the server:

ngoh@build04.foo.com $ netstat -ton | grep 4200
tcp        0      0 192.168.0.209:4200      192.168.0.146:1146     ESTABLISHED off (0.00/0/0)

So it looks to me like the server just does not see a FIN from the
client.  The server application (distccd) is just blocked in read(),
waiting for more data or EOF.

tcpdump seems to show that the client just never sends the FIN

22:16:21.690340 build03.foo.com.1146 > build04.foo.com.4200: S 1541177197:1541177197(0) win 32120 <mss 1460,sackOK,timestamp 1005928219[|tcp]> (DF)
22:16:21.690537 build04.foo.com.4200 > build03.foo.com.1146: S 1546103786:1546103786(0) ack 1541177198 win 32120 <mss 1460,sackOK,timestamp 1005835757[|tcp]> (DF)
22:16:21.690593 build03.foo.com.1146 > build04.foo.com.4200: . ack 1 win 32120 <nop,nop,timestamp 1005928219 1005835757> (DF)
22:16:21.691329 build03.foo.com.1146 > build04.foo.com.4200: P 1:1448(1447) ack 1 win 32120 <nop,nop,timestamp 1005928219 1005835757> (DF)
22:16:21.691822 build04.foo.com.4200 > build03.foo.com.1146: . ack 1448 win 31856 <nop,nop,timestamp 1005835757 1005928219> (DF)

If the TCP_CORK is never inserted, or if the application removes the
cork before exiting, then things work properly.  Also, this works
properly on 2.4.18.

It seems that the problem is not to do with firewalling troubles or
packet loss.

This was originally observed by Hien D. Ngo on 2.2.16 and 2.2.19 while
trying out my program distcc on some Red Hat 6.2 machines.  All of the
gory details are available here:

  http://lists.samba.org/pipermail/distcc/2002q3/thread.html

I don't have any 2.2 machines myself, but if necessary I can install
it and try to reproduce the problem.

So I would guess that there is some kind of bug in tcp_snd_test()'s
logic for deciding whether to send a packet.  The comment there claims
to handle this case of close() with cork in place, but it seems that
it is not.  (I don't really know if it's that function, it could be
elsewhere.)

The final statement is 

	return ((!tail || nagle_check || skb_tailroom(skb) < 32) &&
		((tcp_packets_in_flight(tp) < tp->snd_cwnd) ||
		 (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)) &&
		!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd) &&
		tp->retransmits == 0);

As far as I can see all of these are true, so either my assumptions
are wrong, or this function is not itself the problem.

We're OK on the first, because nagle_check will be 1.  We're OK on the
second because presumably TCPCB_FLAG_FIN is set.  We're OK on the
third because there's  plenty of space in the window.  And we should
be OK on the fourth because the packet hasn't been retransmitted.

I wonder if the transmit queue actually has a small data packet ahead
of the FIN packet, and the data packet is not being sent and therefore
jamming up the works?  

If that was true, and they somehow did not get combined, then...
flags for that packet would not have FIN, and the length would be less
than the mss_cache, so nagle_check would become 0.  It wouldn't be the
tail; the nagle check would be false, and it wouldn't be nearly full.
So tcp_snd_test() would return 0.

Anyhow, I hope you find it an interesting bug.  Please cc me on
replies and let me know if there's anything I can do to help.

(Incidentally, distcc is pretty cool if you ever compile large
programs, like, say, the kernel.  On my 3 PCs it builds 2.6 times
faster, and it's pretty trivial to install.  Try it, you'll like it.)

-- 
Martin 
