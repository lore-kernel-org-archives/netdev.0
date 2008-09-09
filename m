From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
	feature-negotiation patches
Date: Tue, 9 Sep 2008 10:09:11 +0200
Message-ID: <20080909080911.GA9176@gerrit.erg.abdn.ac.uk>
References: <20080902.230655.89921076.davem@davemloft.net> <20080903081839.GA9001@gerrit.erg.abdn.ac.uk> <20080904061511.GA30756@gerrit.erg.abdn.ac.uk> <20080908.173250.204419507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:59976 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753596AbYIIIJb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 04:09:31 -0400
Content-Disposition: inline
In-Reply-To: <20080908.173250.204419507.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > This is an update with regard to Wei's comments. I have re-synched 
| > 
| > 	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[subtree `dccp']
| > 	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=shortlog;h=dccp
| > 
| > Also did some testing with a client that only supports CCID 2/3 talking to a client supporting
| > CCID 2/3/4. They could still negotiate and settle for a common CCID.
| 
Sorry the above includes the whole dccp test tree, over and above the
feature negotiation. We have been waiting for Arnaldo and there was a
phase where people sent comments about this patch set, so I had not
prepared a second net-next-2.6 pull request for this patch set yet.

If you want to revert this, I will prepare a net-next-2.6 clone with
just the revised 37 patches from this set.

Otherwise some parts (as below) need to be modified.


| #if (HZ >= 500)
| # define TFRC_T_DELTA		   USEC_PER_MSEC
| #else
| # define TFRC_T_DELTA		   (USEC_PER_SEC / (2 * HZ))
| #warning Coarse CONFIG_HZ resolution -- higher value recommended for TFRC.
| #endif
| 
| Don't warn about crap like this, instead convert the code over to hrtimers.
| 
| This kernel being built, even with HZ=100, can do nanosecond timers on
| my systems, but that's only if you would make proper use of them.
| 
The present sk_timer implementation uses the algorithm from RFC 3448. I
did not want to blindly port it to hrtimer since so far the following
difficulties were in the way:

 * when using the algorithm from RFC 3448, 4.6 directly with hrtimers,
   a large burst of activity will result, especially on fast links;

 * I have doubts whether it will help: each time the precision is improved,
   more frantic high-frequency noise results in CCID-3:
   - at some time socket timestamps were suggested for better RTT measurement,
     it proved better to reduce the precision to taking timestamps within the
     DCCP module (smoother response and also includes slow receiver);
   - even with that, on Gigabit Ethernet zero-RTT samples still occur;
   - one of the above patches updates CCID-3 to track the sending rate X_recv 
     with higher frequency. There seems to be not much benefit, when comparing
     the sender plots, the amount of high-frequency noise in X_recv has
     increased after increasing the frequency of updating;

 * some people have suggested to use a timerless algorithm instead which 
   would just control the number of packets per time. This would require
   rewriting some of the infrastructure (with benefits), it would use
   hrtimers for measuring the time intervals. 
