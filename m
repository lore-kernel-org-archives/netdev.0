From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 23 Sep 2004 16:11:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923161141.4ea9be4c.davem@davemloft.net>
References: <20040920063012.GL2825@krispykreme>
	<20040920203021.GD4242@wotan.suse.de>
	<20040921155835.18aee381.davem@davemloft.net>
	<20040922140000.GD27432@wotan.suse.de>
	<20040922111209.7887df53.davem@davemloft.net>
	<20040922195515.GA2619@wotan.suse.de>
	<c0a09e5c04092213126ba5f29d@mail.gmail.com>
	<20040922133906.7d57ef49.davem@davemloft.net>
	<20040922220628.GC2619@wotan.suse.de>
	<20040922152535.7bc81c8a.davem@davemloft.net>
	<20040922224732.GD2619@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>, niv@us.ibm.com
In-Reply-To: <20040922224732.GD2619@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I think I know what may be going on here.

Let's say that we even get the congestion window openned up
so that we can build 64K TSO frames, that's around 43 or 44
1500 mtu frames.

That means as the window fills up, we have to see 44 ACKs
before we are able to send the next TSO frame.  Needless to
say that breaks ACK clocking completely.

And given that, getting 22MB/sec with TSO enabled is
actually an impressive feat.

I can't think of a fix I'm completely happy with.  We could
limit TSO to something like 2 or 4 normal MSS frames, but
that negates much of the gain from TSO.  But something like
this is necessary to keep the pipe full.

Anyways, for testing, something like the patch below.  If things
still stink a bit, try using a limit of "2" in this patch instead
of "4".

===== net/ipv4/tcp_output.c 1.58 vs edited =====
--- 1.58/net/ipv4/tcp_output.c	2004-09-13 21:39:17 -07:00
+++ edited/net/ipv4/tcp_output.c	2004-09-23 15:51:51 -07:00
@@ -645,6 +645,12 @@
 		if (factor > tp->snd_cwnd)
 			factor = tp->snd_cwnd;
 
+		/* Also, do not let it grow more than 4 frames
+		 * so that ACK clocking continues to work.
+		 */
+		if (factor > 4)
+			factor = 4;
+
 		tp->mss_cache = mss_now * factor;
 	}
 
