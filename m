From: Marc Herbert <marc.herbert@free.fr>
Subject: Re: TcpOutSegs way too optimistic (netstat -s)
Date: Sat, 15 May 2004 02:51:39 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405150217020.9107@fcat>
References: <Pine.LNX.4.58.0405150007090.8193@fcat> <Pine.LNX.4.58.0405150027230.8281@fcat>
 <40A54D73.2050108@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <40A54D73.2050108@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 14 May 2004, Nivedita Singhvi wrote:

> I'm not sure I agree with this patch.  Ideally, every layer should coun=
t
> what it sent out, and what it drops. If a lower layer drops the segment=
/
> packet for any reason, that is the responsibility of the lower layer to
> count.  This includes the qdisc layer (a topic I will come back to).

The interface here between these two layers is not really "dropping"
but rather "blocking".

Let's have a look at the main sending loop "tcp_write_xmit()". When
the qdisc and thus tcp_transmit_skb() returns a error (most common
cause:  qdisc full), the loop just breaks and exits WITHOUT=A0advancing
the "send_head".

In brief, what happened=A0? TCP tried to give a packet to the qdisc,
which refused it. So TCP keeps it until a better time.  No packet has
disappeared, no packet has moved. Please tell me what has been "sent"
or "dropped" in this case. This TCP/IP interface really looks much
more like a "blocking" pipe rather than like some "dropping" IP
router.

The retransmission code is very similar: when the qdisc errors, the
retransmission loop is broken, the status of the tentatively
retransmitted packet is NOT updated to "retransmitted", so it will be
the first packet to be retransmitted on next pass (please confirm
this).
And BTW, not any "TcpRetransWhatever" counter is incremented in this
case (so there is at least some inconsistency here).

If the IP stack was silently dropping packets just like a external
IP=A0router, things would be different. TCP would then not be able to
tell the difference between its local IP=A0stack and a further router, a
packet would have disappeared indeed, TCP would skip to the next
packet in the flow and finally receive a SACK / a timeout, etc. But
this is not what happens.


The point of view of the qdisc is quite different, because the qdisc
has not only TCP as a client. But my patch is for TCP.
