From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] skb pcount with MTU discovery
Date: Fri, 1 Apr 2005 16:22:59 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0504011612140.18380@dexter.psc.edu>
References: <Pine.LNX.4.58.0504011340510.17051@dexter.psc.edu>
 <20050401131045.4e558f65.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050401131045.4e558f65.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Apr 2005, David S. Miller wrote:

> On Fri, 1 Apr 2005 16:05:49 -0500 (EST)
> John Heffner <jheffner@psc.edu> wrote:
>
> > The problem is that when doing MTU discovery, the too-large segments in
> > the write queue will be calculated as having a pcount of >1.  When
> > tcp_write_xmit() is trying to send, tcp_snd_test() fails the cwnd test
> > when pcount > cwnd.
> >
> > The segments are eventually transmitted one at a time by keepalive, but
> > this can take a long time.
> >
> > This patch checks if TSO is enabled when setting pcount.
>
> Why isn't the MSS properly updated at this point in time?
> If it were, the pcount setting would do the right thing.
>
> That's how this code is supposed to work.

The problem occurs when TSO is disabled.

Common case, start out with mss of 8948.  Send 2 segments; neither are
acknowledged, and we receive an ICMP can't fragment indicating a pmtu of
1500 so mss is set down to 1448.  Now tcp_set_skb_tso_segs() sets tso_segs
to 6, so tcp_snd_test thinks we are doing TSO and will send the full 6
mss, and fails the cwnd test since cwnd == 2.

  -John
