From: John Heffner <jheffner@psc.edu>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 27 Sep 2004 18:38:42 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu>
References: <20040923161141.4ea9be4c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <ak@suse.de>, <niv@us.ibm.com>, <andy.grover@gmail.com>,
        <anton@samba.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040923161141.4ea9be4c.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2004, David S. Miller wrote:

>
> I think I know what may be going on here.
>
> Let's say that we even get the congestion window openned up
> so that we can build 64K TSO frames, that's around 43 or 44
> 1500 mtu frames.
>
> That means as the window fills up, we have to see 44 ACKs
> before we are able to send the next TSO frame.  Needless to
> say that breaks ACK clocking completely.


More specifically, I think it is an interaction with delayed ack (acking
less than 1 virtual segment), and the small cwnd.  This works for me, but
I'm not sure that aren't some lurking problems still.

===== net/ipv4/tcp_output.c 1.58 vs edited =====
--- 1.58/net/ipv4/tcp_output.c	2004-09-14 00:39:17 -04:00
+++ edited/net/ipv4/tcp_output.c	2004-09-27 18:26:43 -04:00
@@ -642,8 +657,8 @@
 		 * do not exceed congestion window.
 		 */
 		factor = large_mss / mss_now;
-		if (factor > tp->snd_cwnd)
-			factor = tp->snd_cwnd;
+		if (factor > (tp->snd_cwnd>>3))
+			factor = max(tp->snd_cwnd>>3, 1);

 		tp->mss_cache = mss_now * factor;
 	}

  -John
