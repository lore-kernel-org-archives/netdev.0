From: Adrian Chadd <adrian@freebsd.org>
Subject: Re: BQL crap and wireless
Date: Tue, 30 Aug 2011 09:44:56 +0800
Message-ID: <CAJ-Vmom_EwR31Z6r4VpSiKTwE+YXwmRwtwurzr5VUX6nnC67fg@mail.gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
	<CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
	<CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com>
	<4E5C3B47.1050809@freedesktop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Tom Herbert <therbert@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Matt Smith <smithm@qca.qualcomm.com>,
	Kevin Hayes <hayes@qca.qualcomm.com>,
	Derek Smithies <derek@indranet.co.nz>, netdev@vger.kernel.org
To: Jim Gettys <jg@freedesktop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:64918 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881Ab1H3Bo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 21:44:57 -0400
In-Reply-To: <4E5C3B47.1050809@freedesktop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30 August 2011 09:22, Jim Gettys <jg@freedesktop.org> wrote:

Note: I'm knee deep in the aggregation TX/RX path at the present time
- I'm porting the atheros 802.11n TX aggregation code to FreeBSD.

> Computing the buffering in bytes is better than in packets; but since on
> wireless multicast/broadcast is transmitted at a radically different
> rate than other packets, I expect something based on time is really the
> long term solution; and only the driver has any idea how long a packet
> of a given flavour will likely take to transmit.

And the driver (hopefully!) can find out how long the packet -did-
take to transmit.

There are a bunch of different reasons for why the packet isn't
transmitting or why it can take so long. If (say) an aggregate has 10
hardware (long, short) retries at a high MCS rate, and then 10
software retries, that's up to 100 attempts at transmitting the
sub-frames in some way. It may also involve 10 attempts at an RTS
exchange. But it may also be 10 attempts at transmitting the -whole-
frame. In the case of a long aggregate (say the upper bounds of 4ms,
easily achievable when lower MCS rates are selected), this can take a
long time.

I'm occasionally seeing this in my testing, where the block-ack isn't
seen by the sender. The whole aggregate frame is thus retransmitted in
its entirety. This causes occasional bumps in the testing latency. The
obvious solution is to not form such large aggregates at lower MCS
rates but even single events have an impact on latency.

I'm not at the point yet where I can start tinkering with rate control
and queue management in this way but the idea of asking the rate
control code to manage per-node and overall airtime has crossed my
mind. Ie, the rate control code can see how successful transmissions
are to a given node (at given streams, rates, antenna configurations,
etc) and then enforce aggregate size and retransmission limits there.
Since a decision for any given node will affect the latency on all
subsequent nodes, it makes sense for the rate control code to keep a
global idea of the airtime involved as well as the (current) per-node
logic.

2c, which'll be more when I work the 11n TX A-MPDU kinks out in the
FreeBSD driver,


Adrian
