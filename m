From: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>
Subject: Re: [PATCH RFC net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Thu, 05 Nov 2015 03:06:41 +0100
Message-ID: <2582037.foOh8SgZpQ@garfield>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com> <1445633413-3532-3-git-send-email-bro.devel+kernel@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1CBC86F1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jonathan Corbet <corbet@lwn.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Yuchung Cheng <ycheng@google.com>,
	Paolo Abeni <pabeni@redhat.com>, Erik Kline <ek@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Daniel Lee <Longinus00@gmail.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Willem de Bruijn <willemb@google.com>,
	=?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	"linux-doc@vger.kernel
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBC86F1@AcuExch.aculab.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, November 02, 2015 09:37:54 AM David Laight wrote:
> From: Bendik R=F8nning Opstad
> > Sent: 23 October 2015 21:50
> > RDB is a mechanism that enables a TCP sender to bundle redundant
> > (already sent) data with TCP packets containing new data. By bundli=
ng
> > (retransmitting) already sent data with each TCP packet containing =
new
> > data, the connection will be more resistant to sporadic packet loss
> > which reduces the application layer latency significantly in conges=
ted
> > scenarios.
>=20
> What sort of traffic flows do you expect this to help?

As mentioned in the cover letter, RDB is aimed at reducing the
latencies for "thin-stream" traffic often produced by
latency-sensitive applications. This blog post describes RDB and the
underlying motivation:
http://mlab.no/blog/2015/10/redundant-data-bundling-in-tcp

=46urther information is available in the links referred to in the blog
post.

> An ssh (or similar) connection will get additional data to send,
> but that sort of data flow needs Nagle in order to reduce the
> number of packets sent.

Whether an application needs to reduce the number of packets sent
depends on the perspective of who you ask. If low latency is of high
priority for the application it may need to increase the number of
packets sent by disabling Nagle to reduce the segments sojourn times
on the sender side.

As for SSH clients, it seems OpenSSH disables Nagle for interactive
sessions.

> OTOH it might benefit from including unacked data if the Nagle
> timer expires.
> Being able to set the Nagle timer on a per-connection basis
> (or maybe using something based on the RTT instead of 2 secs)
> might make packet loss less problematic.

There is no timer for Nagle? The current (Minshall variant)
implementation restricts sending a small segment as long as the
previously transmitted packet was small and is not yet ACKed.

> Data flows that already have Nagle disabled (probably anything that
> isn't command-response and isn't unidirectional bulk data) are
> likely to generate a lot of packets within the RTT.

How many packets such applications need to transmit for optimal
latency varies to a great extent. Packets per RTT is not a very useful
metric in this regard, considering the strict dependency on the RTT.

This is why we propose a dynamic packets in flight limit (DPIFL) that
indirectly relies on the application write frequency, i.e. how often
the application performs write systems calls. This limit is used to
ensure that only applications that write data less frequently than a
certain limit may utilize RDB.

> Resending unacked data will just eat into available network bandwidth
> and could easily make any congestion worse.
>
> I think that means you shouldn't resend data more than once, and/or
> should make sure that the resent data isn't a significant overhead
> on the packet being sent.

It is important to remember what type of traffic flows we are
discussing. The applications RDB is aimed at helping produce
application-limited flows that transmit small amounts of data, both in
terms of payload per packet and packets per second.

Analysis of traces from latency-sensitive applications producing
traffic with thin-stream characteristics show inter-transmission times
ranging from a few ms (typically 20-30 ms on average) to many hundred
ms.
(http://mlab.no/blog/2015/10/redundant-data-bundling-in-tcp/#thin_strea=
ms)

Increasing the amount of transmitted data will certainly contribute to
congestion to some degree, but it is not (necessarily) an unreasonable
trade-off considering the relatively small amounts of data such
applications transmit compared to greedy flows.

RDB does not cause more packets to be sent through the network, as it
uses available "free" space in packets already scheduled for
transmission. With a bundling limitation of only one previous segment,
the bandwidth requirement is doubled - accounting for headers it would
be less.

By increasing the BW requirement for an application that produces
relatively little data, we still end up with a low BW requirement.
The suggested minimum lower bound inter-transmission time is 10 ms,
meaning that when an application writes data more frequently than
every 10 ms (on average) it will not be allowed to utilize RDB.

To what degree RDB affects competing traffic will of course depend on
the link capacity and the number of simultaneous flows utilizing RDB.
We have performed tests to asses how RDB affects competing traffic. In
one of the test scenarios, 10 RDB-enabled thin streams and 10 regular
TCP thin streams compete against 5 greedy TCP flows over a shared
bottleneck limited to 5Mbit/s. The results from this test show that by
only bundling one previous segment with each packet (segment size: 120
bytes), the effect on the the competing thin-stream traffic is modest.
(http://mlab.no/blog/2015/10/redundant-data-bundling-in-tcp/#latency_te=
st_with_cross_traffic).

Also relevant to the discussion is the paper "Reducing web latency:
the virtue of gentle aggression, (2013)", and one of the presented
mechanisms (called Proactive) which applies redundancy by transmitting
every packet twice. While doubling the bandwidth requirements when
using Proactive, their measurements show negligible effect on the
baseline traffic because, as they explain, the traffic utilizing the
mechanism (Web service traffic in their case) is only a small amount
of the total traffic passing through their servers.

While RDB and the Proactive mechanism have slightly different
approaches, they aim at solving the same basic problem; the increased
latencies caused by the need for normal retransmissions. By
proactively (re)transmitting redundant data they are able to avoid the
need for normal retransmissions to a great extent, which reduces
application layer latency by alleviating head-of-line blocking on the
receiver.

An important property of RDB is that by only using packets already
scheduled for transmission, a limit is naturally imposed when severe
congestion occurs. As soon as loss is detected, resulting in a
reduction of the CWND (i.e. becomes network limited), new data from
the application will be appended to the SKB in the output queue
containing the newest (unsent) data. Depending on the rate at which the
application produces data and the level of congestion (the size of the
CWND), the new data from the application will eventually fill up the
SKBs such that skb->len >=3D MSS. The result is that there is no "free"
space available to bundle redundant data, effectively disabling RDB
and enforcing a behavior equal to regular TCP.

Bendik

