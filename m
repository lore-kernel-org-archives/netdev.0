From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 27 Sep 2004 16:04:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927160411.22b44f48.davem@davemloft.net>
References: <20040923161141.4ea9be4c.davem@davemloft.net>
	<Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 18:38:42 -0400 (EDT)
John Heffner <jheffner@psc.edu> wrote:

> On Thu, 23 Sep 2004, David S. Miller wrote:
> 
> >
> > I think I know what may be going on here.
> >
> > Let's say that we even get the congestion window openned up
> > so that we can build 64K TSO frames, that's around 43 or 44
> > 1500 mtu frames.
> >
> > That means as the window fills up, we have to see 44 ACKs
> > before we are able to send the next TSO frame.  Needless to
> > say that breaks ACK clocking completely.
> 
> More specifically, I think it is an interaction with delayed ack (acking
> less than 1 virtual segment), and the small cwnd.  This works for me, but
> I'm not sure that aren't some lurking problems still.

Yes, this is supposed to work around the problem, but:

1) It is a hack :-)

2) It doesn't help Andi's case, and I think I know why.

The reason Andi Kleen didn't see any improvements from limiting
'factor' is that he is using short lived connections.  If you
have a connection up for long enough, this allows the congestion
window to grow and then it doesn't matter.

Something like the following is what I have been talking about.
I am able to reproduce the problem here locally and the following
makes it go away.

Andi, Anton, and niv, can you confirm it does so for you too?

If tcp_clean_rtx_queue() doesn't return DATA
acked then no congestion growth is allowed to occur.  So we only
get a snd_cwnd bump once for every tso_factor frames, that stinks :)

This is not the final fix.  I need to do something like record the
upper-most virtual ACK within a TSO frame so we don't say DATA acked
for dup-acks that happen to fall in the middle of a TSO frame.

===== net/ipv4/tcp_input.c 1.75 vs edited =====
--- 1.75/net/ipv4/tcp_input.c	2004-09-27 12:00:32 -07:00
+++ edited/net/ipv4/tcp_input.c	2004-09-27 15:35:12 -07:00
@@ -2373,8 +2373,12 @@
 		 * discard it as it's confirmed to have arrived at
 		 * the other end.
 		 */
-		if (after(scb->end_seq, tp->snd_una))
+		if (after(scb->end_seq, tp->snd_una)) {
+			if (scb->tso_factor &&
+			    after(tp->snd_una, scb->seq))
+				acked |= FLAG_DATA_ACKED;
 			break;
+		}
 
 		/* Initial outgoing SYN's get put onto the write_queue
 		 * just like anything else we transmit.  It is not
