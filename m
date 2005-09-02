From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent 2.4.x/2.6.x kernels
Date: Fri, 2 Sep 2005 22:36:56 +0400
Message-ID: <20050902183656.GA16537@yakov.inr.ac.ru>
References: <Pine.LNX.4.61.0509011713240.6083@guppy.limebrokerage.com> <20050901.154300.118239765.davem@davemloft.net> <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750841AbVIBSha@vger.kernel.org>
To: Ion Badulescu <lists@limebrokerage.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> This is where things start going bad. The window starts shrinking from 
> 15340 all the way down to 2355 over the course of 0.3 seconds. Notice the 
> many duplicate acks that serve no purpose

These are not duplicate, TCP_NODELAY sender just starts flooding
tiny segments, and those are normal ACKs acking those segments, note
ACK field is not the same.

> Five minutes later the TCP window is still at 2355,
....
> We are kind of stumped at this point, and it's proving to be a 
> show-stopping bug for our purposes, especially over WAN links that have 
> higher latency (for obvious reasons). Any kind of assistance would be 
> greatly appreciated.

I still do not know how the value of 184 is possible in your case,
I would expect 730 as an absolute possible minumum. I see 9420 (2355*4).
Anyway, ignoring this puzzle, the following patch for 2.4 should help.


--- net/ipv4/tcp_input.c.orig	2003-02-20 20:38:39.000000000 +0300
+++ net/ipv4/tcp_input.c	2005-09-02 22:28:00.845952888 +0400
@@ -343,8 +343,6 @@
 			app_win -= tp->ack.rcv_mss;
 		app_win = max(app_win, 2U*tp->advmss);
 
-		if (!ofo_win)
-			tp->window_clamp = min(tp->window_clamp, app_win);
 		tp->rcv_ssthresh = min(tp->window_clamp, 2U*tp->advmss);
 	}
 }
